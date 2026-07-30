import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tmdb_genres.dart';
import '../../../core/database/database_provider.dart';
import '../domain/achievement_models.dart';
import '../domain/insight_buckets.dart';
import '../../../core/l10n/l10n_lookup.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/settings_provider.dart';
import 'widgets/contribution_heatmap_utils.dart';

// Legacy class kept for backward compatibility
class BadgeState {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0

  const BadgeState({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
  });

  factory BadgeState.fromAchievement(AchievementBadge b) {
    return BadgeState(
      id: b.id,
      title: b.isUnlocked ? b.currentTierTitle : b.title,
      description: b.description,
      icon: b.icon,
      isUnlocked: b.isUnlocked,
      progress: b.progress,
    );
  }
}

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
  final List<BadgeState> badges;
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
    required this.badges,
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

class TierStep {
  final int target;
  final String title;
  final String description;

  const TierStep({
    required this.target,
    required this.title,
    required this.description,
  });
}

final insightsProvider = Provider<InsightsData?>((ref) {
  // Badge titles and descriptions are assembled here, not in a widget, so the
  // language has to be resolved without a BuildContext.
  final l10n = lookupL10n(ref.watch(localeProvider));
  final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
  final list = watchRecordsAsync.value;
  final settingsMap = ref.watch(allMovieSettingsProvider).value ?? {};
  if (list == null) return null;

  final loggedMovieDayKeys = <String>{
    for (final r in list) '${r.movie.tmdbId}_${r.movie.isTv}_${formatHeatmapDateKey(r.record.watchDate)}',
  };
  final progressOnlyDates = <DateTime>{};
  for (final entry in settingsMap.entries) {
    final progressAt = entry.value.lastEpisodeProgressAt;
    if (progressAt == null) continue;
    final key = '${entry.key.tmdbId}_${entry.key.isTv}_${formatHeatmapDateKey(progressAt)}';
    if (loggedMovieDayKeys.contains(key)) continue;
    progressOnlyDates.add(DateTime(progressAt.year, progressAt.month, progressAt.day));
  }

  if (list.isEmpty && progressOnlyDates.isEmpty) return null;

  final totalWatchCount = list.length;
  final uniqueTitleCount = list.map((r) => (r.movie.tmdbId, r.movie.isTv)).toSet().length;

  int totalDurationMinutes = 0;
  for (final r in list) {
    totalDurationMinutes += (r.movie.runtime ?? 0) * r.record.episodeCount;
  }

  double totalRating = 0;
  int ratingCount = 0;
  for (final r in list) {
    totalRating += r.record.rating;
    ratingCount++;
  }
  final averageRating = ratingCount > 0 ? (totalRating / ratingCount) : 0.0;

  final topGenres = _countGenreIds(list);
  final topDirectors = _countCommaSeparatedField(list, (r) => r.movie.director);
  final topActors = _countCommaSeparatedField(list, (r) => r.movie.actors);

  final currentYear = DateTime.now().year;
  final monthlyWatchTrend = <int, int>{};
  for (int i = 1; i <= 12; i++) {
    monthlyWatchTrend[i] = 0;
  }
  for (final r in list) {
    if (r.record.watchDate.year == currentYear) {
      final month = r.record.watchDate.month;
      monthlyWatchTrend[month] = (monthlyWatchTrend[month] ?? 0) + 1;
    }
  }

  final timeOfDayTrend = {for (final band in TimeOfDayBand.values) band: 0};
  for (final r in list) {
    final band = TimeOfDayBand.forHour(r.record.watchDate.hour);
    timeOfDayTrend[band] = (timeOfDayTrend[band] ?? 0) + 1;
  }

  final dayOfWeekTrend = <int, int>{};
  for (int i = 1; i <= 7; i++) {
    dayOfWeekTrend[i] = 0;
  }
  for (final r in list) {
    final weekday = r.record.watchDate.weekday;
    dayOfWeekTrend[weekday] = (dayOfWeekTrend[weekday] ?? 0) + 1;
  }

  final dailyWatchCounts = <String, int>{};
  final dailyMovieWatchCounts = <String, int>{};
  final dailyTvWatchCounts = <String, int>{};

  for (final r in list) {
    final date = r.record.watchDate;
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final increment = r.movie.isTv ? r.record.episodeCount : 1;
    dailyWatchCounts[dateKey] = (dailyWatchCounts[dateKey] ?? 0) + increment;

    if (r.movie.isTv) {
      dailyTvWatchCounts[dateKey] = (dailyTvWatchCounts[dateKey] ?? 0) + increment;
    } else {
      dailyMovieWatchCounts[dateKey] = (dailyMovieWatchCounts[dateKey] ?? 0) + increment;
    }
  }

  for (final date in progressOnlyDates) {
    final dateKey = formatHeatmapDateKey(date);
    dailyWatchCounts[dateKey] = (dailyWatchCounts[dateKey] ?? 0) + 1;
  }

  // Calculate Streaks
  final uniqueDates = <DateTime>{
    for (final r in list) DateTime(r.record.watchDate.year, r.record.watchDate.month, r.record.watchDate.day),
    ...progressOnlyDates,
  }.toList()
    ..sort();

  int currentStreak = 0;
  int longestStreak = 0;

  if (uniqueDates.isNotEmpty) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int tempLongest = 1;
    int currentRun = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
      if (diff == 1) {
        currentRun++;
      } else if (diff > 1) {
        if (currentRun > tempLongest) {
          tempLongest = currentRun;
        }
        currentRun = 1;
      }
    }
    longestStreak = currentRun > tempLongest ? currentRun : tempLongest;

    // Membership is checked once per day of the streak, so it goes through a
    // Set. `uniqueDates` is a List (it has to be sorted for the longest-run
    // scan above), and List.contains is a linear scan — walking a 400-day
    // streak over a 2000-entry list meant 800k comparisons on every rebuild of
    // this provider, which runs on every watch-record change.
    final dateSet = uniqueDates.toSet();
    final streakStart = dateSet.contains(today)
        ? today
        : (dateSet.contains(yesterday) ? yesterday : null);

    if (streakStart != null) {
      var checkDate = streakStart;
      while (dateSet.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }
  }

  final ratingDistribution = <int, int>{};
  for (int i = 1; i <= 10; i++) {
    ratingDistribution[i] = 0;
  }
  for (final r in list) {
    final ratingInt = r.record.rating.round().clamp(1, 10);
    ratingDistribution[ratingInt] = (ratingDistribution[ratingInt] ?? 0) + 1;
  }

  int mostFrequentRating = 8;
  int maxFreq = -1;
  for (final entry in ratingDistribution.entries) {
    if (entry.value > maxFreq) {
      maxFreq = entry.value;
      mostFrequentRating = entry.key;
    }
  }

  final seasonalCounts = {for (final season in Season.values) season: 0};
  for (final r in list) {
    final season = Season.forMonth(r.record.watchDate.month);
    seasonalCounts[season] = seasonalCounts[season]! + 1;
  }

  int goldenWeekday = 7;
  int maxDayCount = -1;
  for (final entry in dayOfWeekTrend.entries) {
    if (entry.value > maxDayCount) {
      maxDayCount = entry.value;
      goldenWeekday = entry.key;
    }
  }

  // WatchRecords.tags — the "#sinema, #gece" field the user fills in on each
  // diary entry — not UserMovieSettings.personalTags, which no screen ever
  // writes a value into (it only gets copied forward by settings merges), so
  // reading it made "En Çok Kullanılan Etiketler" permanently empty.
  final topTags = _countCommaSeparatedField(list, (r) => r.record.tags);

  final today = DateTime.now();
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final startOfMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final thisWeekWatchCount = list.where((r) => r.record.watchDate.isAfter(startOfMonday) || r.record.watchDate.isAtSameMomentAs(startOfMonday)).length;

  // Compute 28 Expanded Tiered Achievement Badges Series
  final achievementBadges = _calculateAllTieredAchievements(
    list: list,
    totalWatchCount: totalWatchCount,
    longestStreak: longestStreak,
    dailyWatchCounts: dailyWatchCounts,
    topTags: topTags,
    l10n: l10n,
  );

  final badges = achievementBadges.map((b) => BadgeState.fromAchievement(b)).toList();

  return InsightsData(
    totalWatchCount: totalWatchCount,
    uniqueTitleCount: uniqueTitleCount,
    totalDurationMinutes: totalDurationMinutes,
    averageRating: averageRating,
    topGenres: topGenres,
    topDirectors: topDirectors,
    topActors: topActors,
    monthlyWatchTrend: monthlyWatchTrend,
    timeOfDayTrend: timeOfDayTrend,
    dayOfWeekTrend: dayOfWeekTrend,
    badges: badges,
    achievementBadges: achievementBadges,
    dailyWatchCounts: dailyWatchCounts,
    dailyMovieWatchCounts: dailyMovieWatchCounts,
    dailyTvWatchCounts: dailyTvWatchCounts,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    ratingDistribution: ratingDistribution,
    mostFrequentRating: mostFrequentRating,
    seasonalCounts: seasonalCounts,
    goldenWeekday: goldenWeekday,
    topTags: topTags,
    thisWeekWatchCount: thisWeekWatchCount,
  );
});

