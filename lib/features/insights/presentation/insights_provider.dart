import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/achievement_models.dart';
import 'widgets/contribution_heatmap_utils.dart';

extension WatchRecordSafeExtension on WatchRecord {
  int get safeEpisodeCount {
    try {
      return (episodeCount as dynamic) ?? 1;
    } catch (_) {
      return 1;
    }
  }

  int get safeWatchNumber {
    try {
      return (watchNumber as dynamic) ?? 1;
    } catch (_) {
      return 1;
    }
  }

  double get safeRating {
    try {
      return (rating as dynamic)?.toDouble() ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }
}

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
  final List<MapEntry<String, int>> topGenres;
  final List<MapEntry<String, int>> topDirectors;
  final List<MapEntry<String, int>> topActors;
  final Map<int, int> monthlyWatchTrend;
  final Map<String, int> timeOfDayTrend;
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
  final Map<String, int> seasonalCounts;
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
    totalDurationMinutes += (r.movie.runtime ?? 0) * r.record.safeEpisodeCount;
  }

  double totalRating = 0;
  int ratingCount = 0;
  for (final r in list) {
    totalRating += r.record.safeRating;
    ratingCount++;
  }
  final averageRating = ratingCount > 0 ? (totalRating / ratingCount) : 0.0;

  final topGenres = _countCommaSeparatedField(list, (r) => r.movie.genres);
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

  final timeOfDayTrend = <String, int>{
    'Sabah': 0,
    'Öğle': 0,
    'Akşam': 0,
    'Gece': 0,
  };
  for (final r in list) {
    final hour = r.record.watchDate.hour;
    if (hour >= 6 && hour < 12) {
      timeOfDayTrend['Sabah'] = (timeOfDayTrend['Sabah'] ?? 0) + 1;
    } else if (hour >= 12 && hour < 18) {
      timeOfDayTrend['Öğle'] = (timeOfDayTrend['Öğle'] ?? 0) + 1;
    } else if (hour >= 18 && hour < 24) {
      timeOfDayTrend['Akşam'] = (timeOfDayTrend['Akşam'] ?? 0) + 1;
    } else {
      timeOfDayTrend['Gece'] = (timeOfDayTrend['Gece'] ?? 0) + 1;
    }
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
    final increment = r.movie.isTv ? r.record.safeEpisodeCount : 1;
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

    bool hasToday = uniqueDates.contains(today);
    bool hasYesterday = uniqueDates.contains(yesterday);

    if (hasToday || hasYesterday) {
      DateTime checkDate = hasToday ? today : yesterday;
      while (uniqueDates.contains(checkDate)) {
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
    final ratingInt = r.record.safeRating.round().clamp(1, 10);
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

  final seasonalCounts = {
    'Kış': 0,
    'İlkbahar': 0,
    'Yaz': 0,
    'Sonbahar': 0,
  };
  for (final r in list) {
    final month = r.record.watchDate.month;
    if (month == 12 || month == 1 || month == 2) {
      seasonalCounts['Kış'] = seasonalCounts['Kış']! + 1;
    } else if (month >= 3 && month <= 5) {
      seasonalCounts['İlkbahar'] = seasonalCounts['İlkbahar']! + 1;
    } else if (month >= 6 && month <= 8) {
      seasonalCounts['Yaz'] = seasonalCounts['Yaz']! + 1;
    } else {
      seasonalCounts['Sonbahar'] = seasonalCounts['Sonbahar']! + 1;
    }
  }

  int goldenWeekday = 7;
  int maxDayCount = -1;
  for (final entry in dayOfWeekTrend.entries) {
    if (entry.value > maxDayCount) {
      maxDayCount = entry.value;
      goldenWeekday = entry.key;
    }
  }

  final topTags = _countCommaSeparatedField(list, (r) => r.setting?.personalTags);

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
}) {
  final badges = <AchievementBadge>[];

  // --- 1. HACİM VE MARATON (MILSTONES) ---
  badges.add(_buildTieredBadge(
    id: 'first_watch_series',
    defaultTitle: 'İlk Adımlar',
    icon: '🥇',
    category: AchievementCategory.milestone,
    currentValue: totalWatchCount,
    steps: const [
      TierStep(target: 1, title: 'İlk Adım', description: 'Günlüğe 1 izleme kaydı ekle.'),
      TierStep(target: 5, title: 'İzleme Tutkusu', description: 'Günlüğe 5 izleme kaydı ekle.'),
      TierStep(target: 15, title: 'Sıkı Takipçi', description: 'Günlüğe 15 izleme kaydı ekle.'),
    ],
  ));

  badges.add(_buildTieredBadge(
    id: 'sinefil_series',
    defaultTitle: 'Sinefil Serisi',
    icon: '🍿',
    category: AchievementCategory.milestone,
    currentValue: totalWatchCount,
    steps: const [
      TierStep(target: 10, title: 'Sinefil', description: 'En az 10 film veya dizi izle.'),
      TierStep(target: 50, title: 'Kültür Mantarı', description: 'En az 50 film veya dizi izle.'),
      TierStep(target: 100, title: 'Sinema Efsanesi', description: 'En az 100 film veya dizi izle.'),
      TierStep(target: 250, title: 'Sinema Gurusu', description: 'En az 250 film veya dizi izle.'),
    ],
  ));

  badges.add(_buildTieredBadge(
    id: 'streak_series',
    defaultTitle: 'Seri İzleyici',
    icon: '🔥',
    category: AchievementCategory.milestone,
    currentValue: longestStreak,
    steps: const [
      TierStep(target: 3, title: 'Kısa Maraton', description: 'Üst üste 3 gün boyunca kayıt gir.'),
      TierStep(target: 7, title: 'Seri İzleyici', description: 'Üst üste 7 gün boyunca kayıt gir.'),
      TierStep(target: 14, title: 'Ateşli İzleyici', description: 'Üst üste 14 gün boyunca kayıt gir.'),
      TierStep(target: 30, title: 'Durdurulamaz Maratoncu', description: 'Üst üste 30 gün boyunca kayıt gir.'),
    ],
  ));

  // --- 2. ZAMAN & ATMOSFER ---
  final nightWatches = list.where((r) {
    final h = r.record.watchDate.hour;
    return h >= 0 && h < 5;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'night_owl_series',
    defaultTitle: 'Gece Kuşu Serisi',
    icon: '🌙',
    category: AchievementCategory.timeOfDay,
    currentValue: nightWatches,
    steps: const [
      TierStep(target: 3, title: 'Gece Kuşu', description: 'Gece 00:00 - 05:00 arasında 3 izleme yap.'),
      TierStep(target: 7, title: 'Gece Bekçisi', description: 'Gece 00:00 - 05:00 arasında 7 izleme yap.'),
      TierStep(target: 15, title: 'Karanlıklar Prensi', description: 'Gece 00:00 - 05:00 arasında 15 izleme yap.'),
    ],
  ));

  final earlyWatches = list.where((r) {
    final h = r.record.watchDate.hour;
    return h >= 6 && h < 9;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'early_bird_series',
    defaultTitle: 'Erken Kuş Serisi',
    icon: '🌅',
    category: AchievementCategory.timeOfDay,
    currentValue: earlyWatches,
    steps: const [
      TierStep(target: 2, title: 'Gün Doğumu İzleyicisi', description: 'Sabah 06:00 - 09:00 arasında 2 izleme yap.'),
      TierStep(target: 5, title: 'Erken Kuş', description: 'Sabah 06:00 - 09:00 arasında 5 izleme yap.'),
      TierStep(target: 10, title: 'Şafak Bekçisi', description: 'Sabah 06:00 - 09:00 arasında 10 izleme yap.'),
    ],
  ));

  final sundayWatches = list.where((r) => r.record.watchDate.weekday == 7).length;
  badges.add(_buildTieredBadge(
    id: 'sunday_series',
    defaultTitle: 'Pazar Sineması',
    icon: '☀️',
    category: AchievementCategory.timeOfDay,
    currentValue: sundayWatches,
    steps: const [
      TierStep(target: 3, title: 'Pazar Keyfi', description: 'Pazar günleri 3 film/dizi izle.'),
      TierStep(target: 7, title: 'Pazar Sineması', description: 'Pazar günleri 7 film/dizi izle.'),
      TierStep(target: 15, title: 'Pazar Üstadı', description: 'Pazar günleri 15 film/dizi izle.'),
    ],
  ));

  final maxSingleDayCount = dailyWatchCounts.values.isEmpty ? 0 : dailyWatchCounts.values.reduce((a, b) => a > b ? a : b);
  badges.add(_buildTieredBadge(
    id: 'weekend_marathon_series',
    defaultTitle: 'Hafta Sonu Maratonu',
    icon: '🍿',
    category: AchievementCategory.timeOfDay,
    currentValue: maxSingleDayCount,
    steps: const [
      TierStep(target: 2, title: 'Hafta Sonu Başlangıcı', description: 'Tek günde en az 2 film/dizi izle.'),
      TierStep(target: 4, title: 'Hafta Sonu Maratoncusu', description: 'Tek günde en az 4 film/dizi izle.'),
      TierStep(target: 7, title: 'Hafta Sonu Canavarı', description: 'Tek günde en az 7 film/dizi izle.'),
    ],
  ));

  final winterWatches = list.where((r) {
    final m = r.record.watchDate.month;
    return m == 12 || m == 1 || m == 2;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'seasonal_series',
    defaultTitle: 'Kışlık Battaniye & Film',
    icon: '❄️',
    category: AchievementCategory.timeOfDay,
    currentValue: winterWatches,
    steps: const [
      TierStep(target: 5, title: 'Mevsimlik İzleyici', description: 'Kış aylarında 5 yapım izle.'),
      TierStep(target: 15, title: 'Kışlık Battaniye & Film', description: 'Kış aylarında 15 yapım izle.'),
      TierStep(target: 30, title: 'Dört Mevsim Sinefil', description: 'Kış aylarında 30 yapım izle.'),
    ],
  ));

  final retroWatches = list.where((r) {
    final year = r.movie.releaseYear;
    return year != null && year < 1980;
  }).length;
  badges.add(_buildTieredBadge(
    id: 'time_traveler_series',
    defaultTitle: 'Zaman Gezgini',
    icon: '⌛',
    category: AchievementCategory.timeOfDay,
    currentValue: retroWatches,
    steps: const [
      TierStep(target: 3, title: 'Nostalji Meraklısı', description: '1980 öncesi çekilmiş 3 film izle.'),
      TierStep(target: 7, title: 'Zaman Gezgini', description: '1980 öncesi çekilmiş 7 film izle.'),
      TierStep(target: 15, title: 'Klasikler Arşivcisi', description: '1980 öncesi çekilmiş 15 film izle.'),
    ],
  ));

  // --- 3. YÖNETMENLER & AUTEURS ---
  final nolanCount = _countByKeyword(list, (r) => r.movie.director, 'christopher nolan');
  badges.add(_buildTieredBadge(
    id: 'nolan_series',
    defaultTitle: 'Nolanist Serisi',
    icon: '🎬',
    category: AchievementCategory.directors,
    currentValue: nolanCount,
    steps: const [
      TierStep(target: 2, title: 'Nolan Meraklısı', description: '2 Christopher Nolan filmi izle.'),
      TierStep(target: 4, title: 'Zaman Büken Nolanist', description: '4 Christopher Nolan filmi izle.'),
      TierStep(target: 7, title: 'Rüya İçinde Rüya Mimarı', description: '7 Christopher Nolan filmi izle.'),
    ],
  ));

  final tarantinoCount = _countByKeyword(list, (r) => r.movie.director, 'tarantino');
  badges.add(_buildTieredBadge(
    id: 'tarantino_series',
    defaultTitle: 'Tarantino Sever',
    icon: '🕶️',
    category: AchievementCategory.directors,
    currentValue: tarantinoCount,
    steps: const [
      TierStep(target: 2, title: 'Ucuz Roman Sever', description: '2 Quentin Tarantino filmi izle.'),
      TierStep(target: 4, title: 'Kanlı İntikam Ustası', description: '4 Quentin Tarantino filmi izle.'),
      TierStep(target: 7, title: 'Sinematik Auteur', description: '7 Quentin Tarantino filmi izle.'),
    ],
  ));

  final spielbergCount = _countByKeyword(list, (r) => r.movie.director, 'spielberg');
  badges.add(_buildTieredBadge(
    id: 'spielberg_series',
    defaultTitle: 'Spielberg Hayranı',
    icon: '🚀',
    category: AchievementCategory.directors,
    currentValue: spielbergCount,
    steps: const [
      TierStep(target: 2, title: 'Macera Çırağı', description: '2 Steven Spielberg filmi izle.'),
      TierStep(target: 5, title: 'Spielberg Hayranı', description: '5 Steven Spielberg filmi izle.'),
      TierStep(target: 9, title: 'Blockbuster Efsanesi', description: '9 Steven Spielberg filmi izle.'),
    ],
  ));

  final scorseseCount = _countByKeyword(list, (r) => r.movie.director, 'scorsese');
  badges.add(_buildTieredBadge(
    id: 'scorsese_series',
    defaultTitle: 'Scorsese Müptelası',
    icon: '🎻',
    category: AchievementCategory.directors,
    currentValue: scorseseCount,
    steps: const [
      TierStep(target: 2, title: 'Mafya & Suç Sever', description: '2 Martin Scorsese filmi izle.'),
      TierStep(target: 4, title: 'Scorsese Müptelası', description: '4 Martin Scorsese filmi izle.'),
      TierStep(target: 7, title: 'Sinema Sanatçısı', description: '7 Martin Scorsese filmi izle.'),
    ],
  ));

  final kubrickCount = _countByKeyword(list, (r) => r.movie.director, 'kubrick');
  badges.add(_buildTieredBadge(
    id: 'kubrick_series',
    defaultTitle: 'Kubrick Ustalığı',
    icon: '🌌',
    category: AchievementCategory.directors,
    currentValue: kubrickCount,
    steps: const [
      TierStep(target: 2, title: 'Kubrick Çırağı', description: '2 Stanley Kubrick filmi izle.'),
      TierStep(target: 4, title: 'Kubrick Ustalığı', description: '4 Stanley Kubrick filmi izle.'),
      TierStep(target: 6, title: 'Görsel Vizyoner', description: '6 Stanley Kubrick filmi izle.'),
    ],
  ));

  // --- 4. TÜRLER & TEMALAR ---
  final westernCount = _countByKeyword(list, (r) => r.movie.genres, 'western');
  badges.add(_buildTieredBadge(
    id: 'western_series',
    defaultTitle: 'Vahşi Batı Serisi',
    icon: '🤠',
    category: AchievementCategory.genres,
    currentValue: westernCount,
    steps: const [
      TierStep(target: 3, title: 'Vahşi Batı Kaşifi', description: '3 Western filmi izle.'),
      TierStep(target: 5, title: 'Kovboy & Şerif', description: '5 Western filmi izle.'),
      TierStep(target: 10, title: 'İyi, Kötü ve Çirkin Efsanesi', description: '10 Western filmi izle.'),
    ],
  ));

  final scifiCount = _countByKeyword(list, (r) => r.movie.genres, 'bilim kurgu');
  badges.add(_buildTieredBadge(
    id: 'scifi_series',
    defaultTitle: 'Sci-Fi Kaşifi',
    icon: '🌌',
    category: AchievementCategory.genres,
    currentValue: scifiCount,
    steps: const [
      TierStep(target: 3, title: 'Uzay Yolcusu', description: '3 Bilim Kurgu yapımı izle.'),
      TierStep(target: 7, title: 'Galaksi Kaşifi', description: '7 Bilim Kurgu yapımı izle.'),
      TierStep(target: 15, title: 'Evrenin Hakimi', description: '15 Bilim Kurgu yapımı izle.'),
    ],
  ));

  final horrorCount = _countByKeyword(list, (r) => r.movie.genres, 'korku') +
      _countByKeyword(list, (r) => r.movie.genres, 'gerilim');
  badges.add(_buildTieredBadge(
    id: 'horror_series',
    defaultTitle: 'Korku & Gerilim',
    icon: '👻',
    category: AchievementCategory.genres,
    currentValue: horrorCount,
    steps: const [
      TierStep(target: 3, title: 'Korkusuz İzleyici', description: '3 Korku/Gerilim yapımı izle.'),
      TierStep(target: 7, title: 'Gerilim Üstadı', description: '7 Korku/Gerilim yapımı izle.'),
      TierStep(target: 12, title: 'Kabusların Efendisi', description: '12 Korku/Gerilim yapımı izle.'),
    ],
  ));

  final dramaCount = _countByKeyword(list, (r) => r.movie.genres, 'drama');
  badges.add(_buildTieredBadge(
    id: 'drama_series',
    defaultTitle: 'Drama Tutkunu',
    icon: '🎭',
    category: AchievementCategory.genres,
    currentValue: dramaCount,
    steps: const [
      TierStep(target: 5, title: 'Duygusal İzleyici', description: '5 Drama yapımı izle.'),
      TierStep(target: 12, title: 'Drama Tutkunu', description: '12 Drama yapımı izle.'),
      TierStep(target: 25, title: 'Duygu Üstadı', description: '25 Drama yapımı izle.'),
    ],
  ));

  final crimeCount = _countByKeyword(list, (r) => r.movie.genres, 'suç') +
      _countByKeyword(list, (r) => r.movie.genres, 'gizem');
  badges.add(_buildTieredBadge(
    id: 'crime_series',
    defaultTitle: 'Suç & Gizem Ajanı',
    icon: '🕵️',
    category: AchievementCategory.genres,
    currentValue: crimeCount,
    steps: const [
      TierStep(target: 3, title: 'Amatör Dedektif', description: '3 Suç veya Gizem yapımı izle.'),
      TierStep(target: 7, title: 'Suç & Gizem Ajanı', description: '7 Suç veya Gizem yapımı izle.'),
      TierStep(target: 15, title: 'Sherlock Seviyesi', description: '15 Suç veya Gizem yapımı izle.'),
    ],
  ));

  final animationCount = _countByKeyword(list, (r) => r.movie.genres, 'animasyon') +
      _countByKeyword(list, (r) => r.movie.genres, 'çizgi');
  badges.add(_buildTieredBadge(
    id: 'animation_series',
    defaultTitle: 'Animasyon & Çizgi Düşler',
    icon: '🎨',
    category: AchievementCategory.genres,
    currentValue: animationCount,
    steps: const [
      TierStep(target: 3, title: 'Çizgi Sever', description: '3 Animasyon yapımı izle.'),
      TierStep(target: 7, title: 'Hayal Perdesi', description: '7 Animasyon yapımı izle.'),
      TierStep(target: 15, title: 'Anime & Animasyon Üstadı', description: '15 Animasyon yapımı izle.'),
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
    defaultTitle: 'Yerli Sinema',
    icon: '🇹🇷',
    category: AchievementCategory.genres,
    currentValue: turkishCount,
    steps: const [
      TierStep(target: 3, title: 'Yerli Sinema Dostu', description: '3 Türk yapımı izle.'),
      TierStep(target: 7, title: 'Yeşilçam Sevdalısı', description: '7 Türk yapımı izle.'),
      TierStep(target: 15, title: 'Yerli Sinema Muhafızı', description: '15 Türk yapımı izle.'),
    ],
  ));

  // --- 5. ELEŞTİRMEN & GÜNLÜK ---
  final criticNotesCount = list.where((r) => r.setting?.personalNotes != null && r.setting!.personalNotes!.trim().isNotEmpty).length;
  badges.add(_buildTieredBadge(
    id: 'critic_series',
    defaultTitle: 'Eleştirmen Serisi',
    icon: '✍️',
    category: AchievementCategory.critic,
    currentValue: criticNotesCount,
    steps: const [
      TierStep(target: 3, title: 'Not Tutucu', description: '3 filme kişisel not yaz.'),
      TierStep(target: 10, title: 'Ciddi Eleştirmen', description: '10 filme kişisel not yaz.'),
      TierStep(target: 25, title: 'Köşe Yazarı', description: '25 filme kişisel not yaz.'),
    ],
  ));

  final perfectRaters = list.where((r) => r.record.safeRating >= 9.8).length;
  badges.add(_buildTieredBadge(
    id: 'generous_series',
    defaultTitle: 'Cömert Puanlayıcı',
    icon: '🌟',
    category: AchievementCategory.critic,
    currentValue: perfectRaters,
    steps: const [
      TierStep(target: 3, title: 'Tam Puan Sever', description: '3 yapıma 10/10 tam puan ver.'),
      TierStep(target: 7, title: 'Cömert Puanlayıcı', description: '7 yapıma 10/10 tam puan ver.'),
      TierStep(target: 15, title: 'Başyapıt Avcısı', description: '15 yapıma 10/10 tam puan ver.'),
    ],
  ));

  final strictRaters = list.where((r) => r.record.safeRating < 5.0).length;
  badges.add(_buildTieredBadge(
    id: 'strict_series',
    defaultTitle: 'Zor Beğenen',
    icon: '🌵',
    category: AchievementCategory.critic,
    currentValue: strictRaters,
    steps: const [
      TierStep(target: 2, title: 'Sert Eleştirmen', description: '2 yapıma 5.0 altı puan ver.'),
      TierStep(target: 5, title: 'Zor Beğenen', description: '5 yapıma 5.0 altı puan ver.'),
      TierStep(target: 10, title: 'Affetmeyen Jüri', description: '10 yapıma 5.0 altı puan ver.'),
    ],
  ));

  final rewatches = list.where((r) => r.record.safeWatchNumber > 1).length;
  badges.add(_buildTieredBadge(
    id: 'rewatch_series',
    defaultTitle: 'Sadık İzleyici',
    icon: '🔁',
    category: AchievementCategory.critic,
    currentValue: rewatches,
    steps: const [
      TierStep(target: 1, title: 'Tekrar İzleyen', description: 'Aynı içeriği 2. kez izle.'),
      TierStep(target: 4, title: 'Sadık İzleyici', description: 'Aynı içeriği 4 kez tekrar izle.'),
      TierStep(target: 10, title: 'Fanatik Tekrarcı', description: '10 tekrar izleme kaydı yap.'),
    ],
  ));

  badges.add(_buildTieredBadge(
    id: 'tag_master_series',
    defaultTitle: 'Etiket Ustası',
    icon: '🏷️',
    category: AchievementCategory.critic,
    currentValue: topTags.length,
    steps: const [
      TierStep(target: 3, title: 'Etiket Çırağı', description: '3 farklı kişisel etiket kullan.'),
      TierStep(target: 7, title: 'Kategori Ustası', description: '7 farklı kişisel etiket kullan.'),
      TierStep(target: 15, title: 'Etiket Koleksiyoneri', description: '15 farklı kişisel etiket kullan.'),
    ],
  ));

  // --- 6. DİZİ & SEZON ---
  final totalTvEpisodes = list.where((r) => r.movie.isTv).fold<int>(0, (prev, e) => prev + e.record.safeEpisodeCount);
  badges.add(_buildTieredBadge(
    id: 'tv_series',
    defaultTitle: 'Dizi Kolik Serisi',
    icon: '📺',
    category: AchievementCategory.tvShows,
    currentValue: totalTvEpisodes,
    steps: const [
      TierStep(target: 10, title: 'Dizi Meraklısı', description: '10 dizi bölümü izle.'),
      TierStep(target: 50, title: 'Dizi Kolik', description: '50 dizi bölümü izle.'),
      TierStep(target: 150, title: 'Dizi Müptelası', description: '150 dizi bölümü izle.'),
    ],
  ));

  final finishedSeasons = list.where((r) => r.movie.isTv && r.record.safeEpisodeCount >= 8).length;
  badges.add(_buildTieredBadge(
    id: 'season_finisher_series',
    defaultTitle: 'Sezon Canavarı',
    icon: '📦',
    category: AchievementCategory.tvShows,
    currentValue: finishedSeasons,
    steps: const [
      TierStep(target: 1, title: 'Sezon Bitişi', description: '1 dizinin tüm sezonunu tamamla.'),
      TierStep(target: 3, title: 'Sezon Canavarı', description: '3 dizinin tüm sezonunu tamamla.'),
      TierStep(target: 8, title: 'Maraton Ustası', description: '8 dizinin tüm sezonunu tamamla.'),
    ],
  ));

  return badges;
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
