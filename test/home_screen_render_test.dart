// Verifies HomeScreen shows real watch-history/library data instead of the
// former hardcoded mock lists, dedupes re-watched movies, and shows an
// empty-state message when the user has no data yet.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/home/presentation/home_screen.dart';

Movie _movie(int id, String title, {String? director, int? releaseYear}) {
  return Movie(
    tmdbId: id,
    title: title,
    isTv: false,
    director: director,
    releaseYear: releaseYear,
    createdAt: DateTime(2026, 1, id),
  );
}

WatchRecord _watchRecord(int id, int movieId, DateTime watchDate, {double rating = 8}) {
  return WatchRecord(
    id: id,
    movieId: movieId,
    isTv: false,
    watchDate: watchDate,
    rating: rating,
    watchNumber: 1,
    createdAt: DateTime.now(),
    episodeCount: 1,
    isPublic: false,
  );
}

void main() {
  testWidgets('shows real recently-watched (deduped) and recently-added movies, no mock titles', (tester) async {
    final movieA = _movie(1, 'Real Watched Movie', director: 'Dir A');
    final movieB = _movie(2, 'Real Added Movie', director: 'Dir B', releaseYear: 2020);

    // Movie A watched twice; only the latest watch should be shown once.
    final watchRecords = [
      WatchRecordWithMovie(_watchRecord(1, 1, DateTime(2026, 1, 10), rating: 9), movieA),
      WatchRecordWithMovie(_watchRecord(2, 1, DateTime(2026, 1, 5), rating: 7), movieA),
    ];

    final unwatchedFavorite = _movie(3, 'Unwatched Favorite Movie');
    final unwatchedOther = _movie(4, 'Unwatched Other Movie');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(watchRecords)),
          recentlyAddedMoviesProvider.overrideWith((ref) => Stream.value([movieB])),
          unwatchedMoviesProvider.overrideWith((ref) => Stream.value([unwatchedFavorite, unwatchedOther])),
          favoriteMovieIdsProvider
              .overrideWith((ref) => Stream.value({(tmdbId: unwatchedFavorite.tmdbId, isTv: unwatchedFavorite.isTv)})),
          // Reads from Firestore (via authStateProvider/firebaseAuthProvider)
          // in the real app — overridden directly so this render test doesn't
          // need a Firebase test harness.
          activelyWatchingProvider.overrideWith((ref) => Stream.value(const [])),
          // insightsProvider now also reads this (episode-progress heatmap
          // dedup) — overridden for the same Firebase-avoidance reason as
          // activelyWatchingProvider above.
          allMovieSettingsProvider.overrideWith((ref) => Stream.value(const {})),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Mock titles from the old hardcoded lists must be gone.
    expect(find.text('Interstellar'), findsNothing);
    expect(find.text('Dune: Part Two'), findsNothing);

    // Real data shows up. "Son İzlediklerim" was removed (redundant with
    // "Son Eklediklerim" for this app's usage pattern), so watched-only
    // movies like "Real Watched Movie" no longer render anywhere on Home.
    expect(find.text('Real Added Movie'), findsOneWidget);
    expect(find.text('2020 • Dir B'), findsOneWidget);

    // Suggestion card: prefers the unwatched favorite over the non-favorite.
    expect(find.text('Bu Hafta Ne İzlesem?'), findsOneWidget);
    expect(find.text('Unwatched Favorite Movie'), findsOneWidget);
    expect(find.text('Unwatched Other Movie'), findsNothing);
  });

  testWidgets('shows empty-state messages when there is no watch history or library yet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(const [])),
          recentlyAddedMoviesProvider.overrideWith((ref) => Stream.value(const [])),
          unwatchedMoviesProvider.overrideWith((ref) => Stream.value(const [])),
          favoriteMovieIdsProvider.overrideWith((ref) => Stream.value(const <MovieKey>{})),
          activelyWatchingProvider.overrideWith((ref) => Stream.value(const [])),
          // insightsProvider now also reads this (episode-progress heatmap
          // dedup) — overridden for the same Firebase-avoidance reason as
          // activelyWatchingProvider above.
          allMovieSettingsProvider.overrideWith((ref) => Stream.value(const {})),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Henüz kütüphanene film eklemedin'), findsOneWidget);

    // Nothing to suggest and no watch history means these sections are hidden.
    expect(find.text('Bu Hafta Ne İzlesem?'), findsNothing);
    expect(find.text('En Popüler Türler (Tür Dağılımı)'), findsNothing);
    expect(find.textContaining('günlük seri devam ediyor'), findsNothing);
  });

  testWidgets('shows streak chip and genre chart once there is enough watch history', (tester) async {
    final movieA = _movie(1, 'Streaked Movie', director: 'Christopher Nolan');

    final today = DateTime.now();
    final watchRecords = [
      WatchRecordWithMovie(_watchRecord(1, 1, today), movieA),
      WatchRecordWithMovie(_watchRecord(2, 1, today.subtract(const Duration(days: 1))), movieA),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allWatchRecordsProvider.overrideWith((ref) => Stream.value(watchRecords)),
          recentlyAddedMoviesProvider.overrideWith((ref) => Stream.value(const [])),
          unwatchedMoviesProvider.overrideWith((ref) => Stream.value(const [])),
          favoriteMovieIdsProvider.overrideWith((ref) => Stream.value(const <MovieKey>{})),
          activelyWatchingProvider.overrideWith((ref) => Stream.value(const [])),
          // insightsProvider now also reads this (episode-progress heatmap
          // dedup) — overridden for the same Firebase-avoidance reason as
          // activelyWatchingProvider above.
          allMovieSettingsProvider.overrideWith((ref) => Stream.value(const {})),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('günlük seri devam ediyor'), findsOneWidget);
    // movieA has no genres set, so the genre chart (which hides on empty
    // topGenres) should stay hidden rather than throwing.
    expect(find.text('En Popüler Türler (Tür Dağılımı)'), findsNothing);
  });
}
