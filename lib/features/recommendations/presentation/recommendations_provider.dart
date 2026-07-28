import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tmdb_genres.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/l10n/genre_names.dart';
import '../../../core/l10n/l10n_lookup.dart';
import '../../../core/network/tmdb_service.dart';
import '../../insights/presentation/insights_provider.dart';
import '../../settings/presentation/settings_provider.dart';
import '../data/recommendation_model.dart';

final recommendationsProvider = FutureProvider<List<RecommendationItem>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  // Reasons are built here rather than in a widget, so the genre name is
  // resolved through the context-free lookup against the user's chosen
  // language.
  final l10n = lookupL10n(ref.watch(localeProvider));
  final watchRecords = ref.watch(allWatchRecordsProvider).value ?? [];
  final movieSettings = ref.watch(allMovieSettingsProvider).value ?? {};
  final insights = ref.watch(insightsProvider);

  // Set of all tmdbIds already in library
  final libraryKeys = <String>{};
  for (final r in watchRecords) {
    libraryKeys.add('${r.movie.tmdbId}_${r.movie.isTv}');
  }
  for (final key in movieSettings.keys) {
    libraryKeys.add('${key.tmdbId}_${key.isTv}');
  }

  final uniqueRecordsCount = watchRecords.map((r) => '${r.movie.tmdbId}_${r.movie.isTv}').toSet().length;

  // Fallback for new/inactive users
  if (uniqueRecordsCount < 5 || insights == null) {
    try {
      final popularMovies = await tmdbService.getPopularMovies();
      final popularTv = await tmdbService.getPopularTvShows();

      final list = <RecommendationItem>[];

      for (final m in popularMovies) {
        if (!libraryKeys.contains('${m['id']}_false')) {
          list.add(RecommendationItem.fromJson(m, reason: l10n.recommendationReasonPopular, fallbackTitle: l10n.titleUnknown, isTvOverride: false));
        }
      }
      for (final tv in popularTv) {
        if (!libraryKeys.contains('${tv['id']}_true')) {
          list.add(RecommendationItem.fromJson(tv, reason: l10n.recommendationReasonPopular, fallbackTitle: l10n.titleUnknown, isTvOverride: true));
        }
      }

      list.shuffle();
      return list.take(12).toList();
    } catch (_) {
      return [];
    }
  }

  // Large enough library -> Personal recommendation logic
  final Map<String, RecommendationItem> recommendationsMap = {};

  // 1. Discover by top genres
  if (insights.topGenres.isNotEmpty) {
    // Ids come straight from the stats now — no name→id table to keep in sync.
    // Each id is only valid against the endpoint whose vocabulary contains it,
    // so a TV-only genre isn't sent to discover/movie and vice versa.
    final top2Genres = insights.topGenres.take(2).map((e) => e.key).toList();
    final topGenreLabel = genreName(l10n, top2Genres.first);
    final movieGenreIds = top2Genres.where(kMovieGenreIds.contains).join(',');
    final tvGenreIds = top2Genres.where(kTvGenreIds.contains).join(',');

    try {
      if (movieGenreIds.isNotEmpty) {
        final genreMovies = await tmdbService.discoverMovies(withGenres: movieGenreIds);
        for (final m in genreMovies) {
          final id = m['id'] as int;
          if (!libraryKeys.contains('${id}_false')) {
            recommendationsMap['${id}_false'] = RecommendationItem.fromJson(
              m,
              reason: l10n.recommendationReasonGenre(topGenreLabel),
              fallbackTitle: l10n.titleUnknown,
              isTvOverride: false,
            );
          }
        }
      }

      if (tvGenreIds.isNotEmpty) {
        final genreTv = await tmdbService.discoverTvShows(withGenres: tvGenreIds);
        for (final tv in genreTv) {
          final id = tv['id'] as int;
          if (!libraryKeys.contains('${id}_true')) {
            recommendationsMap['${id}_true'] = RecommendationItem.fromJson(
              tv,
              reason: l10n.recommendationReasonGenre(topGenreLabel),
              fallbackTitle: l10n.titleUnknown,
              isTvOverride: true,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Genre-based recommendations failed: $e');
    }
  }

  // 2. Discover by top director
  if (insights.topDirectors.isNotEmpty) {
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
          final directorMovies = await tmdbService.discoverMovies(withCrew: directorId.toString());
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
      } catch (e) {
        debugPrint('Director-based recommendations failed: $e');
      }
    }
  }

  // 3. Discover by top actor
  if (insights.topActors.isNotEmpty) {
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
      } catch (e) {
        debugPrint('Actor-based recommendations failed: $e');
      }
    }
  }

  final finalRecommendations = recommendationsMap.values.toList();
  finalRecommendations.shuffle(); // Shuffle for variety
  return finalRecommendations.take(12).toList();
});
