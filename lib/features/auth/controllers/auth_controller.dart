import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

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

final userModelStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
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
/// yet. Uses the local part of their own email, which the client always has
/// from Firebase Auth — deliberately NOT read back from Firestore, since the
/// email is no longer stored there (see [UserModel]).
String defaultUsernameFor(User user) => (user.email ?? '').split('@').first;

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
  final username = model?.username ?? (fromEmail.isEmpty ? 'Anonim' : fromEmail);
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
        if (previousUsernameLower != null && previousUsernameLower != usernameLower) {
          tx.delete(_firestore.collection('usernames').doc(previousUsernameLower));
        }
      });
      return true;
    } on _UsernameTakenException {
      return false;
    }
  }

  Future<void> initUser(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _ref.read(userModelProvider.notifier).state = UserModel.fromMap(doc.data()!, user.uid);
        return;
      }

      // No profile document — the signup flow was interrupted after the Auth
      // account was created. Rebuild a minimal profile so the app is usable.
      // The email local part can collide with an existing username, so the
      // uid is appended when the claim fails rather than leaving the user
      // stuck on a screen they can't get past.
      final base = defaultUsernameFor(user);
      var username = base.isEmpty ? 'kullanici' : base;
      if (!await _claimUsername(uid: user.uid, usernameLower: username.toLowerCase())) {
        username = '$username-${user.uid.substring(0, 6)}';
        await _claimUsername(uid: user.uid, usernameLower: username.toLowerCase());
      }

      final newUser = UserModel(
        id: user.uid,
        username: username,
        avatarUrl: defaultAvatarUrlFor(username),
      );
      await _firestore.collection('users').doc(user.uid).set(_userDocFor(newUser));
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

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      return 'Kullanıcı adı boş olamaz.';
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
        return 'Hesap oluşturulamadı, lütfen tekrar deneyin.';
      }

      final claimed = await _claimUsername(
        uid: createdUser.uid,
        usernameLower: trimmedUsername.toLowerCase(),
      );
      if (!claimed) {
        await createdUser.delete();
        return 'Bu kullanıcı adı zaten alınmış.';
      }

      final newUser = UserModel(
        id: createdUser.uid,
        username: trimmedUsername,
        avatarUrl: defaultAvatarUrlFor(trimmedUsername),
      );
      await _firestore.collection('users').doc(createdUser.uid).set(_userDocFor(newUser));
      _ref.read(userModelProvider.notifier).state = newUser;
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Bu e-posta adresi zaten kullanılıyor.';
      } else if (e.code == 'weak-password') {
        return 'Şifre en az 6 karakter olmalıdır.';
      } else if (e.code == 'invalid-email') {
        return 'Geçersiz bir e-posta adresi girdiniz.';
      }
      return e.message ?? 'Bir hata oluştu.';
    } catch (e) {
      // Never leave a half-created account behind: without a profile document
      // the user would be signed in to a broken state on next launch.
      try {
        await createdUser?.delete();
      } catch (_) {}
      return e.toString();
    }
  }

  Future<String?> signIn({
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
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'E-posta veya şifre hatalı.';
      }
      return e.message ?? 'Giriş yapılamadı.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _ref.read(userModelProvider.notifier).state = null;
  }

  Future<String?> updateProfile({
    required String username,
    required String? avatarUrl,
    required String? bio,
    List<String>? featuredMovieIds,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Kullanıcı oturumu bulunamadı.';

      final currentModel = _ref.read(userModelProvider);
      if (currentModel == null) return 'Kullanıcı verisi bulunamadı.';

      final newUsername = username.trim();
      if (newUsername.isEmpty) return 'Kullanıcı adı boş olamaz.';

      // Same server-enforced claim as signup, so a rename can't take a name
      // another user grabbed a moment earlier.
      if (currentModel.username.toLowerCase() != newUsername.toLowerCase()) {
        final claimed = await _claimUsername(
          uid: user.uid,
          usernameLower: newUsername.toLowerCase(),
          previousUsernameLower: currentModel.username.toLowerCase(),
        );
        if (!claimed) return 'Bu kullanıcı adı zaten alınmış.';
      }

      final updatedModel = currentModel.copyWith(
        username: newUsername,
        avatarUrl: avatarUrl?.trim(),
        bio: bio?.trim(),
        featuredMovieIds: featuredMovieIds,
      );

      await _firestore.collection('users').doc(user.uid).update(_userDocFor(updatedModel));

      // Update local state
      _ref.read(userModelProvider.notifier).state = updatedModel;

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

class _UsernameTakenException implements Exception {}
