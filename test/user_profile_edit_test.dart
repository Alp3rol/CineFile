import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/auth/models/user_model.dart';

void main() {
  group('AuthController - Profile Edit Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;
    late ProviderContainer container;
    const uid = 'test-uid';

    setUp(() async {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: uid, email: 'tester@cinefile.com'),
      );
      firestore = FakeFirebaseFirestore();
      container = ProviderContainer(overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firestoreProvider.overrideWithValue(firestore),
      ]);

      // Seed the current user doc
      await firestore.collection('users').doc(uid).set({
        'email': 'tester@cinefile.com',
        'username': 'tester',
        'usernameLower': 'tester',
        'avatarUrl': 'https://api.dicebear.com/7.x/bottts/png?seed=tester',
        'followerCount': 0,
        'followingCount': 0,
      });

      // Synchronize state provider
      await container.read(authControllerProvider).initUser(mockAuth.currentUser!);
    });

    tearDown(() {
      container.dispose();
    });

    test('Successfully updates username, bio and avatarUrl', () async {
      final authController = container.read(authControllerProvider);
      
      final result = await authController.updateProfile(
        username: 'cinephile99',
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=cinephile99',
        bio: 'I love sci-fi movies!',
      );

      expect(result, isNull); // No error returned

      // Verify Firestore update
      final doc = await firestore.collection('users').doc(uid).get();
      expect(doc.data()!['username'], 'cinephile99');
      expect(doc.data()!['usernameLower'], 'cinephile99');
      expect(doc.data()!['bio'], 'I love sci-fi movies!');
      expect(doc.data()!['avatarUrl'], 'https://api.dicebear.com/7.x/bottts/png?seed=cinephile99');

      // Verify Local State update
      final localUser = container.read(userModelProvider);
      expect(localUser, isNotNull);
      expect(localUser!.username, 'cinephile99');
      expect(localUser.bio, 'I love sci-fi movies!');
      expect(localUser.avatarUrl, 'https://api.dicebear.com/7.x/bottts/png?seed=cinephile99');
    });

    test('Fails when trying to update to a username that is already taken', () async {
      // Seed another user doc with the target username
      await firestore.collection('users').doc('another-uid').set({
        'email': 'other@cinefile.com',
        'username': 'takenname',
        'usernameLower': 'takenname',
        'avatarUrl': '',
        'followerCount': 0,
        'followingCount': 0,
      });

      final authController = container.read(authControllerProvider);
      
      final result = await authController.updateProfile(
        username: 'takenname',
        avatarUrl: '',
        bio: 'New bio',
      );

      expect(result, 'Bu kullanıcı adı zaten alınmış.');

      // Verify that user doc was not updated in Firestore
      final doc = await firestore.collection('users').doc(uid).get();
      expect(doc.data()!['username'], 'tester'); // Stays 'tester'
    });

    test('Allows changing case of own username without "already taken" error', () async {
      final authController = container.read(authControllerProvider);
      
      final result = await authController.updateProfile(
        username: 'Tester', // Only case changed
        avatarUrl: '',
        bio: '',
      );

      expect(result, isNull);

      final doc = await firestore.collection('users').doc(uid).get();
      expect(doc.data()!['username'], 'Tester');
      expect(doc.data()!['usernameLower'], 'tester');
    });
  });
}
