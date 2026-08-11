import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user_model.dart';
import 'auth_failure.dart';

export 'auth_failure.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userModelProvider = StateProvider<UserModel?>((ref) => null);

/// The signed-in user *right now*, for imperative write paths (saving a diary
/// entry, deleting a record, sharing a collection...).
///
/// Those used to read `ref.read(authStateProvider).value`, which is the last
/// value emitted by a stream — and it is `null` until that stream's first
/// emission. Anything acting before then saw "signed out" and silently took
/// the guest branch, writing to a local database that no signed-in screen ever
/// reads back. `FirebaseAuth.currentUser` is populated synchronously and is
/// the authoritative answer.
///
/// Widgets rendering *based on* auth state should keep watching
/// [authStateProvider] instead — they need to rebuild when it changes, which a
/// plain getter can't drive.
extension CurrentUserOnWidgetRef on WidgetRef {
  User? get currentUser => read(firebaseAuthProvider).currentUser;
}

extension CurrentUserOnRef on Ref {
  User? get currentUser => read(firebaseAuthProvider).currentUser;
}

final userModelStreamProvider = StreamProvider.family<UserModel?, String>((
  ref,
  userId,
) {
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

/// Display-name fallback for a signed-in [User] that has no profile document
/// yet. Uses a privacy-preserving handle based on UID instead of email prefix.
String defaultUsernameFor(User user) {
  final suffix = user.uid.length >= 6 ? user.uid.substring(0, 6) : 'user';
  return 'sinefil_$suffix';
}

String defaultAvatarUrlFor(String username) =>
    'https://api.dicebear.com/7.x/bottts/png?seed=$username';

/// The display name + avatar stamped onto anything the current user authors
/// (diary logs, community posts, comments, shared collections).
///
/// Those documents denormalise the author's identity so a feed render doesn't
/// need a `users` lookup per row. Resolving it lived inline at four call sites
/// as the same `userModel?.username ?? user.email!.split('@')[0]` pair — with
/// a `!` that throws for any account without an email — so it's one function
/// now.
typedef UserIdentity = ({String username, String avatarUrl});

UserIdentity resolveUserIdentity(UserModel? model, User? user) {
  final fromEmail = user == null ? '' : defaultUsernameFor(user);
  final username =
      model?.username ?? (fromEmail.isEmpty ? 'Anonim' : fromEmail);
  return (
    username: username,
    avatarUrl: model?.avatarUrl ?? defaultAvatarUrlFor(username),
  );
}

class AuthController {
  final Ref _ref;

  AuthController(this._ref);

  FirebaseAuth get _auth => _ref.read(firebaseAuthProvider);
  FirebaseFirestore get _firestore => _ref.read(firestoreProvider);

  /// Claims `usernames/{usernameLower}` for [uid], optionally releasing a
  /// previously held [previousUsernameLower] in the same transaction.
  ///
  /// This collection is what actually makes usernames unique. The old approach
  /// — query `users` for the name, then write if nothing came back — is a
  /// check-then-act race: two signups seconds apart both read "free" and both
  /// write. Here the claim is a document *create*, which Firestore only
  /// permits when the document does not already exist, so the second writer
  /// is rejected by the server rather than by a hopeful client-side read.
  ///
  /// Returns true if the claim succeeded, false if the name is already taken.
  Future<bool> _claimUsername({
    required String uid,
    required String usernameLower,
    String? previousUsernameLower,
  }) async {
    final claimRef = _firestore.collection('usernames').doc(usernameLower);
    try {
      await _firestore.runTransaction((tx) async {
        final existing = await tx.get(claimRef);
        if (existing.exists) {
          // Re-claiming a name this same user already holds (e.g. changing
          // only the capitalisation of their own username) is a no-op, not a
          // conflict.
          if (existing.data()?['uid'] == uid) return;
          throw _UsernameTakenException();
        }
        tx.set(claimRef, {'uid': uid});
        if (previousUsernameLower != null &&
            previousUsernameLower != usernameLower) {
          tx.delete(
            _firestore.collection('usernames').doc(previousUsernameLower),
          );
        }
      });
      return true;
    } on _UsernameTakenException {
      return false;
    }
  }

  /// Registers a claim for a username the user already holds, if one isn't
  /// recorded yet.
  ///
  /// The `usernames` registry was introduced after accounts already existed,
  /// so every pre-existing user's name is unreserved until something claims
  /// it — meaning someone else could sign up and take it. Backfilling this
  /// from a script would need admin credentials; doing it here instead means
  /// each account reserves its own name the next time its owner signs in,
  /// which is exactly what the security rules permit and needs no service
  /// account anywhere.
  ///
  /// Never fatal: if the name has already been taken by someone else in the
  /// meantime, that conflict predates this call and the user keeps their
  /// current username either way.
  Future<void> _backfillUsernameClaim(String uid, String username) async {
    final lower = username.trim().toLowerCase();
    if (lower.isEmpty) return;
    try {
      final claimed = await _claimUsername(uid: uid, usernameLower: lower);
      if (!claimed) {
        debugPrint(
          'Username "$lower" is already claimed by another account; '
          'leaving $uid\'s profile as-is.',
        );
      }
    } catch (e) {
      debugPrint('Username claim backfill failed for $uid: $e');
    }
  }

  Future<void> initUser(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        var model = UserModel.fromMap(doc.data()!, user.uid);

        // Profiles created before `avatarUrl` was always populated carry null.
        // Every document this user authors (logs, posts, comments) stamps the
        // avatar onto itself, and firestore.rules now requires that stamp to
        // equal the profile's — a null here would make the client fall back to
        // the generated DiceBear URL and the server would reject the write.
        // Backfilling once, on sign-in, keeps the two sides in step.
        if (model.avatarUrl == null || model.avatarUrl!.trim().isEmpty) {
          model = model.copyWith(
            avatarUrl: defaultAvatarUrlFor(model.username),
          );
          await _firestore.collection('users').doc(user.uid).set({
            'avatarUrl': model.avatarUrl,
          }, SetOptions(merge: true));
        }

        _ref.read(userModelProvider.notifier).state = model;
        // Fire-and-forget: sign-in must not wait on (or fail because of) a
        // registry write for a name the user already has.
        unawaited(_backfillUsernameClaim(user.uid, model.username));
        return;
      }

      // No profile document — the signup flow was interrupted after the Auth
      // account was created. Rebuild a minimal profile so the app is usable.
      // The email local part can collide with an existing username, so the
      // uid is appended when the claim fails rather than leaving the user
      // stuck on a screen they can't get past.
      final base = defaultUsernameFor(user);
      var username = base.isEmpty ? 'kullanici' : base;
      if (!await _claimUsername(
        uid: user.uid,
        usernameLower: username.toLowerCase(),
      )) {
        username = '$username-${user.uid.substring(0, 6)}';
        await _claimUsername(
          uid: user.uid,
          usernameLower: username.toLowerCase(),
        );
      }

      final newUser = UserModel(
        id: user.uid,
        username: username,
        avatarUrl: defaultAvatarUrlFor(username),
        onboardingCompleted: false,
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(_userDocFor(newUser));
      _ref.read(userModelProvider.notifier).state = newUser;
    } catch (e, st) {
      // Not fatal: the app still runs signed-in with a null userModel (every
      // consumer falls back to defaultUsernameFor). Logged rather than
      // swallowed silently so this is diagnosable when it does happen.
      debugPrint('initUser failed for ${user.uid}: $e\n$st');
    }
  }

  /// `usernameLower` is written alongside `username` purely so
  /// user_search_provider.dart can run a case-insensitive prefix query
  /// (Firestore range queries are otherwise case-sensitive). It is not part of
  /// [UserModel] because nothing reads it back into the app.
  Map<String, dynamic> _userDocFor(UserModel model) =>
      model.toMap()..['usernameLower'] = model.username.toLowerCase();

  /// Creates the username claim and profile together, so signup can never
  /// leave one behind without the other.
  Future<bool> _createProfileWithUsernameClaim(UserModel model) async {
    final usernameLower = model.username.toLowerCase();
    final claimRef = _firestore.collection('usernames').doc(usernameLower);
    final profileRef = _firestore.collection('users').doc(model.id);

    try {
      await _firestore.runTransaction((tx) async {
        final existing = await tx.get(claimRef);
        if (existing.exists && existing.data()?['uid'] != model.id) {
          throw _UsernameTakenException();
        }
        if (!existing.exists) {
          tx.set(claimRef, {'uid': model.id});
        }
        tx.set(profileRef, _userDocFor(model));
      });
      return true;
    } on _UsernameTakenException {
      return false;
    }
  }

  /// Returns null on success, or why it failed. See [AuthFailure] for why this
  /// is a reason rather than a ready-made message.
  Future<AuthFailure?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      return AuthFailure.usernameEmpty;
    }

    User? createdUser;
    try {
      // The Auth account has to exist before the username can be claimed:
      // `usernames` is only writable by an authenticated user (otherwise
      // anyone could squat every name without ever signing up). If the claim
      // then fails, the account created here is rolled back below.
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        // NOT trimmed: a password is an opaque secret, and silently stripping
        // whitespace changes what the user typed.
        password: password,
      );
      createdUser = credential.user;
      if (createdUser == null) {
        return AuthFailure.accountCreationFailed;
      }

      final newUser = UserModel(
        id: createdUser.uid,
        username: trimmedUsername,
        avatarUrl: defaultAvatarUrlFor(trimmedUsername),
        onboardingCompleted: false,
      );
      final claimed = await _createProfileWithUsernameClaim(newUser);
      if (!claimed) {
        await createdUser.delete();
        return AuthFailure.usernameTaken;
      }

      _ref.read(userModelProvider.notifier).state = newUser;
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return AuthFailure.emailAlreadyInUse;
      } else if (e.code == 'weak-password') {
        return AuthFailure.weakPassword;
      } else if (e.code == 'invalid-email') {
        return AuthFailure.invalidEmail;
      }
      debugPrint('signUp failed with unhandled code "${e.code}": ${e.message}');
      return AuthFailure.unknown;
    } catch (e) {
      // Never leave a half-created account behind: without a profile document
      // the user would be signed in to a broken state on next launch.
      try {
        await createdUser?.delete();
      } catch (rollbackError) {
        // The rollback itself failing is the worse outcome — it leaves an
        // orphaned Auth account with no profile document. initUser rebuilds a
        // profile for it on the next sign-in, so the user is not stuck, but
        // this should never pass unnoticed.
        debugPrint(
          'signUp rollback failed; ${createdUser?.uid} is now an '
          'Auth account with no profile: $rollbackError',
        );
      }
      debugPrint('signUp failed: $e');
      return AuthFailure.unknown;
    }
  }

  /// Returns null on success, or why it failed.
  Future<AuthFailure?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await initUser(credential.user!);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return AuthFailure.invalidCredentials;
      }
      debugPrint('signIn failed with unhandled code "${e.code}": ${e.message}');
      return AuthFailure.unknown;
    } catch (e) {
      debugPrint('signIn failed: $e');
      return AuthFailure.unknown;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _ref.read(userModelProvider.notifier).state = null;
  }

  /// Returns null on success, or why it failed.
  Future<AuthFailure?> updateProfile({
    required String username,
    required String? avatarUrl,
    required String? bio,
    List<String>? featuredMovieIds,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return AuthFailure.notSignedIn;

      final currentModel = _ref.read(userModelProvider);
      if (currentModel == null) return AuthFailure.userDataMissing;

      final newUsername = username.trim();
      if (newUsername.isEmpty) return AuthFailure.usernameEmpty;

      // Same server-enforced claim as signup, so a rename can't take a name
      // another user grabbed a moment earlier.
      if (currentModel.username.toLowerCase() != newUsername.toLowerCase()) {
        final claimed = await _claimUsername(
          uid: user.uid,
          usernameLower: newUsername.toLowerCase(),
          previousUsernameLower: currentModel.username.toLowerCase(),
        );
        if (!claimed) return AuthFailure.usernameTaken;
      }

      final updatedModel = currentModel.copyWith(
        username: newUsername,
        avatarUrl: avatarUrl?.trim(),
        bio: bio?.trim(),
        featuredMovieIds: featuredMovieIds,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(_userDocFor(updatedModel));

      // Update local state
      _ref.read(userModelProvider.notifier).state = updatedModel;

      return null;
    } catch (e) {
      debugPrint('updateProfile failed: $e');
      return AuthFailure.unknown;
    }
  }
}

class _UsernameTakenException implements Exception {}
