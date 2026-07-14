import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/tmdb_service.dart';
import '../../insights/presentation/insights_provider.dart';
import '../data/recommendation_model.dart';

const Map<String, int> _tmdbMovieGenreMap = {
  'Aksiyon': 28,
  'Macera': 12,
  'Animasyon': 16,
  'Komedi': 35,
  'Suç': 80,
  'Belgesel': 99,
  'Dram': 18,
  'Aile': 10751,
  'Fantastik': 14,
  'Tarih': 36,
  'Korku': 27,
  'Müzik': 10402,
  'Gizem': 9648,
  'Romantik': 10749,
  'Bilim Kurgu': 878,
  'Gerilim': 53,
  'Savaş': 10752,
  'Vahşi Batı': 37
};

const Map<String, int> _tmdbTvGenreMap = {
  'Aksiyon & Macera': 10759,
  'Animasyon': 16,
  'Komedi': 35,
  'Suç': 80,
  'Belgesel': 99,
  'Dram': 18,
  'Aile': 10751,
  'Çocuk': 10762,
  'Gizem': 9648,
  'Haberler': 10763,
  'Realite': 10764,
  'Bilim Kurgu & Fantazi': 10765,
  'Pembe Dizi': 10766,
  'Talk Show': 10767,
  'Savaş & Politika': 10768,
  'Vahşi Batı': 37
};

final recommendationsProvider = FutureProvider<List<RecommendationItem>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
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
          list.add(RecommendationItem.fromJson(m, reason: 'Toplulukta Popüler', isTvOverride: false));
        }
      }
      for (final tv in popularTv) {
        if (!libraryKeys.contains('${tv['id']}_true')) {
          list.add(RecommendationItem.fromJson(tv, reason: 'Toplulukta Popüler', isTvOverride: true));
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
    final top2Genres = insights.topGenres.take(2).map((e) => e.key).toList();
    final movieGenreIds = top2Genres
        .map((g) => _tmdbMovieGenreMap[g])
        .where((id) => id != null)
        .join(',');
    final tvGenreIds = top2Genres
        .map((g) => _tmdbTvGenreMap[g])
        .where((id) => id != null)
        .join(',');

    try {
      if (movieGenreIds.isNotEmpty) {
        final genreMovies = await tmdbService.discoverMovies(withGenres: movieGenreIds);
        for (final m in genreMovies) {
          final id = m['id'] as int;
          if (!libraryKeys.contains('${id}_false')) {
            recommendationsMap['${id}_false'] = RecommendationItem.fromJson(
              m,
              reason: '${top2Genres.first} Sevenlere',
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
              reason: '${top2Genres.first} Sevenlere',
              isTvOverride: true,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Tür bazlı öneri getirilemedi: $e');
    }
  }

  // 2. Discover by top director
  if (insights.topDirectors.isNotEmpty) {
    final topDirector = insights.topDirectors.first.key;
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
                reason: '$topDirector Yönettiği İçin',
                isTvOverride: false,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Yönetmen bazlı öneri getirilemedi: $e');
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
                reason: '$topActor Rol Alıyor',
                isTvOverride: isTv,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Oyuncu bazlı öneri getirilemedi: $e');
      }
    }
  }

  final finalRecommendations = recommendationsMap.values.toList();
  finalRecommendations.shuffle(); // Shuffle for variety
  return finalRecommendations.take(12).toList();
});
