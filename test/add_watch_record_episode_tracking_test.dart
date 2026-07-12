// Verifies the "Aktif İzliyorum" episode tracking added to
// AddWatchRecordSheet: the manual episode-count stepper is capped at the
// show's total episode count (the reported bug — it used to climb past 26
// for a 26-episode show), active tracking suggests the next episode across
// separate watch records, and reaching the last episode marks the show
// completed (surfaced as a checkmark badge in the Journal list).
//
// Saving now writes to Firestore (not the local Drift DB) — see
// AddWatchRecordSheet._saveRecord — so these tests run against
// FakeFirebaseFirestore + a mocked signed-in FirebaseAuth user instead of an
// in-memory Drift database.
import 'dart:async';
import 'package:drift/drift.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/journal/models/diary_log_model.dart';
import 'package:filmdizi/features/movie_detail/presentation/add_watch_record_sheet.dart';
import 'package:filmdizi/features/journal/presentation/widgets/journal_table_list.dart';

const _tvMovieData = {
  'id': 900,
  'title': 'Test Dizi',
  'media_type': 'tv',
  'number_of_episodes': 3,
};

// A base route + a real Navigator, so AddWatchRecordSheet's own
// Navigator.pop(context) on save works exactly like it does in the real app
// (the sheet is normally pushed as its own route/modal, not the app's only
// route). Each _openSheet call pushes a fresh route — and therefore a fresh
// State — the same way reopening the "Kayıt Ekle" bottom sheet does.
//
// The GlobalKey is created fresh per test (not module-level) — reusing one
// GlobalKey across separate pumpWidget trees in different tests corrupts
// the element tree.
Widget _rootApp(GlobalKey<NavigatorState> navigatorKey) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    home: const Scaffold(body: SizedBox()),
  );
}

Future<void> _openSheet(WidgetTester tester, GlobalKey<NavigatorState> navigatorKey) async {
  unawaited(navigatorKey.currentState!.push(
    MaterialPageRoute(
      builder: (context) => const Scaffold(body: AddWatchRecordSheet(movieData: _tvMovieData)),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late ProviderContainer container;

  setUp(() {
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'test-uid', email: 'test@test.com'));
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(overrides: [
      firebaseAuthProvider.overrideWithValue(mockAuth),
      firestoreProvider.overrideWithValue(firestore),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('manual episode-count stepper cannot exceed the total episode count', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: _rootApp(navigatorKey)));
    await tester.pumpAndSettle();
    await _openSheet(tester, navigatorKey);

    // Default (not actively watching) is 1 episode — NOT the show's total
    // (defaulting to "all episodes" caused a real bug: logging the same
    // show multiple times each counted as a full rewatch of the series).
    expect(find.text('1'), findsOneWidget);

    // Tapping "+" repeatedly must not push it past 3.
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
    }
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsNothing);
  });

  testWidgets('active tracking suggests the next episode across separate records, then completes', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: _rootApp(navigatorKey)));
    await tester.pumpAndSettle();

    // --- Record 1: turn on active tracking, keep suggested episode 1 ---
    await _openSheet(tester, navigatorKey);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Bölüm 1 / 3'), findsOneWidget);

    await tester.tap(find.text('Kaydı Günlüğe Ekle'));
    await tester.pumpAndSettle();
    // Flush the success-toast's auto-dismiss timer (Future.delayed) so it
    // doesn't leak past this test — pumpAndSettle doesn't wait for timers
    // that aren't tied to a scheduled frame.
    await tester.pump(const Duration(seconds: 3));

    Future<Map<String, dynamic>> settingsData() async {
      final doc = await firestore.collection('users').doc('test-uid').collection('movie_settings').doc('900_true').get();
      return doc.data()!;
    }

    var settings = await settingsData();
    expect(settings['lastWatchedEpisode'], 1);
    expect(settings['isActivelyWatching'], isTrue);

    var logsSnap = await firestore.collection('logs').where('userId', isEqualTo: 'test-uid').get();
    expect(logsSnap.docs.single.data()['episodeCount'], 1);

    // --- Record 2: a fresh sheet instance should suggest episode 2 ---
    await _openSheet(tester, navigatorKey);
    expect(find.text('Bölüm 2 / 3'), findsOneWidget);

    await tester.tap(find.text('Kaydı Günlüğe Ekle'));
    await tester.pumpAndSettle();
    // Flush the success-toast's auto-dismiss timer (Future.delayed) so it
    // doesn't leak past this test — pumpAndSettle doesn't wait for timers
    // that aren't tied to a scheduled frame.
    await tester.pump(const Duration(seconds: 3));

    settings = await settingsData();
    expect(settings['lastWatchedEpisode'], 2);
    expect(settings['isActivelyWatching'], isTrue);

    // --- Record 3: reaching the last episode (3/3) auto-completes ---
    await _openSheet(tester, navigatorKey);
    expect(find.text('Bölüm 3 / 3'), findsOneWidget);

    await tester.tap(find.text('Kaydı Günlüğe Ekle'));
    await tester.pumpAndSettle();
    // Flush the success-toast's auto-dismiss timer (Future.delayed) so it
    // doesn't leak past this test — pumpAndSettle doesn't wait for timers
    // that aren't tied to a scheduled frame.
    await tester.pump(const Duration(seconds: 3));

    settings = await settingsData();
    expect(settings['lastWatchedEpisode'], 3);
    expect(settings['isActivelyWatching'], isFalse); // auto-cleared: "Tamamlandı"

    // The Journal table view shows a completed checkmark for this record.
    logsSnap = await firestore.collection('logs').where('userId', isEqualTo: 'test-uid').get();
    final log = DiaryLogModel.fromMap(logsSnap.docs.first.data(), logsSnap.docs.first.id);
    final watchWithMovie = log.toWatchRecordWithMovie();
    final setting = UserMovieSetting(
      tmdbId: 900,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      isActivelyWatching: false,
      lastWatchedEpisode: 3,
    );
    final movie = watchWithMovie.movie.copyWith(totalEpisodes: const Value(3));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JournalRecordsTable(
            items: [WatchRecordWithMovie(watchWithMovie.record, movie, setting: setting)],
            onReorder: (items, oldIndex, newIndex) {},
            onUpdateRanking: (_) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
