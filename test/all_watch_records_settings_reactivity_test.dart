// Regression test for a bug where allWatchRecordsProvider (the Journal's
// data source) only refreshed on 'logs' collection changes, so a
// settings-only write — like advanceEpisodeProgress (the quick-add "+"
// button, see episode_logging.dart) which only touches 'movie_settings',
// never 'logs' — never showed up in Journal. This left Journal displaying a
// stale episode number that visibly differed from Home (which reads
// activelyWatchingProvider, already reactive to movie_settings), and made
// tapping "+" from Journal look like it did nothing at all.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/core/database/database_provider.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late ProviderContainer container;
  const uid = 'test-uid';

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: uid, email: 'test@test.com'));
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(overrides: [
      firebaseAuthProvider.overrideWithValue(mockAuth),
      firestoreProvider.overrideWithValue(firestore),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('a settings-only write (no logs change) updates allWatchRecordsProvider', (tester) async {
    await firestore.collection('logs').add({
      'userId': uid,
      'username': 'tester',
      'userAvatarUrl': '',
      'movieId': 700,
      'isTv': true,
      'movieTitle': 'Kalk Gidelim',
      'movieTotalEpisodes': 135,
      'watchDate': Timestamp.fromDate(DateTime(2026, 7, 13)),
      'rating': 7.0,
      'watchNumber': 1,
      'episodeCount': 1,
      'createdAt': Timestamp.now(),
      'starredBy': <String>[],
      'commentCount': 0,
    });
    await firestore.collection('users').doc(uid).collection('movie_settings').doc('700_true').set({
      'movieId': 700,
      'isTv': true,
      'isFavorite': false,
      'isReWatchList': false,
      'isActivelyWatching': true,
      'lastWatchedEpisode': 55,
      'updatedAt': Timestamp.now(),
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(builder: (context, ref, _) {
            ref.watch(allWatchRecordsProvider);
            return const SizedBox();
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(allWatchRecordsProvider).value!.single.setting!.lastWatchedEpisode, 55);

    // Simulate what advanceEpisodeProgress does: write ONLY to
    // movie_settings, never touching the 'logs' collection at all.
    await firestore.collection('users').doc(uid).collection('movie_settings').doc('700_true').set({
      'lastWatchedEpisode': 61,
    }, SetOptions(merge: true));
    await tester.pumpAndSettle();

    expect(container.read(allWatchRecordsProvider).value!.single.setting!.lastWatchedEpisode, 61);
  });
}
