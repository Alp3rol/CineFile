// Regression test for a real privacy-fix bug: viewing another user's
// profile threw [cloud_firestore/permission-denied] because
// watchRecordsForUserProvider queried `logs` filtered only by `userId`,
// with no `isPublic` filter. firestore.rules' read rule
// (`isPublic == true || auth.uid == resource.data.userId`) can't be
// statically satisfied by a query that doesn't filter on isPublic, so
// Firestore denies the whole query for a non-owner viewer. The fix adds
// `isPublic == true` to the query itself when the viewer isn't the owner —
// this test verifies that filtering happens client-side (a real emulator/
// rules test would be needed to verify the server denies the old query,
// but fake_cloud_firestore doesn't enforce security rules).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/core/database/database_provider.dart';

Future<void> _seedLogs(FakeFirebaseFirestore firestore, String ownerId) async {
  await firestore.collection('logs').doc('public1').set({
    'userId': ownerId,
    'username': 'owner',
    'userAvatarUrl': '',
    'movieId': 1,
    'movieTitle': 'Public Movie',
    'isTv': false,
    'watchDate': Timestamp.fromDate(DateTime(2026, 1, 1)),
    'rating': 8.0,
    'mood': '🍿',
    'watchNumber': 1,
    'episodeCount': 1,
    'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    'starredBy': <String>[],
    'commentCount': 0,
    'isPublic': true,
  });
  await firestore.collection('logs').doc('private1').set({
    'userId': ownerId,
    'username': 'owner',
    'userAvatarUrl': '',
    'movieId': 2,
    'movieTitle': 'Private Movie',
    'isTv': false,
    'watchDate': Timestamp.fromDate(DateTime(2026, 1, 2)),
    'rating': 7.0,
    'mood': '🍿',
    'watchNumber': 1,
    'episodeCount': 1,
    'createdAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
    'starredBy': <String>[],
    'commentCount': 0,
    'isPublic': false,
  });
}

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await _seedLogs(firestore, 'owner');
  });

  test('owner viewing their own profile sees both public and private logs', () async {
    final container = ProviderContainer(overrides: [
      firebaseAuthProvider.overrideWithValue(
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'owner', email: 'owner@test.com')),
      ),
      firestoreProvider.overrideWithValue(firestore),
    ]);
    addTearDown(container.dispose);

    // watchRecordsForUserProvider watches authStateProvider (also async) to
    // decide whether isPublic should be filtered. Reading its .future before
    // authStateProvider has emitted races a provider rebuild against the
    // Future captured here, which orphans it — settle auth first.
    await container.read(authStateProvider.future);

    final records = await container.read(watchRecordsForUserProvider('owner').future);
    final titles = records.map((r) => r.movie.title).toSet();

    expect(titles, {'Public Movie', 'Private Movie'});
  });

  test('a stranger viewing someone else\'s profile only sees public logs', () async {
    final container = ProviderContainer(overrides: [
      firebaseAuthProvider.overrideWithValue(
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'stranger', email: 'stranger@test.com')),
      ),
      firestoreProvider.overrideWithValue(firestore),
    ]);
    addTearDown(container.dispose);

    // watchRecordsForUserProvider watches authStateProvider (also async) to
    // decide whether isPublic should be filtered. Reading its .future before
    // authStateProvider has emitted races a provider rebuild against the
    // Future captured here, which orphans it — settle auth first.
    await container.read(authStateProvider.future);

    final records = await container.read(watchRecordsForUserProvider('owner').future);
    final titles = records.map((r) => r.movie.title).toSet();

    expect(titles, {'Public Movie'});
  });
}
