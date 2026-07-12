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
import 'package:filmdizi/features/journal/presentation/widgets/journal_record_list.dart';

const _tvMovieData = {
  'id': 900,
  'title': 'Test Dizi',
  'media_type': 'tv',
  'number_of_episodes': 3,
};

// A long-running show — typing the episode count directly must work here,
// since tapping "+" 786 times isn't a reasonable way to log it.
const _longRunningTvMovieData = {
  'id': 901,
  'title': 'Uzun Dizi',
  'media_type': 'tv',
  'number_of_episodes': 786,
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

Future<void> _openSheet(
  WidgetTester tester,
  GlobalKey<NavigatorState> navigatorKey, {
  Map<String, dynamic> movieData = _tvMovieData,
}) async {
  unawaited(navigatorKey.currentState!.push(
    MaterialPageRoute(
      builder: (context) => Scaffold(body: AddWatchRecordSheet(movieData: movieData)),
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

  testWidgets('default (not actively watching) marks the whole show as finished', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: _rootApp(navigatorKey)));
    await tester.pumpAndSettle();
    await _openSheet(tester, navigatorKey);

    // "Aktif İzliyorum" is off by default, and so is "Belirli sayıda bölüm" —
    // the default assumption is that the user finished the whole show (why
    // else would they be logging it without tracking progress). The manual
    // stepper should be hidden in this state.
    expect(find.text('Tüm sezonu bitirdim'), findsOneWidget);
    expect(find.text('Kaç bölüm izledin?'), findsNothing);

    await tester.tap(find.text('Kaydı Günlüğe Ekle'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    final settingsDoc = await firestore.collection('users').doc('test-uid').collection('movie_settings').doc('900_true').get();
    final settings = settingsDoc.data()!;
    expect(settings['lastWatchedEpisode'], 3);
    expect(settings['isActivelyWatching'], isFalse);

    final logsSnap = await firestore.collection('logs').where('userId', isEqualTo: 'test-uid').get();
    expect(logsSnap.docs.single.data()['episodeCount'], 3);

    // The Journal list (both the card list and the table view) marks a show
    // "Tamamlandı" purely from UserMovieSettings.lastWatchedEpisode reaching
    // totalEpisodes — so "Tüm sezonu bitirdim" surfaces the same green
    // checkmark as finishing a show one episode at a time via "Aktif
    // İzliyorum", with no extra wiring needed.
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
          body: JournalRecordsList(
            items: [WatchRecordWithMovie(watchWithMovie.record, movie, setting: setting)],
            onUpdateRanking: (_) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('close button dismisses the sheet without saving a record', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: _rootApp(navigatorKey)));
    await tester.pumpAndSettle();
    await _openSheet(tester, navigatorKey);

    expect(find.byType(AddWatchRecordSheet), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AddWatchRecordSheet), findsNothing);

    final logsSnap = await firestore.collection('logs').where('userId', isEqualTo: 'test-uid').get();
    expect(logsSnap.docs, isEmpty);
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

    // Switch to the manual partial-watch mode to reveal the stepper.
    await tester.tap(find.text('Belirli sayıda bölüm'));
    await tester.pumpAndSettle();

    // Default in manual mode is 1 episode — NOT the show's total
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

  testWidgets('manual episode count can be typed directly for long-running shows', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: _rootApp(navigatorKey)));
    await tester.pumpAndSettle();
    await _openSheet(tester, navigatorKey, movieData: _longRunningTvMovieData);

    await tester.tap(find.text('Belirli sayıda bölüm'));
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('episodeCountField'));
    await tester.enterText(field, '700');
    await tester.pump();
    expect(find.text('700'), findsOneWidget);

    // Typing past the show's total (786) clamps back down to it.
    await tester.enterText(field, '9999');
    await tester.pump();
    expect(find.text('786'), findsOneWidget);

    await tester.tap(find.text('Kaydı Günlüğe Ekle'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    final settingsDoc = await firestore.collection('users').doc('test-uid').collection('movie_settings').doc('901_true').get();
    expect(settingsDoc.data()!['lastWatchedEpisode'], 786);
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

    // "Topluluğa Paylaş" now renders first (moved above episode tracking so
    // it's harder to miss), so "Aktif İzliyorum" is the second Switch.
    await tester.tap(find.byType(Switch).at(1));
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
            onReorderItem: (items, oldIndex, newIndex) {},
            onUpdateRanking: (_) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
