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

  // Fetch combined credits (both movies and TV shows) featuring this person
  final credits = await tmdbService.getPersonCombinedCredits(personId);

  // Sort by popularity descending
  final sorted = List<Map<String, dynamic>>.from(credits);
  sorted.sort((a, b) {
    final popA = (a['popularity'] as num?)?.toDouble() ?? 0.0;
    final popB = (b['popularity'] as num?)?.toDouble() ?? 0.0;
    return popB.compareTo(popA);
  });

  // Limit to top 20 items
  return sorted.take(20).toList();
});
