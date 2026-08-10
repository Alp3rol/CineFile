import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n_lookup.dart';
import '../../../core/l10n/genre_names.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../../core/database/database_provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../domain/cine_twin_calculator.dart';
import '../../swipe_discovery/data/swipe_preference_signal.dart';

/// Argument parameter for CineTwin comparison.
class CineTwinParams {
  final String targetUsername;
  final List<Map<String, dynamic>> targetEntries;
  final List<int> targetTasteGenreIds;

  const CineTwinParams({
    required this.targetUsername,
    required this.targetEntries,
    this.targetTasteGenreIds = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CineTwinParams &&
          runtimeType == other.runtimeType &&
          targetUsername == other.targetUsername &&
          targetEntries.length == other.targetEntries.length &&
          _sameIds(targetTasteGenreIds, other.targetTasteGenreIds);

  @override
  int get hashCode => Object.hash(
    targetUsername,
    targetEntries.length,
    Object.hashAll(targetTasteGenreIds),
  );

  static bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Provider that converts local user logs and target user logs into CineTwinResult.
final cineTwinProvider = Provider.family<CineTwinResult?, CineTwinParams>((
  ref,
  params,
) {
  // Recommendation reasons and the fallback labels below are user-facing, and
  // this is a provider — there is no BuildContext to read them from.
  final l10n = lookupL10n(ref.watch(localeProvider));
  final localWatchAsync = ref.watch(allWatchRecordsProvider);
  final authState = ref.watch(authStateProvider);
  final currentUserName = authState.value?.displayName ?? l10n.cineTwinYou;
  final localTasteProfile = buildSwipeTasteProfile(
    ref.watch(swipePreferenceSignalsProvider).value ?? const [],
  );

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
      genres:
          w.movie.genres
              ?.split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
    );
  }).toList();

  // Convert target user's public entries
  final userBLogs = params.targetEntries.map((e) {
    final movieId = ((e['movieId'] ?? e['tmdbId'] ?? 0) as num).toInt();
    final title =
        (e['title'] ?? e['movieTitle'] ?? l10n.graphNodeMovie) as String;
    final isTv = e['isTv'] == true || e['isTv'] == 1;
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

  final localHasTaste =
      userALogs.isNotEmpty || localTasteProfile.genreIds.isNotEmpty;
  final targetHasTaste =
      userBLogs.isNotEmpty || params.targetTasteGenreIds.isNotEmpty;
  if (!localHasTaste || !targetHasTaste) {
    return null;
  }

  return CineTwinCalculator.calculate(
    userALogs: userALogs,
    userBLogs: userBLogs,
    userAName: currentUserName,
    userBName: '@${params.targetUsername}',
    userATasteGenres: localTasteProfile.genreIds
        .map((id) => genreName(l10n, id))
        .toList(growable: false),
    userBTasteGenres: params.targetTasteGenreIds
        .map((id) => genreName(l10n, id))
        .toList(growable: false),
    l10n: l10n,
  );
});
