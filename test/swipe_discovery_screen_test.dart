import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:cinefile/features/swipe_discovery/presentation/swipe_discovery_screen.dart';
import 'package:cinefile/features/swipe_discovery/data/swipe_preference_signal.dart';
import 'package:cinefile/features/movie_detail/presentation/movie_detail_provider.dart';
import 'package:cinefile/features/movie_detail/presentation/watch_providers_provider.dart';
import 'package:cinefile/features/movie_detail/domain/watch_provider_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_app.dart';

Map<String, dynamic> _movie(int id, String title) => {
  'id': id,
  'title': title,
  'poster_path': '',
  'release_date': '2026-01-01',
  'media_type': 'movie',
  'overview': 'A test overview',
  'vote_average': 8.2,
  'genre_ids': [18, 878],
  'recommendation_reason': 'Bilim kurgu sevdiğin için',
};

Widget _app({
  required Map<MovieKey, String> decisions,
  List<Map<String, dynamic>>? items,
  Future<List<Map<String, dynamic>>> Function()? onRefresh,
  MockFirebaseAuth? auth,
  FakeFirebaseFirestore? firestore,
}) {
  return ProviderScope(
    overrides: [
      allMovieSettingsProvider.overrideWith(
        (ref) => Stream.value(<MovieKey, UserMovieSetting>{}),
      ),
      allWatchRecordsProvider.overrideWith(
        (ref) => Stream.value(<WatchRecordWithMovie>[]),
      ),
      swipePreferenceSignalsProvider.overrideWith(
        (ref) => Stream.value(
          decisions.entries
              .map(
                (entry) => SwipePreferenceSignal(
                  isInterested: entry.value == 'interested',
                  genreIds: const [],
                  key: entry.key,
                ),
              )
              .toList(),
        ),
      ),
      movieDetailProvider((tmdbId: 42, isTv: false)).overrideWith(
        (ref) async => {
          ..._movie(42, 'Test Filmi'),
          'runtime': 126,
          'credits': {
            'crew': [
              {'name': 'Test Yönetmen', 'job': 'Director'},
            ],
            'cast': [
              {'name': 'Oyuncu Bir'},
              {'name': 'Oyuncu İki'},
            ],
          },
        },
      ),
      watchProvidersProvider((tmdbId: 42, isTv: false)).overrideWith(
        (ref) async => const WatchAvailability(
          region: 'TR',
          link: null,
          byCategory: {
            WatchProviderCategory.flatrate: [
              WatchProvider(
                providerId: 8,
                name: 'TestFlix',
                logoPath: null,
                displayPriority: 1,
              ),
            ],
          },
        ),
      ),
      if (auth != null) firebaseAuthProvider.overrideWithValue(auth),
      if (firestore != null) firestoreProvider.overrideWithValue(firestore),
    ],
    child: LocalizedTestApp(
      locale: const Locale('tr'),
      home: SwipeDiscoveryScreen(
        items: items ?? [_movie(42, 'Test Filmi')],
        onRefresh: onRefresh,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'swipe_gesture_guide_seen_v1': true,
    });
  });

  testWidgets('shows an unseen title as the active swipe card', (tester) async {
    await tester.pumpWidget(_app(decisions: const {}));
    await tester.pumpAndSettle();

    expect(find.text('Test Filmi'), findsOneWidget);
    expect(find.text('Bilim kurgu sevdiğin için'), findsOneWidget);
    expect(find.text('1 öneri kaldı'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_add_rounded), findsOneWidget);
    expect(find.text('Geç'), findsOneWidget);
    expect(find.text('Listeme Ekle'), findsOneWidget);
  });

  testWidgets('opens the premium quick look without leaving the deck', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(decisions: const {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Filmi'));
    await tester.pumpAndSettle();

    expect(find.text('Tüm Detayları Gör'), findsOneWidget);
    expect(find.text('A test overview'), findsWidgets);
    expect(find.text('126dk'), findsOneWidget);
    expect(find.text('TestFlix'), findsOneWidget);
    expect(find.text('Test Yönetmen'), findsOneWidget);
    expect(find.text('Oyuncu Bir, Oyuncu İki'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the gesture guide once and remembers its dismissal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app(decisions: const {}));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.swipe_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Kapat'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.swipe_rounded), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('swipe_gesture_guide_seen_v1'), isTrue);
  });

  testWidgets('reveals a decision stamp while dragging and springs back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(decisions: const {}));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('(isTv: false, tmdbId: 42)'))),
    );
    await gesture.moveBy(const Offset(25, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(45, 0));
    await tester.pump();

    expect(find.text('Listeme Ekle'), findsNWidgets(2));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Listeme Ekle'), findsOneWidget);
    expect(find.text('Test Filmi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('previews the next card behind the active recommendation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        decisions: const {},
        items: [_movie(42, 'Öndeki Film'), _movie(43, 'Sıradaki Film')],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Öndeki Film'), findsOneWidget);
    expect(find.text('Sıradaki Film'), findsOneWidget);
    expect(find.text('2 öneri kaldı'), findsOneWidget);
  });

  testWidgets('does not offer a title with a saved swipe decision', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(decisions: const {(tmdbId: 42, isTv: false): 'notInterested'}),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Filmi'), findsNothing);
    expect(find.text('Şimdilik hepsi bu!'), findsOneWidget);
  });

  testWidgets('explains that resetting swipes keeps watchlist and history', (
    tester,
  ) async {
    await tester.pumpWidget(_app(decisions: const {}));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tercihleri sıfırla'));
    await tester.pumpAndSettle();

    expect(find.text('Kaydırma tercihleri sıfırlansın mı?'), findsOneWidget);
    expect(
      find.text(
        'İlgilenmediğin içerikler yeniden önerilebilir. İzleme Listen ve izleme geçmişin değişmez.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads a fresh deck after all current titles are decided', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        decisions: const {(tmdbId: 42, isTv: false): 'notInterested'},
        onRefresh: () async => [_movie(43, 'Yeni Öneri')],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yeni öneriler getir'));
    await tester.pumpAndSettle();

    expect(find.text('Yeni Öneri'), findsOneWidget);
    expect(find.text('1 öneri kaldı'), findsOneWidget);
  });

  testWidgets('summarizes the decisions when the session deck is complete', (
    tester,
  ) async {
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'swipe-user'),
    );
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      _app(decisions: const {}, auth: auth, firestore: firestore),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Geç'));
    await tester.pumpAndSettle();

    expect(find.text('Bu Oturumda'), findsOneWidget);
    expect(find.text('Geçildi'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Şimdilik hepsi bu!'), findsOneWidget);
  });

  testWidgets('supports keyboard decisions without adding visual clutter', (
    tester,
  ) async {
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'keyboard-user'),
    );
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      _app(decisions: const {}, auth: auth, firestore: firestore),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    expect(find.text('Şimdilik hepsi bu!'), findsOneWidget);
    expect(find.text('Geçildi'), findsOneWidget);
  });

  testWidgets('explains which taste signals will shape recommendations', (
    tester,
  ) async {
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'taste-user'),
    );
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      _app(decisions: const {}, auth: auth, firestore: firestore),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Listeme Ekle'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Dram • Bilim Kurgu seçimlerin sonraki önerilerini güçlendirecek',
      ),
      findsOneWidget,
    );
  });
}