List<MapEntry<String, int>> _countCommaSeparatedField(
  List<WatchRecordWithMovie> list,
  String? Function(WatchRecordWithMovie) fieldSelector,
) {
  final counts = <String, int>{};
  for (final r in list) {
    final fieldStr = fieldSelector(r);
    if (fieldStr != null && fieldStr.isNotEmpty) {
      final values = fieldStr.split(',').map((v) => v.trim());
      for (final v in values) {
        if (v.isNotEmpty) {
          counts[v] = (counts[v] ?? 0) + 1;
        }
      }
    }
  }
  return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
}

/// Tiered Badge Builder Helper
AchievementBadge _buildTieredBadge({
  required String id,
  required String defaultTitle,
  required String icon,
  required AchievementCategory category,
  required int currentValue,
  required List<TierStep> steps,
}) {
  int currentTier = 0;
  String currentTitle = defaultTitle;
  String currentDesc = steps.first.description;
  int currentTarget = steps.first.target;
  String? nextTitle = steps.first.title;
  int nextTarget = steps.first.target;

  for (int i = 0; i < steps.length; i++) {
    final step = steps[i];
    if (currentValue >= step.target) {
      currentTier = i + 1;
      currentTitle = step.title;
      currentDesc = step.description;
      currentTarget = step.target;
      if (i + 1 < steps.length) {
        nextTitle = steps[i + 1].title;
        nextTarget = steps[i + 1].target;
      } else {
        nextTitle = null; // Max tier reached!
        nextTarget = step.target;
      }
    } else {
      if (currentTier == 0) {
        nextTitle = step.title;
        nextTarget = step.target;
      }
      break;
    }
  }

  final isUnlocked = currentTier > 0;

  // Calculate progress towards next tier
  double progress = 0.0;
  if (currentTier == 0) {
    progress = (currentValue / nextTarget).clamp(0.0, 1.0);
  } else if (currentTier >= steps.length) {
    progress = 1.0; // Completed max tier!
  } else {
    final prevTarget = currentTarget;
    final range = nextTarget - prevTarget;
    if (range > 0) {
      progress = ((currentValue - prevTarget) / range).clamp(0.0, 1.0);
    } else {
      progress = 1.0;
    }
  }

  return AchievementBadge(
    id: id,
    title: defaultTitle,
    description: currentDesc,
    icon: icon,
    category: category,
    isUnlocked: isUnlocked,
    progress: progress,
    currentValue: currentValue,
    targetValue: currentTarget,
    currentTier: currentTier,
    maxTier: steps.length,
    currentTierTitle: currentTitle,
    nextTierTitle: nextTitle,
    nextTargetValue: nextTarget,
  );
}

