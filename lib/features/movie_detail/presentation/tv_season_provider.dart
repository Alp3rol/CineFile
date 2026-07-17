import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/tmdb_service.dart';

// Keeps track of the selected season number for a given TV show ID in the UI.
// Defaults to season 1.
final selectedSeasonProvider = StateProvider.family<int, int>((ref, tvId) => 1);

// Fetches the detailed episodes (still_path, name, overview, air_date)
// for a specific season of a TV show.
final tvSeasonDetailsProvider = FutureProvider.family<Map<String, dynamic>?, ({int tvId, int seasonNumber})>((ref, arg) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return await tmdbService.getTvSeasonDetails(arg.tvId, arg.seasonNumber);
});
