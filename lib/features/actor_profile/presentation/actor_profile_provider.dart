import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/tmdb_service.dart';

enum ActorMediaFilter { all, movie, tv }

final actorMediaFilterProvider = StateProvider<ActorMediaFilter>((ref) => ActorMediaFilter.all);

final personDetailsProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, personId) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return await tmdbService.getPersonDetails(personId);
});

final actorFilmographyProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, personId) async {
  final tmdbService = ref.watch(tmdbServiceProvider);

  // Fetch both movies and tv shows featuring this person
  final movies = await tmdbService.discoverMovies(withCast: personId.toString());
  final tvShows = await tmdbService.discoverTvShows(withPeople: personId.toString());

  // Merge the lists
  final combined = <Map<String, dynamic>>[...movies, ...tvShows];

  // Sort by popularity descending
  combined.sort((a, b) {
    final popA = (a['popularity'] as num?)?.toDouble() ?? 0.0;
    final popB = (b['popularity'] as num?)?.toDouble() ?? 0.0;
    return popB.compareTo(popA);
  });

  // Limit to top 20 items
  return combined.take(20).toList();
});
