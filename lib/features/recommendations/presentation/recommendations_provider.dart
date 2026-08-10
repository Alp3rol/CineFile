import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tmdb_genres.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/l10n/genre_names.dart';
import '../../../core/l10n/l10n_lookup.dart';
import '../../../core/network/tmdb_service.dart';
import '../../../core/observability/error_reporting.dart';
import '../../insights/presentation/insights_provider.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/recommendation_model.dart';
import '../../swipe_discovery/data/swipe_preference_signal.dart';

List<({int genreId, bool isTv})> recommendationGenreTargets(
  Iterable<int> preferredGenreIds,
) => [
  for (final genreId in preferredGenreIds) ...[
    if (kMovieGenreIds.contains(genreId)) (genreId: genreId, isTv: false),
    if (kTvGenreIds.contains(genreId)) (genreId: genreId, isTv: true),
  ],
];

final recommendationsProvider = FutureProvider<List<RecommendationItem>>((
  ref,
) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  // Reasons are built here rather than in a widget, so the genre name is
  // resolved through the context-free lookup against the user's chosen
  // language.
  final l10n = lookupL10n(ref.watch(localeProvider));
  final watchRecords = ref.watch(allWatchRecordsProvider).value ?? [];
  final movieSettings = ref.watch(allMovieSettingsProvider).value ?? {};
  final insights = ref.watch(insightsProvider);
  final swipeSignals =
      ref.watch(swipePreferenceSignalsProvider).value ?? const [];

  // A right swipe is a stronger signal than a single left swipe. This lets
  // repeated passes gently lower a genre without one poster choice banning an
  // entire category from future recommendations.
  final swipeGenreIds = rankedSwipeGenreIds(swipeSignals);

  // Set of all tmdbIds already in library
  final libraryKeys = <String>{};
  for (final r in watchRecords) {
    libraryKeys.add('${r.movie.tmdbId}_${r.movie.isTv}');
  }
  for (final entry in movieSettings.entries) {
    final setting = entry.value;
    final hasUserData =
        setting.isFavorite ||
        setting.isReWatchList ||
        setting.isActivelyWatching ||
        setting.personalRanking != null ||
        setting.personalNotes != null ||
        setting.personalTags != null ||
        setting.lastWatchedEpisode != null;
    if (hasUserData) {
      libraryKeys.add('${entry.key.tmdbId}_${entry.key.isTv}');
    }
  }
  for (final signal in swipeSignals) {
    final key = signal.key;
    if (key != null) libraryKeys.add('${key.tmdbId}_${key.isTv}');
  }

  final uniqueRecordsCount = watchRecords
      .map((r) => '${r.movie.tmdbId}_${r.movie.isTv}')
      .toSet()
      .length;

  // Fallback for new/inactive users
  if ((uniqueRecordsCount < 5 || insights == null) && swipeGenreIds.isEmpty) {
    try {
      final popularMovies = await tmdbService.getPopularMovies();
      final popularTv = await tmdbService.getPopularTvShows();

      final list = <RecommendationItem>[];

      for (final m in popularMovies) {
        if (!libraryKeys.contains('${m['id']}_false')) {
          list.add(
            RecommendationItem.fromJson(
              m,
              reason: l10n.recommendationReasonPopular,
              fallbackTitle: l10n.titleUnknown,
              isTvOverride: false,
            ),
          );
        }
      }
      for (final tv in popularTv) {
        if (!libraryKeys.contains('${tv['id']}_true')) {
          list.add(
            RecommendationItem.fromJson(
              tv,
              reason: l10n.recommendationReasonPopular,
              fallbackTitle: l10n.titleUnknown,
              isTvOverride: true,
            ),
          );
        }
      }

      list.shuffle();
      return list.take(12).toList();
    } catch (error, stackTrace) {
      reportError(error, stackTrace, where: 'recommendations.popularFallback');
      return [];
    }
  }

  // Large enough library -> Personal recommendation logic
  final recommendationsMap = <String, RecommendationItem>{};

  // 1. Discover by top genres
  final preferredGenreIds = rankedBlendedGenreIds(
    watchedGenres: insights?.topGenres ?? const <MapEntry<int, int>>[],
    swipeSignals: swipeSignals,
  );
  if (preferredGenreIds.isNotEmpty) {
    // Query each learned genre independently. Combining the strongest genres
    // into one request narrows the pool and labels every result with only the
    // first genre. Separate requests preserve variety and honest reasons.
    await Future.wait(
      recommendationGenreTargets(preferredGenreIds).map((target) async {
        final genreLabel = genreName(l10n, target.genreId);
        try {
          final results = target.isTv
              ? await tmdbService.discoverTvShows(
                  withGenres: '${target.genreId}',
                )
              : await tmdbService.discoverMovies(
                  withGenres: '${target.genreId}',
                );
          for (final item in results) {
            final id = item['id'] as int;
            final key = '${id}_${target.isTv}';
            if (!libraryKeys.contains(key)) {
              recommendationsMap.putIfAbsent(
                key,
                () => RecommendationItem.fromJson(
                  item,
                  reason: l10n.recommendationReasonGenre(genreLabel),
                  fallbackTitle: l10n.titleUnknown,
                  isTvOverride: target.isTv,
                ),
              );
            }
          }
        } catch (error, stackTrace) {
          reportError(
            error,
            stackTrace,
            where: 'recommendations.byGenre.${target.genreId}.${target.isTv}',
          );
        }
      }),
    );
  }

  // 2. Discover by top director
  if (insights != null && insights.topDirectors.isNotEmpty) {
    final topDirector = insights.topDirectors.first.key;
    // 'Bilinmiyor' is not something the stats produce — it leaks in from rows
    // cached before this guard existed, where movie_detail_provider.dart
    // fabricated that placeholder as a crew name rather than leaving the
    // director null. Kept as a legacy-data defence; the write path that
    // creates it is fixed with the movie-detail slice.
    if (topDirector != 'Bilinmiyor' && topDirector.isNotEmpty) {
      try {
        final directorId = await tmdbService.searchPersonId(topDirector);
        if (directorId != null) {
          final directorMovies = await tmdbService.discoverMovies(
            withCrew: directorId.toString(),
          );
          for (final m in directorMovies) {
            final id = m['id'] as int;
            if (!libraryKeys.contains('${id}_false')) {
              recommendationsMap['${id}_false'] = RecommendationItem.fromJson(
                m,
                reason: l10n.recommendationReasonDirector(topDirector),
                fallbackTitle: l10n.titleUnknown,
                isTvOverride: false,
              );
            }
          }
        }
      } catch (error, stackTrace) {
        reportError(error, stackTrace, where: 'recommendations.byDirector');
      }
    }
  }

  // 3. Discover by top actor
  if (insights != null && insights.topActors.isNotEmpty) {
    final topActor = insights.topActors.first.key;
    if (topActor != 'Bilinmiyor' && topActor.isNotEmpty) {
      try {
        final actorId = await tmdbService.searchPersonId(topActor);
        if (actorId != null) {
          final credits = await tmdbService.getPersonCombinedCredits(actorId);
          for (final item in credits) {
            final id = item['id'] as int;
            final isTv = item['media_type'] == 'tv';
            if (!libraryKeys.contains('${id}_$isTv')) {
              recommendationsMap['${id}_$isTv'] = RecommendationItem.fromJson(
                item,
                reason: l10n.recommendationReasonActor(topActor),
                fallbackTitle: l10n.titleUnknown,
                isTvOverride: isTv,
              );
            }
          }
        }
      } catch (error, stackTrace) {
        reportError(error, stackTrace, where: 'recommendations.byActor');
      }
    }
  }

  final finalRecommendations = recommendationsMap.values.toList();
  finalRecommendations.shuffle(); // Shuffle for variety
  return finalRecommendations.take(12).toList();
});
