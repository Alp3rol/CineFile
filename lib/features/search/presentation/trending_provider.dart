import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  List<Map<String, dynamic>> movies;
  List<Map<String, dynamic>> tv;
  var shouldShuffle = false;

  switch (category) {
    case DiscoverCategory.trend:
      shouldShuffle = true;
      if (timeWindow == DiscoverTimeWindow.today) {
        movies = await tmdbService.getTrendingMoviesToday();
        tv = await tmdbService.getTrendingTvShowsToday();
      } else {
        movies = await tmdbService.getTrendingMoviesThisWeek();
        tv = await tmdbService.getTrendingTvShowsThisWeek();
      }
      break;
    case DiscoverCategory.popular:
      movies = await tmdbService.getPopularMovies();
      tv = await tmdbService.getPopularTvShows();
      break;
    case DiscoverCategory.topRated:
      movies = await tmdbService.getTopRatedMovies();
      tv = await tmdbService.getTopRatedTvShows();
      break;
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
