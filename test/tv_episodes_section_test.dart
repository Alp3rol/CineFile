import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/movie_detail/presentation/widgets/tv_episodes_section.dart';
import 'package:filmdizi/features/movie_detail/presentation/tv_season_provider.dart';

const _seasonsData = [
  {
    'season_number': 1,
    'episode_count': 2,
    'name': '1. Sezon',
  },
  {
    'season_number': 2,
    'episode_count': 2,
    'name': '2. Sezon',
  }
];

const _mockSeason1Data = {
  'season_number': 1,
  'episodes': [
    {
      'episode_number': 1,
      'name': 'Episode 1 Name',
      'overview': 'Overview of episode 1.',
      'still_path': null,
      'air_date': '2011-04-17',
    },
    {
      'episode_number': 2,
      'name': 'Episode 2 Name',
      'overview': 'Overview of episode 2.',
      'still_path': null,
      'air_date': '2011-04-24',
    }
  ]
};

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

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
      tvSeasonDetailsProvider((tvId: 1, seasonNumber: 1)).overrideWith((ref) async => _mockSeason1Data),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  Widget _wrap({
    required Movie movie,
    required UserMovieSetting? settings,
    bool hasJournalEntry = true,
    int? totalEpisodes = 4,
    VoidCallback? onRequestAddToJournal,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MovieDetailTvEpisodesSection(
              movie: movie,
              seasons: _seasonsData,
              settings: settings,
              totalEpisodes: totalEpisodes,
              hasJournalEntry: hasJournalEntry,
              onRequestAddToJournal: onRequestAddToJournal ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders title, season chips, and loads episode list', (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(_wrap(movie: movie, settings: null));
    // Let the StreamProvider and FutureProvider both settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Bölüm Rehberi'), findsOneWidget);
    expect(find.text('1. Sezon'), findsOneWidget);
    expect(find.text('2. Sezon'), findsOneWidget);

    expect(find.text('1. Episode 1 Name'), findsOneWidget);
    expect(find.text('2. Episode 2 Name'), findsOneWidget);
    expect(find.text('17 Nisan 2011'), findsOneWidget);
    expect(find.text('Overview of episode 1.'), findsOneWidget);
  });

  testWidgets('tapping unchecked next episode updates settings in Firestore', (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    final initialSetting = UserMovieSetting(
      tmdbId: 1,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      lastWatchedEpisode: 0,
      isActivelyWatching: true,
    );

    // Pre-resolve auth so the stream is in AsyncData before the widget mounts.
    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: initialSetting));
    await tester.pumpAndSettle();

    // Tapping the first unchecked episode (episode 1)
    await tester.tap(find.byKey(const ValueKey('episode_check_1')));
    // Flush the async write and advance past the 2500ms PremiumToast timer
    // so pumpAndSettle doesn't hit a pending-timer assertion.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .get();

    expect(doc.exists, isTrue);
    expect(doc.data()?['lastWatchedEpisode'], 1);
    expect(doc.data()?['isActivelyWatching'], isTrue);
  });

  testWidgets('tapping checkmark of last watched episode rolls back settings', (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    final initialSetting = UserMovieSetting(
      tmdbId: 1,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      lastWatchedEpisode: 1,
      isActivelyWatching: true,
    );

    // Seed initial setting into mock Firestore
    await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .set({
      'movieId': 1,
      'isTv': true,
      'lastWatchedEpisode': 1,
      'isActivelyWatching': true,
    });

    // Pre-resolve auth
    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: initialSetting));
    await tester.pumpAndSettle();

    // Tap first checked episode (episode 1) to uncheck it
    await tester.tap(find.byKey(const ValueKey('episode_check_1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .get();

    expect(doc.data()?['lastWatchedEpisode'], 0);
    expect(doc.data()?['isActivelyWatching'], isTrue);
  });

  testWidgets('tapping a non-adjacent episode shows a bulk-confirm dialog; confirming jumps progress to it',
      (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    final initialSetting = UserMovieSetting(
      tmdbId: 1,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      lastWatchedEpisode: 0,
      isActivelyWatching: true,
    );

    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: initialSetting));
    await tester.pumpAndSettle();

    // Episode 2 is not adjacent to lastWatchedEpisode 0, so a bulk-confirm
    // dialog should appear instead of writing immediately.
    await tester.tap(find.byKey(const ValueKey('episode_check_2')));
    await tester.pumpAndSettle();

    expect(find.text('Bölümleri İzledin mi?'), findsOneWidget);

    await tester.tap(find.text('Evet'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .get();

    expect(doc.data()?['lastWatchedEpisode'], 2);
    expect(doc.data()?['isActivelyWatching'], isTrue);
  });

  testWidgets('un-journaled show prompts to add to journal; choosing "Günlüğe Ekle" opens the sheet without writing progress',
      (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    await container.read(authStateProvider.future);

    var addToJournalRequested = false;
    await tester.pumpWidget(_wrap(
      movie: movie,
      settings: null,
      hasJournalEntry: false,
      onRequestAddToJournal: () => addToJournalRequested = true,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('episode_check_1')));
    await tester.pumpAndSettle();

    expect(find.text('Bu diziyi günlüğüne eklemek ister misin?'), findsOneWidget);

    await tester.tap(find.text('Günlüğe Ekle'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(addToJournalRequested, isTrue);

    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .get();
    expect(doc.exists, isFalse);
  });

  testWidgets('un-journaled show prompts to add to journal; choosing "Sadece Takip Et" marks the episode as watched',
      (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: null, hasJournalEntry: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('episode_check_1')));
    await tester.pumpAndSettle();

    expect(find.text('Bu diziyi günlüğüne eklemek ister misin?'), findsOneWidget);

    await tester.tap(find.text('Sadece Takip Et'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .get();

    expect(doc.exists, isTrue);
    expect(doc.data()?['lastWatchedEpisode'], 1);
  });

  testWidgets('marking an episode when totalEpisodes is null (TMDb field missing) keeps the show actively watching',
      (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    final initialSetting = UserMovieSetting(
      tmdbId: 1,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      lastWatchedEpisode: 0,
      isActivelyWatching: true,
    );

    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: initialSetting, totalEpisodes: null));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('episode_check_1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .get();

    expect(doc.data()?['lastWatchedEpisode'], 1);
    // Regression: totalEpisodes == null used to coerce to 0 via `?? 0`,
    // making 1 < 0 false and incorrectly flipping isActivelyWatching off.
    expect(doc.data()?['isActivelyWatching'], isTrue);
  });

  testWidgets('shows a "Sıradaki" badge only on the next unwatched episode', (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    final initialSetting = UserMovieSetting(
      tmdbId: 1,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      lastWatchedEpisode: 0,
      isActivelyWatching: true,
    );

    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: initialSetting));
    await tester.pumpAndSettle();

    // lastWatchedEpisode is 0, so episode 1 (overall index 1) is next up.
    expect(find.text('▶ SIRADAKİ'), findsOneWidget);
  });

  testWidgets('"Bu Sezonu İzledim" completes the season via the existing bulk-confirm flow, and hides once complete',
      (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    final initialSetting = UserMovieSetting(
      tmdbId: 1,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      lastWatchedEpisode: 0,
      isActivelyWatching: true,
    );

    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: initialSetting));
    await tester.pumpAndSettle();

    expect(find.text('Bu Sezonu İzledim'), findsOneWidget);

    await tester.tap(find.text('Bu Sezonu İzledim'));
    await tester.pumpAndSettle();

    // Season 1 has 2 episodes; jumping from 0 straight to 2 is non-adjacent,
    // so the existing bulk-confirm dialog should appear.
    expect(find.text('Bölümleri İzledin mi?'), findsOneWidget);

    await tester.tap(find.text('Evet'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('movie_settings')
        .doc('1_true')
        .get();
    expect(doc.data()?['lastWatchedEpisode'], 2);
  });

  testWidgets('"Bu Sezonu İzledim" is hidden once the selected season is already fully watched', (tester) async {
    final movie = Movie(
      tmdbId: 1,
      title: 'Test Dizi',
      isTv: true,
      createdAt: DateTime.now(),
    );

    final initialSetting = UserMovieSetting(
      tmdbId: 1,
      isTv: true,
      isFavorite: false,
      isReWatchList: false,
      updatedAt: DateTime.now(),
      lastWatchedEpisode: 2, // Season 1 (2 episodes) already fully watched.
      isActivelyWatching: true,
    );

    await container.read(authStateProvider.future);

    await tester.pumpWidget(_wrap(movie: movie, settings: initialSetting));
    await tester.pumpAndSettle();

    expect(find.text('Bu Sezonu İzledim'), findsNothing);
  });
}
