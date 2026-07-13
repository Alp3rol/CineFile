// Verifies the compact "Bölüm X/Y +" tag added to the Journal table/card
// views (replacing the earlier full-width "Aktif İzlediklerin" row per user
// feedback): it only appears on an actively-watched show's latest record,
// and tapping "+" advances the episode progress counter immediately with no
// dialog/screen — and, like Home's quick-add "+", without creating a new
// diary log entry (an earlier version created one per tap, which made the
// diary look like a new show was added every time someone caught up on a
// few episodes from Journal).
//
// Watch records now live in Firestore (see database_provider.dart) rather
// than the local Drift DB, so this seeds a FakeFirebaseFirestore + a mocked
// signed-in user instead of an in-memory Drift database.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/journal/presentation/widgets/journal_table_list.dart';
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

  testWidgets('quick-advance tag advances episode progress without a new diary entry, no dialog', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await firestore.collection('logs').add({
      'userId': uid,
      'username': 'tester',
      'userAvatarUrl': '',
      'movieId': 700,
      'isTv': true,
      'movieTitle': 'Son Yaz',
      'movieTotalEpisodes': 26,
      'watchDate': Timestamp.fromDate(DateTime(2026, 7, 9)),
      'rating': 7.0,
      'mood': '🍿',
      'watchNumber': 4,
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
      'lastWatchedEpisode': 4,
      'updatedAt': Timestamp.now(),
    });

    // Reading `.future` directly (no widget subscribing to the provider)
    // never drives the fake Firestore stream forward, so mount a Consumer
    // that watches the provider and pumpAndSettle instead.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(builder: (context, ref, _) {
              final items = ref.watch(allWatchRecordsProvider).value ?? const [];
              return JournalRecordsTable(
                items: items,
                onReorderItem: (list, oldIndex, newIndex) {},
                onUpdateRanking: (_) async {},
              );
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The tag shows the *next* episode to log (lastWatchedEpisode + 1), not
    // the last one logged — see commit "Fix episode number mismatch between
    // home and journal".
    expect(find.text('5/26'), findsOneWidget);

    await tester.tap(find.text('5/26'));
    await tester.pumpAndSettle();

    // No dialog/screen appears — this must not have navigated anywhere.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(JournalRecordsTable), findsOneWidget);

    final settingsDoc =
        await firestore.collection('users').doc(uid).collection('movie_settings').doc('700_true').get();
    expect(settingsDoc.data()!['lastWatchedEpisode'], 5);
    expect(settingsDoc.data()!['isActivelyWatching'], isTrue);

    // No new diary entry should be created by the quick-advance tag — only
    // the one log seeded to make the record resolvable in the first place.
    final logsSnap = await firestore.collection('logs').where('userId', isEqualTo: uid).get();
    expect(logsSnap.docs.length, 1);
  });
}
