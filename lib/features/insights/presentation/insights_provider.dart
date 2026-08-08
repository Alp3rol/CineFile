import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/constants/tmdb_genres.dart';
import '../../../core/database/database_provider.dart';
import '../domain/achievement_models.dart';
import 'achievement_catalogue.dart';
import '../domain/insight_buckets.dart';
import '../domain/insights_calculator.dart';
import '../../../core/l10n/l10n_lookup.dart';
import '../../settings/presentation/settings_provider.dart';
import 'widgets/contribution_heatmap_utils.dart';

class InsightsData {
  final int totalWatchCount;
  final int uniqueTitleCount;
  final int totalDurationMinutes;
  final double averageRating;

  /// Genre **ids** and how many watch records carry them, most-watched first.
  /// Ids rather than names so the tally survives a language switch; callers
  /// render them with `genreName(l10n, id)`.
  final List<MapEntry<int, int>> topGenres;
  final List<MapEntry<String, int>> topDirectors;
  final List<MapEntry<String, int>> topActors;
  final Map<int, int> monthlyWatchTrend;

  /// Watches per time-of-day band. Keyed by [TimeOfDayBand] rather than the
  /// band's display name — those keys were Turkish strings, so the widget's
  /// lookup silently missed every bucket once the UI spoke another language.
  final Map<TimeOfDayBand, int> timeOfDayTrend;
  final Map<int, int> dayOfWeekTrend;
  final List<AchievementBadge> achievementBadges;

  // Heatmap & Streaks
  final Map<String, int> dailyWatchCounts;
  final Map<String, int> dailyMovieWatchCounts;
  final Map<String, int> dailyTvWatchCounts;
  final int currentStreak;
  final int longestStreak;

  // Rating Distribution
  final Map<int, int> ratingDistribution;
  final int mostFrequentRating;

  // Seasonal Trends
  /// Watches per season, keyed by [Season] for the same reason as
  /// [timeOfDayTrend].
  final Map<Season, int> seasonalCounts;
  final int goldenWeekday;

  // Tags & Weekly Goal
  final List<MapEntry<String, int>> topTags;
  final int thisWeekWatchCount;

  const InsightsData({
    required this.totalWatchCount,
    required this.uniqueTitleCount,
    required this.totalDurationMinutes,
    required this.averageRating,
    required this.topGenres,
    required this.topDirectors,
    required this.topActors,
    required this.monthlyWatchTrend,
    required this.timeOfDayTrend,
    required this.dayOfWeekTrend,
    required this.achievementBadges,
    required this.dailyWatchCounts,
    required this.dailyMovieWatchCounts,
    required this.dailyTvWatchCounts,
    required this.currentStreak,
    required this.longestStreak,
    required this.ratingDistribution,
    required this.mostFrequentRating,
    required this.seasonalCounts,
    required this.goldenWeekday,
    required this.topTags,
    required this.thisWeekWatchCount,
  });
}

final insightsYearFilterProvider = StateProvider<int?>((ref) => null);
final insightsMediaTypeFilterProvider = StateProvider<String?>((ref) => null);

final insightsProvider = Provider<InsightsData?>((ref) {
  final l10n = lookupL10n(ref.watch(localeProvider));
  final watchRecords = ref.watch(allWatchRecordsProvider).value;
  final settingsMap = ref.watch(allMovieSettingsProvider).value ?? {};
  if (watchRecords == null) return null;

  final selectedYear = ref.watch(insightsYearFilterProvider);
  final selectedMediaType = ref.watch(insightsMediaTypeFilterProvider);

  var filteredWatchRecords = watchRecords;
  if (selectedYear != null) {
    filteredWatchRecords = filteredWatchRecords.where((r) => r.record.watchDate.year == selectedYear).toList();
  }
  if (selectedMediaType != null) {
    final isTv = selectedMediaType == 'tv';
    filteredWatchRecords = filteredWatchRecords.where((r) => r.movie.isTv == isTv).toList();
  }

  final loggedMovieDayKeys = <String>{
    for (final r in filteredWatchRecords)
      '${r.movie.tmdbId}_${r.movie.isTv}_${formatHeatmapDateKey(r.record.watchDate)}',
  };
  final progressOnlyDates = <DateTime>{};
  for (final entry in settingsMap.entries) {
    final progressAt = entry.value.lastEpisodeProgressAt;
    if (progressAt == null) continue;
    final key =
        '${entry.key.tmdbId}_${entry.key.isTv}_${formatHeatmapDateKey(progressAt)}';
    if (!loggedMovieDayKeys.contains(key)) {
      progressOnlyDates.add(
        DateTime(progressAt.year, progressAt.month, progressAt.day),
      );
    }
  }
  if (filteredWatchRecords.isEmpty && progressOnlyDates.isEmpty) return null;

  final records = [
    for (final item in filteredWatchRecords)
      InsightRecord(
        tmdbId: item.movie.tmdbId,
        isTv: item.movie.isTv,
        watchDate: item.record.watchDate,
        rating: item.record.rating,
        episodeCount: item.record.episodeCount,
        watchNumber: item.record.watchNumber,
        runtime: item.movie.runtime ?? 0,
        genreIds: parseGenreIds(item.movie.genreIds),
        director: item.movie.director,
        actors: item.movie.actors,
        tags: item.record.tags,
        releaseYear: item.movie.releaseYear,
        title: item.movie.title,
        overview: item.movie.overview,
        personalNotes: item.setting?.personalNotes,
      ),
  ];
  final metrics = InsightsCalculator.calculate(
    records: records,
    progressOnlyDates: progressOnlyDates,
  );
  final badges = buildAchievementCatalogue(
    list: watchRecords,
    totalWatchCount: metrics.totalWatchCount,
    longestStreak: metrics.longestStreak,
    dailyWatchCounts: metrics.dailyWatchCounts,
    topTags: metrics.topTags,
    l10n: l10n,
  );

  return InsightsData(
    totalWatchCount: metrics.totalWatchCount,
    uniqueTitleCount: metrics.uniqueTitleCount,
    totalDurationMinutes: metrics.totalDurationMinutes,
    averageRating: metrics.averageRating,
    topGenres: metrics.topGenres,
    topDirectors: metrics.topDirectors,
    topActors: metrics.topActors,
    monthlyWatchTrend: metrics.monthlyWatchTrend,
    timeOfDayTrend: metrics.timeOfDayTrend,
    dayOfWeekTrend: metrics.dayOfWeekTrend,
    achievementBadges: badges,
    dailyWatchCounts: metrics.dailyWatchCounts,
    dailyMovieWatchCounts: metrics.dailyMovieWatchCounts,
    dailyTvWatchCounts: metrics.dailyTvWatchCounts,
    currentStreak: metrics.currentStreak,
    longestStreak: metrics.longestStreak,
    ratingDistribution: metrics.ratingDistribution,
    mostFrequentRating: metrics.mostFrequentRating,
    seasonalCounts: metrics.seasonalCounts,
    goldenWeekday: metrics.goldenWeekday,
    topTags: metrics.topTags,
    thisWeekWatchCount: metrics.thisWeekWatchCount,
  );
});
