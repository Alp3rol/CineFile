// Verifies the "Aktif İzliyorum" quick-add flow: activelyWatchingProvider
// surfaces shows with UserMovieSettings.isActivelyWatching (from Firestore),
// the ActivelyWatchingRow renders them with a quick-add "+" button, and
// tapping it advances lastWatchedEpisode immediately — no dialog, and
// (unlike the Journal table's quick-advance tag, see
// journal_quick_advance_tag_test.dart) without creating a new diary log
// entry, since this is meant as a lightweight "mark next episode watched"
// shortcut, not a diary action. Also removes the show from the active list
// once the last episode is reached.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/core/widgets/actively_watching_row.dart';

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

  Future<void> seedActivelyWatchingShow({required int tmdbId, required int totalEpisodes, required int lastWatchedEpisode}) async {
    // One existing log so activelyWatchingProvider (which joins movie_settings
    // with the matching log) can resolve the show's title/poster/etc.
    await firestore.collection('logs').add({
      'userId': uid,
      'username': 'tester',
      'userAvatarUrl': '',
      'movieId': tmdbId,
      'isTv': true,
      'movieTitle': 'Aktif Dizi',
      'movieTotalEpisodes': totalEpisodes,
      'watchDate': Timestamp.now(),
      'rating': 7.0,
      'mood': '🍿',
      'watchNumber': 1,
      'episodeCount': lastWatchedEpisode,
      'createdAt': Timestamp.now(),
      'starredBy': <String>[],
      'commentCount': 0,
    });
    await firestore.collection('users').doc(uid).collection('movie_settings').doc('${tmdbId}_true').set({
      'movieId': tmdbId,
      'isTv': true,
      'isFavorite': false,
      'isReWatchList': false,
      'isActivelyWatching': true,
      'lastWatchedEpisode': lastWatchedEpisode,
      'updatedAt': Timestamp.now(),
    });
  }

  testWidgets('activelyWatchingProvider only returns shows marked isActivelyWatching', (tester) async {
    await seedActivelyWatchingShow(tmdbId: 1, totalEpisodes: 10, lastWatchedEpisode: 3);
    // A finished show (isActivelyWatching false) must not show up.
    await firestore.collection('logs').add({
      'userId': uid,
      'username': 'tester',
      'userAvatarUrl': '',
      'movieId': 2,
      'isTv': true,
      'movieTitle': 'Bitmiş Dizi',
      'movieTotalEpisodes': 5,
      'watchDate': Timestamp.now(),
      'rating': 8.0,
      'mood': '🍿',
      'watchNumber': 1,
      'episodeCount': 5,
      'createdAt': Timestamp.now(),
      'starredBy': <String>[],
      'commentCount': 0,
    });
    await firestore.collection('users').doc(uid).collection('movie_settings').doc('2_true').set({
      'movieId': 2,
      'isTv': true,
      'isFavorite': false,
      'isReWatchList': false,
      'isActivelyWatching': false,
      'lastWatchedEpisode': 5,
      'updatedAt': Timestamp.now(),
    });

    // Reading `.future` directly (no widget subscribing to the provider)
    // never drives the fake Firestore stream forward, so mount a trivial
    // Consumer and pumpAndSettle instead — same pattern the widget test below
    // already relies on.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(builder: (context, ref, _) {
            ref.watch(activelyWatchingProvider);
            return const SizedBox();
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = container.read(activelyWatchingProvider).value!;
    expect(list.length, 1);
    expect(list.single.movie.tmdbId, 1);
    expect(list.single.setting.lastWatchedEpisode, 3);
  });

  testWidgets('quick-add "+" advances episode progress without a new diary entry, and auto-completes on the last one',
      (tester) async {
    // total=2, already at episode 1 — one quick-add should finish the show.
    await seedActivelyWatchingShow(tmdbId: 5, totalEpisodes: 2, lastWatchedEpisode: 1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: ActivelyWatchingRow()))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bölüm 2 / 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    final settingsDoc =
        await firestore.collection('users').doc(uid).collection('movie_settings').doc('5_true').get();
    expect(settingsDoc.data()!['lastWatchedEpisode'], 2);
    expect(settingsDoc.data()!['isActivelyWatching'], isFalse);

    // No new diary entry should be created by the quick-add "+" — only the
    // one log seeded to make the show resolvable in the first place.
    final logsSnap = await firestore.collection('logs').where('userId', isEqualTo: uid).where('movieId', isEqualTo: 5).get();
    expect(logsSnap.docs.length, 1);

    // The show is done, so the row (and quick-add button) is gone now.
    expect(find.text('Aktif Dizi'), findsNothing);
  });

  testWidgets('activelyWatchingProvider returns shows sorted by updatedAt descending', (tester) async {
    // Seed show 1 with updatedAt = 2 hours ago
    await seedActivelyWatchingShow(tmdbId: 1, totalEpisodes: 10, lastWatchedEpisode: 3);
    await firestore.collection('users').doc(uid).collection('movie_settings').doc('1_true').update({
      'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
    });

    // Seed show 2 with updatedAt = now (more recent)
    await seedActivelyWatchingShow(tmdbId: 2, totalEpisodes: 5, lastWatchedEpisode: 1);
    await firestore.collection('users').doc(uid).collection('movie_settings').doc('2_true').update({
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(builder: (context, ref, _) {
            ref.watch(activelyWatchingProvider);
            return const SizedBox();
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = container.read(activelyWatchingProvider).value!;
    expect(list.length, 2);
    // Show 2 should be first because it was updated more recently
    expect(list[0].movie.tmdbId, 2);
    expect(list[1].movie.tmdbId, 1);
  });
}
