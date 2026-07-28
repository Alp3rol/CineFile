import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/features/auth/controllers/auth_controller.dart';

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

      // Seed the current user doc. No `email` field: it is deliberately not
      // stored in this world-readable collection any more (see UserModel).
      await firestore.collection('users').doc(uid).set({
        'username': 'tester',
        'usernameLower': 'tester',
        'avatarUrl': 'https://api.dicebear.com/7.x/bottts/png?seed=tester',
        'followerCount': 0,
        'followingCount': 0,
      });
      // ...and the matching claim in the registry that actually enforces
      // uniqueness (AuthController._claimUsername).
      await firestore.collection('usernames').doc('tester').set({'uid': uid});

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
      // Seed another user holding the target name, claim included.
      await firestore.collection('users').doc('another-uid').set({
        'username': 'takenname',
        'usernameLower': 'takenname',
        'avatarUrl': '',
        'followerCount': 0,
        'followingCount': 0,
      });
      await firestore.collection('usernames').doc('takenname').set({'uid': 'another-uid'});

      final authController = container.read(authControllerProvider);
      
      final result = await authController.updateProfile(
        username: 'takenname',
        avatarUrl: '',
        bio: 'New bio',
      );

      expect(result, AuthFailure.usernameTaken);

      // Verify that user doc was not updated in Firestore
      final doc = await firestore.collection('users').doc(uid).get();
      expect(doc.data()!['username'], 'tester'); // Stays 'tester'
    });

    // The registry was added after accounts already existed, so pre-existing
    // users have no claim on the name they are already using — anyone could
    // sign up and take it. Signing in reserves it.
    test('Signing in backfills a missing claim for the name the user already has',
        () async {
      await firestore.collection('usernames').doc('tester').delete();

      await container.read(authControllerProvider).initUser(mockAuth.currentUser!);
      // The backfill is deliberately not awaited by initUser.
      await Future<void>.delayed(Duration.zero);

      final claim = await firestore.collection('usernames').doc('tester').get();
      expect(claim.exists, isTrue);
      expect(claim.data()!['uid'], uid);
    });

    test('Backfill leaves a name already claimed by someone else alone', () async {
      await firestore.collection('usernames').doc('tester').set({'uid': 'someone-else'});

      await container.read(authControllerProvider).initUser(mockAuth.currentUser!);
      await Future<void>.delayed(Duration.zero);

      // The pre-existing conflict is not "resolved" by stealing the claim, and
      // sign-in still succeeds with the user's profile loaded.
      final claim = await firestore.collection('usernames').doc('tester').get();
      expect(claim.data()!['uid'], 'someone-else');
      expect(container.read(userModelProvider)!.username, 'tester');
    });

    // The registry, not a check-then-write query, is what makes names unique:
    // a claim is a document create, which Firestore refuses if the document
    // already exists. Renaming has to hand the old name back at the same time,
    // or names would leak out of circulation forever.
    test('A successful rename claims the new name and releases the old one', () async {
      final result = await container.read(authControllerProvider).updateProfile(
            username: 'cinephile99',
            avatarUrl: '',
            bio: '',
          );
      expect(result, isNull);

      final claimed = await firestore.collection('usernames').doc('cinephile99').get();
      expect(claimed.exists, isTrue);
      expect(claimed.data()!['uid'], uid);

      final released = await firestore.collection('usernames').doc('tester').get();
      expect(released.exists, isFalse);
    });

    test('A rejected rename leaves the original claim intact', () async {
      await firestore.collection('usernames').doc('takenname').set({'uid': 'another-uid'});

      final result = await container.read(authControllerProvider).updateProfile(
            username: 'takenname',
            avatarUrl: '',
            bio: '',
          );
      expect(result, AuthFailure.usernameTaken);

      // The user keeps their own name, and the other user keeps theirs.
      final own = await firestore.collection('usernames').doc('tester').get();
      expect(own.data()!['uid'], uid);
      final other = await firestore.collection('usernames').doc('takenname').get();
      expect(other.data()!['uid'], 'another-uid');
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