/// Calculates all 28 expanded multi-tier series badges.
List<AchievementBadge> _calculateAllTieredAchievements({
  required List<WatchRecordWithMovie> list,
  required int totalWatchCount,
  required int longestStreak,
  required Map<String, int> dailyWatchCounts,
  required List<MapEntry<String, int>> topTags,
  required AppLocalizations l10n,
}) {
  final badges = <AchievementBadge>[];

  // Tier titles and descriptions are localized here rather than in a widget:
  // the badge list is assembled in this provider, and AchievementBadge carries
  // the finished strings. The `const` on each step list is therefore gone —
  // that is the price of the text no longer being baked in.

  // --- 1. HACİM VE MARATON (MILSTONES) ---
  badges.add(_buildTieredBadge(
    id: 'first_watch_series',
    defaultTitle: l10n.badgeFirstWatchTitle,
    icon: '🥇',
    category: AchievementCategory.milestone,
    currentValue: totalWatchCount,
    steps: [
      TierStep(target: 1, title: l10n.badgeFirstWatchT1, description: l10n.badgeDescLogEntries(1)),
      TierStep(target: 5, title: l10n.badgeFirstWatchT2, description: l10n.badgeDescLogEntries(5)),
      TierStep(target: 15, title: l10n.badgeFirstWatchT3, description: l10n.badgeDescLogEntries(15)),
    ],
  ));

  badges.add(_buildTieredBadge(
    id: 'sinefil_series',
    defaultTitle: l10n.badgeSinefilTitle,
    icon: '🍿',
    category: AchievementCategory.milestone,
    currentValue: totalWatchCount,
    steps: [
      TierStep(target: 10, title: l10n.badgeSinefilT1, description: l10n.badgeDescWatchAtLeast(10)),
      TierStep(target: 50, title: l10n.badgeSinefilT2, description: l10n.badgeDescWatchAtLeast(50)),
      TierStep(target: 100, title: l10n.badgeSinefilT3, description: l10n.badgeDescWatchAtLeast(100)),
      TierStep(target: 250, title: l10n.badgeSinefilT4, description: l10n.badgeDescWatchAtLeast(250)),
    ],
  ));

  badges.add(_buildTieredBadge(
    id: 'streak_series',
    defaultTitle: l10n.badgeStreakTitle,
    icon: '🔥',
    category: AchievementCategory.milestone,
    currentValue: longestStreak,
    steps: [
      TierStep(target: 3, title: l10n.badgeStreakT1, description: l10n.badgeDescStreak(3)),
      TierStep(target: 7, title: l10n.badgeStreakT2, description: l10n.badgeDescStreak(7)),
      TierStep(target: 14, title: l10n.badgeStreakT3, description: l10n.badgeDescStreak(14)),
      TierStep(target: 30, title: l10n.badgeStreakT4, description: l10n.badgeDescStreak(30)),
    ],
  ));

  // --- 2. ZAMAN & ATMOSFER ---
  final nightWatches = list.where((r) {
    final h = r.record.watchDate.hour;
    return h >= 0 && h < 5;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'night_owl_series',
    defaultTitle: l10n.badgeNightOwlTitle,
    icon: '🌙',
    category: AchievementCategory.timeOfDay,
    currentValue: nightWatches,
    steps: [
      TierStep(target: 3, title: l10n.badgeNightOwlT1, description: l10n.badgeDescNightWatch(3)),
      TierStep(target: 7, title: l10n.badgeNightOwlT2, description: l10n.badgeDescNightWatch(7)),
      TierStep(target: 15, title: l10n.badgeNightOwlT3, description: l10n.badgeDescNightWatch(15)),
    ],
  ));

  final earlyWatches = list.where((r) {
    final h = r.record.watchDate.hour;
    return h >= 6 && h < 9;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'early_bird_series',
    defaultTitle: l10n.badgeEarlyBirdTitle,
    icon: '🌅',
    category: AchievementCategory.timeOfDay,
    currentValue: earlyWatches,
    steps: [
      TierStep(target: 2, title: l10n.badgeEarlyBirdT1, description: l10n.badgeDescEarlyWatch(2)),
      TierStep(target: 5, title: l10n.badgeEarlyBirdT2, description: l10n.badgeDescEarlyWatch(5)),
      TierStep(target: 10, title: l10n.badgeEarlyBirdT3, description: l10n.badgeDescEarlyWatch(10)),
    ],
  ));

  final sundayWatches = list.where((r) => r.record.watchDate.weekday == 7).length;
  badges.add(_buildTieredBadge(
    id: 'sunday_series',
    defaultTitle: l10n.badgeSundayTitle,
    icon: '☀️',
    category: AchievementCategory.timeOfDay,
    currentValue: sundayWatches,
    steps: [
      TierStep(target: 3, title: l10n.badgeSundayT1, description: l10n.badgeDescSunday(3)),
      TierStep(target: 7, title: l10n.badgeSundayT2, description: l10n.badgeDescSunday(7)),
      TierStep(target: 15, title: l10n.badgeSundayT3, description: l10n.badgeDescSunday(15)),
    ],
  ));

  final maxSingleDayCount = dailyWatchCounts.values.isEmpty ? 0 : dailyWatchCounts.values.reduce((a, b) => a > b ? a : b);
  badges.add(_buildTieredBadge(
    id: 'weekend_marathon_series',
    defaultTitle: l10n.badgeWeekendTitle,
    icon: '🍿',
    category: AchievementCategory.timeOfDay,
    currentValue: maxSingleDayCount,
    steps: [
      TierStep(target: 2, title: l10n.badgeWeekendT1, description: l10n.badgeDescSingleDay(2)),
      TierStep(target: 4, title: l10n.badgeWeekendT2, description: l10n.badgeDescSingleDay(4)),
      TierStep(target: 7, title: l10n.badgeWeekendT3, description: l10n.badgeDescSingleDay(7)),
    ],
  ));

  final winterWatches = list.where((r) {
    final m = r.record.watchDate.month;
    return m == 12 || m == 1 || m == 2;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'seasonal_series',
    defaultTitle: l10n.badgeWinterTitle,
    icon: '❄️',
    category: AchievementCategory.timeOfDay,
    currentValue: winterWatches,
    steps: [
      TierStep(target: 5, title: l10n.badgeWinterT1, description: l10n.badgeDescWinter(5)),
      TierStep(target: 15, title: l10n.badgeWinterT2, description: l10n.badgeDescWinter(15)),
      TierStep(target: 30, title: l10n.badgeWinterT3, description: l10n.badgeDescWinter(30)),
    ],
  ));

  final retroWatches = list.where((r) {
    final year = r.movie.releaseYear;
    return year != null && year < 1980;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'time_traveler_series',
    defaultTitle: l10n.badgeTimeTravelerTitle,
    icon: '⌛',
    category: AchievementCategory.timeOfDay,
    currentValue: retroWatches,
    steps: [
      TierStep(target: 3, title: l10n.badgeTimeTravelerT1, description: l10n.badgeDescRetro(3)),
      TierStep(target: 7, title: l10n.badgeTimeTravelerT2, description: l10n.badgeDescRetro(7)),
      TierStep(target: 15, title: l10n.badgeTimeTravelerT3, description: l10n.badgeDescRetro(15)),
    ],
  ));

  // --- 3. YÖNETMENLER & AUTEURS ---
  final nolanCount = _countByKeyword(list, (r) => r.movie.director, 'christopher nolan');
  badges.add(_buildTieredBadge(
    id: 'nolan_series',
    defaultTitle: l10n.badgeNolanTitle,
    icon: '🎬',
    category: AchievementCategory.directors,
    currentValue: nolanCount,
    steps: [
      TierStep(target: 2, title: l10n.badgeNolanT1, description: l10n.badgeDescDirector(2, 'Christopher Nolan')),
      TierStep(target: 4, title: l10n.badgeNolanT2, description: l10n.badgeDescDirector(4, 'Christopher Nolan')),
      TierStep(target: 7, title: l10n.badgeNolanT3, description: l10n.badgeDescDirector(7, 'Christopher Nolan')),
    ],
  ));

  final tarantinoCount = _countByKeyword(list, (r) => r.movie.director, 'tarantino');
  badges.add(_buildTieredBadge(
    id: 'tarantino_series',
    defaultTitle: l10n.badgeTarantinoTitle,
    icon: '🕶️',
    category: AchievementCategory.directors,
    currentValue: tarantinoCount,
    steps: [
      TierStep(target: 2, title: l10n.badgeTarantinoT1, description: l10n.badgeDescDirector(2, 'Quentin Tarantino')),
      TierStep(target: 4, title: l10n.badgeTarantinoT2, description: l10n.badgeDescDirector(4, 'Quentin Tarantino')),
      TierStep(target: 7, title: l10n.badgeTarantinoT3, description: l10n.badgeDescDirector(7, 'Quentin Tarantino')),
    ],
  ));

  final spielbergCount = _countByKeyword(list, (r) => r.movie.director, 'spielberg');
  badges.add(_buildTieredBadge(
    id: 'spielberg_series',
    defaultTitle: l10n.badgeSpielbergTitle,
    icon: '🚀',
    category: AchievementCategory.directors,
    currentValue: spielbergCount,
    steps: [
      TierStep(target: 2, title: l10n.badgeSpielbergT1, description: l10n.badgeDescDirector(2, 'Steven Spielberg')),
      TierStep(target: 5, title: l10n.badgeSpielbergT2, description: l10n.badgeDescDirector(5, 'Steven Spielberg')),
      TierStep(target: 9, title: l10n.badgeSpielbergT3, description: l10n.badgeDescDirector(9, 'Steven Spielberg')),
    ],
  ));

  final scorseseCount = _countByKeyword(list, (r) => r.movie.director, 'scorsese');
  badges.add(_buildTieredBadge(
    id: 'scorsese_series',
    defaultTitle: l10n.badgeScorseseTitle,
    icon: '🎻',
    category: AchievementCategory.directors,
    currentValue: scorseseCount,
    steps: [
      TierStep(target: 2, title: l10n.badgeScorseseT1, description: l10n.badgeDescDirector(2, 'Martin Scorsese')),
      TierStep(target: 4, title: l10n.badgeScorseseT2, description: l10n.badgeDescDirector(4, 'Martin Scorsese')),
      TierStep(target: 7, title: l10n.badgeScorseseT3, description: l10n.badgeDescDirector(7, 'Martin Scorsese')),
    ],
  ));

  final kubrickCount = _countByKeyword(list, (r) => r.movie.director, 'kubrick');
  badges.add(_buildTieredBadge(
    id: 'kubrick_series',
    defaultTitle: l10n.badgeKubrickTitle,
    icon: '🌌',
    category: AchievementCategory.directors,
    currentValue: kubrickCount,
    steps: [
      TierStep(target: 2, title: l10n.badgeKubrickT1, description: l10n.badgeDescDirector(2, 'Stanley Kubrick')),
      TierStep(target: 4, title: l10n.badgeKubrickT2, description: l10n.badgeDescDirector(4, 'Stanley Kubrick')),
      TierStep(target: 6, title: l10n.badgeKubrickT3, description: l10n.badgeDescDirector(6, 'Stanley Kubrick')),
    ],
  ));

  // --- 4. TÜRLER & TEMALAR ---
  final westernCount = _countByGenreId(list, TmdbGenre.western);
  badges.add(_buildTieredBadge(
    id: 'western_series',
    defaultTitle: l10n.badgeWesternTitle,
    icon: '🤠',
    category: AchievementCategory.genres,
    currentValue: westernCount,
    steps: [
      TierStep(target: 3, title: l10n.badgeWesternT1, description: l10n.badgeDescWestern(3)),
      TierStep(target: 5, title: l10n.badgeWesternT2, description: l10n.badgeDescWestern(5)),
      TierStep(target: 10, title: l10n.badgeWesternT3, description: l10n.badgeDescWestern(10)),
    ],
  ));

  // The old substring 'bilim kurgu' also caught the TV genre "Bilim Kurgu &
  // Fantazi"; both ids are counted here to keep that behaviour.
  final scifiCount = _countByGenreId(list, TmdbGenre.scienceFiction) +
      _countByGenreId(list, TmdbGenre.sciFiFantasy);
  badges.add(_buildTieredBadge(
    id: 'scifi_series',
    defaultTitle: l10n.badgeScifiTitle,
    icon: '🌌',
    category: AchievementCategory.genres,
    currentValue: scifiCount,
    steps: [
      TierStep(target: 3, title: l10n.badgeScifiT1, description: l10n.badgeDescScifi(3)),
      TierStep(target: 7, title: l10n.badgeScifiT2, description: l10n.badgeDescScifi(7)),
      TierStep(target: 15, title: l10n.badgeScifiT3, description: l10n.badgeDescScifi(15)),
    ],
  ));

  // Summed rather than OR'd, matching the previous behaviour: a title that is
  // both horror and thriller counts twice. Changing that would retroactively
  // lower some users' badge progress.
  final horrorCount = _countByGenreId(list, TmdbGenre.horror) +
      _countByGenreId(list, TmdbGenre.thriller);
  badges.add(_buildTieredBadge(
    id: 'horror_series',
    defaultTitle: l10n.badgeHorrorTitle,
    icon: '👻',
    category: AchievementCategory.genres,
    currentValue: horrorCount,
    steps: [
      TierStep(target: 3, title: l10n.badgeHorrorT1, description: l10n.badgeDescHorror(3)),
      TierStep(target: 7, title: l10n.badgeHorrorT2, description: l10n.badgeDescHorror(7)),
      TierStep(target: 12, title: l10n.badgeHorrorT3, description: l10n.badgeDescHorror(12)),
    ],
  ));

  final dramaCount = _countByGenreId(list, TmdbGenre.drama);
  badges.add(_buildTieredBadge(
    id: 'drama_series',
    defaultTitle: l10n.badgeDramaTitle,
    icon: '🎭',
    category: AchievementCategory.genres,
    currentValue: dramaCount,
    steps: [
      TierStep(target: 5, title: l10n.badgeDramaT1, description: l10n.badgeDescDrama(5)),
      TierStep(target: 12, title: l10n.badgeDramaT2, description: l10n.badgeDescDrama(12)),
      TierStep(target: 25, title: l10n.badgeDramaT3, description: l10n.badgeDescDrama(25)),
    ],
  ));

  final crimeCount = _countByGenreId(list, TmdbGenre.crime) +
      _countByGenreId(list, TmdbGenre.mystery);
  badges.add(_buildTieredBadge(
    id: 'crime_series',
    defaultTitle: l10n.badgeCrimeTitle,
    icon: '🕵️',
    category: AchievementCategory.genres,
    currentValue: crimeCount,
    steps: [
      TierStep(target: 3, title: l10n.badgeCrimeT1, description: l10n.badgeDescCrime(3)),
      TierStep(target: 7, title: l10n.badgeCrimeT2, description: l10n.badgeDescCrime(7)),
      TierStep(target: 15, title: l10n.badgeCrimeT3, description: l10n.badgeDescCrime(15)),
    ],
  ));

  // The old second term, 'çizgi', matched no TMDb genre name at all — TMDb
  // calls this one "Animasyon" — so it only ever contributed zero.
  final animationCount = _countByGenreId(list, TmdbGenre.animation);
  badges.add(_buildTieredBadge(
    id: 'animation_series',
    defaultTitle: l10n.badgeAnimationTitle,
    icon: '🎨',
    category: AchievementCategory.genres,
    currentValue: animationCount,
    steps: [
      TierStep(target: 3, title: l10n.badgeAnimationT1, description: l10n.badgeDescAnimation(3)),
      TierStep(target: 7, title: l10n.badgeAnimationT2, description: l10n.badgeDescAnimation(7)),
      TierStep(target: 15, title: l10n.badgeAnimationT3, description: l10n.badgeDescAnimation(15)),
    ],
  ));

  final turkishCount = list.where((r) {
    final title = r.movie.title.toLowerCase();
    final overview = r.movie.overview?.toLowerCase() ?? '';
    final director = r.movie.director?.toLowerCase() ?? '';
    final actors = r.movie.actors?.toLowerCase() ?? '';
    return title.contains(RegExp(r'[ığüşöç]')) ||
        overview.contains('türk') ||
        director.contains('nuri bilge') ||
        director.contains('kemal') ||
        actors.contains('şener') ||
        actors.contains('kemal sunal');
  }).length;
  badges.add(_buildTieredBadge(
    id: 'turkish_series',
    defaultTitle: l10n.badgeTurkishTitle,
    icon: '🇹🇷',
    category: AchievementCategory.genres,
    currentValue: turkishCount,
    steps: [
      TierStep(target: 3, title: l10n.badgeTurkishT1, description: l10n.badgeDescTurkish(3)),
      TierStep(target: 7, title: l10n.badgeTurkishT2, description: l10n.badgeDescTurkish(7)),
      TierStep(target: 15, title: l10n.badgeTurkishT3, description: l10n.badgeDescTurkish(15)),
    ],
  ));

  // --- 5. ELEŞTİRMEN & GÜNLÜK ---
  final criticNotesCount = list.where((r) => r.setting?.personalNotes != null && r.setting!.personalNotes!.trim().isNotEmpty).length;
  badges.add(_buildTieredBadge(
    id: 'critic_series',
    defaultTitle: l10n.badgeCriticTitle,
    icon: '✍️',
    category: AchievementCategory.critic,
    currentValue: criticNotesCount,
    steps: [
      TierStep(target: 3, title: l10n.badgeCriticT1, description: l10n.badgeDescNotes(3)),
      TierStep(target: 10, title: l10n.badgeCriticT2, description: l10n.badgeDescNotes(10)),
      TierStep(target: 25, title: l10n.badgeCriticT3, description: l10n.badgeDescNotes(25)),
    ],
  ));

  final perfectRaters = list.where((r) => r.record.rating >= 9.8).length;
  badges.add(_buildTieredBadge(
    id: 'generous_series',
    defaultTitle: l10n.badgeGenerousTitle,
    icon: '🌟',
    category: AchievementCategory.critic,
    currentValue: perfectRaters,
    steps: [
      TierStep(target: 3, title: l10n.badgeGenerousT1, description: l10n.badgeDescPerfectScore(3)),
      TierStep(target: 7, title: l10n.badgeGenerousT2, description: l10n.badgeDescPerfectScore(7)),
      TierStep(target: 15, title: l10n.badgeGenerousT3, description: l10n.badgeDescPerfectScore(15)),
    ],
  ));

  final strictRaters = list.where((r) => r.record.rating < 5.0).length;
  badges.add(_buildTieredBadge(
    id: 'strict_series',
    defaultTitle: l10n.badgeStrictTitle,
    icon: '🌵',
    category: AchievementCategory.critic,
    currentValue: strictRaters,
    steps: [
      TierStep(target: 2, title: l10n.badgeStrictT1, description: l10n.badgeDescLowScore(2)),
      TierStep(target: 5, title: l10n.badgeStrictT2, description: l10n.badgeDescLowScore(5)),
      TierStep(target: 10, title: l10n.badgeStrictT3, description: l10n.badgeDescLowScore(10)),
    ],
  ));

  final rewatches = list.where((r) => r.record.watchNumber > 1).length;
  badges.add(_buildTieredBadge(
    id: 'rewatch_series',
    defaultTitle: l10n.badgeRewatchTitle,
    icon: '🔁',
    category: AchievementCategory.critic,
    currentValue: rewatches,
    steps: [
      TierStep(target: 1, title: l10n.badgeRewatchT1, description: l10n.badgeDescRewatchNth(2)),
      TierStep(target: 4, title: l10n.badgeRewatchT2, description: l10n.badgeDescRewatchTimes(4)),
      TierStep(target: 10, title: l10n.badgeRewatchT3, description: l10n.badgeDescRewatchRecords(10)),
    ],
  ));

  badges.add(_buildTieredBadge(
    id: 'tag_master_series',
    defaultTitle: l10n.badgeTagMasterTitle,
    icon: '🏷️',
    category: AchievementCategory.critic,
    currentValue: topTags.length,
    steps: [
      TierStep(target: 3, title: l10n.badgeTagMasterT1, description: l10n.badgeDescTags(3)),
      TierStep(target: 7, title: l10n.badgeTagMasterT2, description: l10n.badgeDescTags(7)),
      TierStep(target: 15, title: l10n.badgeTagMasterT3, description: l10n.badgeDescTags(15)),
    ],
  ));

  // --- 6. DİZİ & SEZON ---
  final totalTvEpisodes = list.where((r) => r.movie.isTv).fold<int>(0, (prev, e) => prev + e.record.episodeCount);
  badges.add(_buildTieredBadge(
    id: 'tv_series',
    defaultTitle: l10n.badgeTvTitle,
    icon: '📺',
    category: AchievementCategory.tvShows,
    currentValue: totalTvEpisodes,
    steps: [
      TierStep(target: 10, title: l10n.badgeTvT1, description: l10n.badgeDescEpisodes(10)),
      TierStep(target: 50, title: l10n.badgeTvT2, description: l10n.badgeDescEpisodes(50)),
      TierStep(target: 150, title: l10n.badgeTvT3, description: l10n.badgeDescEpisodes(150)),
    ],
  ));

  final finishedSeasons = list.where((r) => r.movie.isTv && r.record.episodeCount >= 8).length;
  badges.add(_buildTieredBadge(
    id: 'season_finisher_series',
    defaultTitle: l10n.badgeSeasonTitle,
    icon: '📦',
    category: AchievementCategory.tvShows,
    currentValue: finishedSeasons,
    steps: [
      TierStep(target: 1, title: l10n.badgeSeasonT1, description: l10n.badgeDescSeasons(1)),
      TierStep(target: 3, title: l10n.badgeSeasonT2, description: l10n.badgeDescSeasons(3)),
      TierStep(target: 8, title: l10n.badgeSeasonT3, description: l10n.badgeDescSeasons(8)),
    ],
  ));

  return badges;
}

/// Tallies genre ids across [list], most-watched first.
///
/// Replaces counting the localized `movie.genres` text: that made "Dram" and
/// "Drama" two different genres for anyone who switched language mid-history.
List<MapEntry<int, int>> _countGenreIds(List<WatchRecordWithMovie> list) {
  final counts = <int, int>{};
  for (final r in list) {
    for (final id in parseGenreIds(r.movie.genreIds)) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
  }
  final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return sorted;
}

/// How many records in [list] carry [genreId].
///
/// The genre badges below used to substring-match the localized genre text,
/// which was both language-dependent and quietly wrong: 'western' never
/// matched "Vahşi Batı" and 'drama' never matched "Dram", so those two badges
/// could not be earned at all.
int _countByGenreId(List<WatchRecordWithMovie> list, int genreId) {
  return list.where((r) => parseGenreIds(r.movie.genreIds).contains(genreId)).length;
}

int _countByKeyword(
  List<WatchRecordWithMovie> list,
  String? Function(WatchRecordWithMovie) selector,
  String keyword,
) {
  final kw = keyword.toLowerCase();
  return list.where((r) {
    final str = selector(r)?.toLowerCase() ?? '';
    return str.contains(kw);
  }).length;
}
