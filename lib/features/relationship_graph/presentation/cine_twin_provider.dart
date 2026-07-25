import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../domain/cine_twin_calculator.dart';

/// Argument parameter for CineTwin comparison.
class CineTwinParams {
  final String targetUsername;
  final List<Map<String, dynamic>> targetEntries;

  const CineTwinParams({
    required this.targetUsername,
    required this.targetEntries,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CineTwinParams &&
          runtimeType == other.runtimeType &&
          targetUsername == other.targetUsername &&
          targetEntries.length == other.targetEntries.length;

  @override
  int get hashCode => targetUsername.hashCode ^ targetEntries.length.hashCode;
}

/// Provider that converts local user logs and target user logs into CineTwinResult.
final cineTwinProvider = Provider.family<CineTwinResult?, CineTwinParams>((ref, params) {
  final localWatchAsync = ref.watch(allWatchRecordsProvider);
  final authState = ref.watch(authStateProvider);
  final currentUserName = authState.value?.displayName ?? 'Sen';

  final localRecords = localWatchAsync.value ?? [];

  // Convert current user's local records
  final userALogs = localRecords.map((w) {
    return CineTwinUserRecord(
      tmdbId: w.movie.tmdbId,
      title: w.movie.title,
      isTv: w.movie.isTv,
      posterPath: w.movie.posterPath,
      rating: w.record.rating,
      director: w.movie.director,
      genres: w.movie.genres?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [],
    );
  }).toList();

  // Convert target user's public entries
  final userBLogs = params.targetEntries.map((e) {
    final movieId = (e['movieId'] ?? e['tmdbId'] ?? 0) as int;
    final title = (e['title'] ?? e['movieTitle'] ?? 'Film') as String;
    final isTv = (e['isTv'] ?? false) as bool;
    final posterPath = e['moviePosterPath'] as String?;
    final rating = (e['rating'] as num?)?.toDouble();
    final director = e['director'] as String?;
    final rawGenres = e['genres'];
    List<String> genresList = [];
    if (rawGenres is List) {
      genresList = rawGenres.map((g) => g.toString()).toList();
    } else if (rawGenres is String) {
      genresList = rawGenres.split(',').map((g) => g.trim()).toList();
    }

    return CineTwinUserRecord(
      tmdbId: movieId,
      title: title,
      isTv: isTv,
      posterPath: posterPath,
      rating: rating,
      director: director,
      genres: genresList,
    );
  }).toList();

  if (userALogs.isEmpty && userBLogs.isEmpty) {
    return null;
  }

  return CineTwinCalculator.calculate(
    userALogs: userALogs,
    userBLogs: userBLogs,
    userAName: currentUserName,
    userBName: '@${params.targetUsername}',
  );
});
