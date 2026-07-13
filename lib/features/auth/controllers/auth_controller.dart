import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userModelProvider = StateProvider<UserModel?>((ref) => null);

final userModelStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;

  AuthController(this._ref);

  FirebaseAuth get _auth => _ref.read(firebaseAuthProvider);
  FirebaseFirestore get _firestore => _ref.read(firestoreProvider);
  FirebaseStorage get _storage => _ref.read(firebaseStorageProvider);

  Future<void> initUser(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _ref.read(userModelProvider.notifier).state = UserModel.fromMap(doc.data()!, user.uid);
      } else {
        // Create user doc if it doesn't exist (e.g. if signup process interrupted)
        final username = user.email!.split('@')[0];
        final newUser = UserModel(
          id: user.uid,
          email: user.email!,
          username: username,
          avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=$username',
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        _ref.read(userModelProvider.notifier).state = newUser;
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Check if username already exists
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .get();

      if (query.docs.isNotEmpty) {
        return 'Bu kullanıcı adı zaten alınmış.';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email.trim(),
          username: username.trim(),
          avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=${username.trim()}',
        );

        // usernameLower isn't part of UserModel (nothing in the app reads it
        // back) — it exists purely so user_search_provider.dart can do a
        // case-insensitive prefix query, since Firestore range queries are
        // otherwise case-sensitive.
        final userDoc = newUser.toMap()..['usernameLower'] = username.trim().toLowerCase();
        await _firestore.collection('users').doc(credential.user!.uid).set(userDoc);
        _ref.read(userModelProvider.notifier).state = newUser;
      }
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
        password: password.trim(),
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
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Kullanıcı oturumu bulunamadı.';

      final currentModel = _ref.read(userModelProvider);
      if (currentModel == null) return 'Kullanıcı verisi bulunamadı.';

      final newUsername = username.trim();
      if (newUsername.isEmpty) return 'Kullanıcı adı boş olamaz.';

      // Check if username is already taken by another user
      if (currentModel.username.toLowerCase() != newUsername.toLowerCase()) {
        final query = await _firestore
            .collection('users')
            .where('usernameLower', isEqualTo: newUsername.toLowerCase())
            .get();

        if (query.docs.isNotEmpty) {
          return 'Bu kullanıcı adı zaten alınmış.';
        }
      }

      final updatedModel = currentModel.copyWith(
        username: newUsername,
        avatarUrl: avatarUrl?.trim(),
        bio: bio?.trim(),
      );

      final userDoc = updatedModel.toMap()..['usernameLower'] = newUsername.toLowerCase();
      await _firestore.collection('users').doc(user.uid).update(userDoc);
      
      // Update local state
      _ref.read(userModelProvider.notifier).state = updatedModel;
      
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> uploadAvatarImage(Uint8List imageBytes, String fileName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final storageRef = _storage
          .ref()
          .child('avatars')
          .child(user.uid)
          .child(fileName);

      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('uploadAvatarImage failed: $e');
      return null;
    }
  }
}
