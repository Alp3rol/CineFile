import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/network/tmdb_service.dart';

enum DiscoverCategory { trend, popular, topRated }

enum DiscoverTimeWindow { week, today }

enum DiscoverMediaFilter { all, movie, tv }

final discoverCategoryProvider = StateProvider<DiscoverCategory>((ref) => DiscoverCategory.trend);
final discoverTimeWindowProvider = StateProvider<DiscoverTimeWindow>((ref) => DiscoverTimeWindow.week);
final discoverMediaFilterProvider = StateProvider<DiscoverMediaFilter>((ref) => DiscoverMediaFilter.all);

final trendingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  final category = ref.watch(discoverCategoryProvider);
  final timeWindow = ref.watch(discoverTimeWindowProvider);

  List<Map<String, dynamic>> movies = const [];
  List<Map<String, dynamic>> tv = const [];
  var shouldShuffle = false;

  try {
    switch (category) {
      case DiscoverCategory.trend:
        shouldShuffle = true;
        if (timeWindow == DiscoverTimeWindow.today) {
          final results = await Future.wait([
            tmdbService.getTrendingMoviesToday().catchError((_) => <Map<String, dynamic>>[]),
            tmdbService.getTrendingTvShowsToday().catchError((_) => <Map<String, dynamic>>[]),
          ]);
          movies = results[0];
          tv = results[1];
        } else {
          final results = await Future.wait([
            tmdbService.getTrendingMoviesThisWeek().catchError((_) => <Map<String, dynamic>>[]),
            tmdbService.getTrendingTvShowsThisWeek().catchError((_) => <Map<String, dynamic>>[]),
          ]);
          movies = results[0];
          tv = results[1];
        }
        break;
      case DiscoverCategory.popular:
        final results = await Future.wait([
          tmdbService.getPopularMovies().catchError((_) => <Map<String, dynamic>>[]),
          tmdbService.getPopularTvShows().catchError((_) => <Map<String, dynamic>>[]),
        ]);
        movies = results[0];
        tv = results[1];
        break;
      case DiscoverCategory.topRated:
        final results = await Future.wait([
          tmdbService.getTopRatedMovies().catchError((_) => <Map<String, dynamic>>[]),
          tmdbService.getTopRatedTvShows().catchError((_) => <Map<String, dynamic>>[]),
        ]);
        movies = results[0];
        tv = results[1];
        break;
    }
  } catch (_) {
    // Graceful fallback below
  }

  if (movies.isEmpty && tv.isEmpty) {
    return tmdbService.mockMovies;
  }

  if (shouldShuffle) {
    final combined = [...movies, ...tv]..shuffle();
    return combined.take(20).toList();
  }

  // Popüler/En Çok Oy Alan: TMDb sıralamasını koru, film/dizi round-robin iç içe geçir.
  final interleaved = <Map<String, dynamic>>[];
  final maxLen = movies.length > tv.length ? movies.length : tv.length;
  for (var i = 0; i < maxLen; i++) {
    if (i < movies.length) interleaved.add(movies[i]);
    if (i < tv.length) interleaved.add(tv[i]);
  }
  return interleaved.take(20).toList();
});
