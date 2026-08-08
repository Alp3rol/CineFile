import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/features/swipe_discovery/presentation/swipe_discovery_screen.dart';
import 'package:cinefile/features/swipe_discovery/data/swipe_preference_signal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_app.dart';

Map<String, dynamic> _movie(int id, String title) => {
  'id': id,
  'title': title,
  'poster_path': '',
  'release_date': '2026-01-01',
  'media_type': 'movie',
  'overview': 'A test overview',
  'vote_average': 8.2,
  'recommendation_reason': 'Bilim kurgu sevdiğin için',
};

Widget _app({
  required Map<MovieKey, String> decisions,
  List<Map<String, dynamic>>? items,
  Future<List<Map<String, dynamic>>> Function()? onRefresh,
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
  testWidgets('shows an unseen title as the active swipe card', (tester) async {
    await tester.pumpWidget(_app(decisions: const {}));
    await tester.pumpAndSettle();

    expect(find.text('Test Filmi'), findsOneWidget);
    expect(find.text('Bilim kurgu sevdiğin için'), findsOneWidget);
    expect(find.text('1 öneri kaldı'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_add_rounded), findsOneWidget);
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
}
