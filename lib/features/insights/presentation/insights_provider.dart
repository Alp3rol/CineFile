import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';

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
}

class InsightsData {
  final int totalWatchCount;
  final int uniqueTitleCount;
  final int totalDurationMinutes;
  final double averageRating;
  final List<MapEntry<String, int>> topGenres;
  final List<MapEntry<String, int>> topDirectors;
  final List<MapEntry<String, int>> topActors;
  final Map<int, int> monthlyWatchTrend; // Month (1-12) -> Count
  final Map<String, int> timeOfDayTrend; // 'Sabah', 'Öğle', 'Akşam', 'Gece' -> Count
  final Map<int, int> dayOfWeekTrend; // Day (1-7) -> Count
  final List<BadgeState> badges;

  // v0.8.2: Heatmap & Streaks
  final Map<String, int> dailyWatchCounts;
  final Map<String, int> dailyMovieWatchCounts;
  final Map<String, int> dailyTvWatchCounts;
  final int currentStreak;
  final int longestStreak;

  // v0.8.3: Rating Distribution
  final Map<int, int> ratingDistribution;
  final int mostFrequentRating;

  // v0.8.4: Seasonal Trends
  final Map<String, int> seasonalCounts;
  final int goldenWeekday;

  // v0.9.0: In-App Tags & Weekly Goal
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

final insightsProvider = Provider<InsightsData?>((ref) {
  final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
  final list = watchRecordsAsync.value;
  if (list == null || list.isEmpty) return null;

  final totalWatchCount = list.length;
  final uniqueTitleCount = list.map((r) => (r.movie.tmdbId, r.movie.isTv)).toSet().length;
  
  // Total Duration. episodeCount scales a single watch record's duration
  // for TV shows, since TMDb only exposes one flat runtime per show rather
  // than a value per episode (always 1 for movies).
  int totalDurationMinutes = 0;
  for (final r in list) {
    totalDurationMinutes += (r.movie.runtime ?? 0) * r.record.episodeCount;
  }

  // Average Rating
  double totalRating = 0;
  int ratingCount = 0;
  for (final r in list) {
    totalRating += r.record.rating;
    ratingCount++;
  }
  final averageRating = ratingCount > 0 ? (totalRating / ratingCount) : 0.0;

  final topGenres = _countCommaSeparatedField(list, (r) => r.movie.genres);
  final topDirectors = _countCommaSeparatedField(list, (r) => r.movie.director);
  final topActors = _countCommaSeparatedField(list, (r) => r.movie.actors);

  // Monthly Trend for the current year
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

  // Time of Day Trend
  final timeOfDayTrend = {
    'Sabah': 0, // 06:00 - 12:00
    'Öğle': 0,  // 12:00 - 18:00
    'Akşam': 0, // 18:00 - 00:00
    'Gece': 0,  // 00:00 - 06:00
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

  // Day of Week Trend
  final dayOfWeekTrend = <int, int>{};
  for (int i = 1; i <= 7; i++) {
    dayOfWeekTrend[i] = 0;
  }
  for (final r in list) {
    final weekday = r.record.watchDate.weekday;
    dayOfWeekTrend[weekday] = (dayOfWeekTrend[weekday] ?? 0) + 1;
  }

  // Daily Watch Counter (Key: 'yyyy-MM-dd')
  final dailyWatchCounts = <String, int>{};
  final dailyMovieWatchCounts = <String, int>{};
  final dailyTvWatchCounts = <String, int>{};

  for (final r in list) {
    final date = r.record.watchDate;
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Film vs Dizi (dizi için bölüm sayısı, film için her zaman 1 kayıt) —
    // dailyWatchCounts ('Tümü') bu ikisinin toplamıyla tutarlı kalır.
    final increment = r.movie.isTv ? r.record.episodeCount : 1;
    dailyWatchCounts[dateKey] = (dailyWatchCounts[dateKey] ?? 0) + increment;

    if (r.movie.isTv) {
      dailyTvWatchCounts[dateKey] = (dailyTvWatchCounts[dateKey] ?? 0) + increment;
    } else {
      dailyMovieWatchCounts[dateKey] = (dailyMovieWatchCounts[dateKey] ?? 0) + increment;
    }
  }

  // Calculate Streaks
  final uniqueDates = list
      .map((r) {
        final d = r.record.watchDate;
        return DateTime(d.year, d.month, d.day);
      })
      .toSet()
      .toList()
    ..sort();

  int currentStreak = 0;
  int longestStreak = 0;

  if (uniqueDates.isNotEmpty) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Longest Streak calculation
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

    // Current Streak calculation
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

  // Rating Distribution (1-10)
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

  // Seasonal Counts
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

  // Golden Weekday
  int goldenWeekday = 7;
  int maxDayCount = -1;
  for (final entry in dayOfWeekTrend.entries) {
    if (entry.value > maxDayCount) {
      maxDayCount = entry.value;
      goldenWeekday = entry.key;
    }
  }

  // Tag Counter (v0.9.0)
  final topTags = _countCommaSeparatedField(list, (r) => r.record.tags);

  // Compute Achievements / Badges
  final badges = <BadgeState>[
    // 1. İlk Adım
    BadgeState(
      id: 'first_watch',
      title: 'İlk Adım',
      description: 'Günlüğe ilk izleme kaydını ekle.',
      icon: '🥇',
      isUnlocked: totalWatchCount >= 1,
      progress: (totalWatchCount / 1).clamp(0.0, 1.0),
    ),
    // 2. Sinefil
    BadgeState(
      id: 'sinefil',
      title: 'Sinefil',
      description: 'En az 10 film veya dizi izle.',
      icon: '🍿',
      isUnlocked: totalWatchCount >= 10,
      progress: (totalWatchCount / 10).clamp(0.0, 1.0),
    ),
    // 3. Kültür Mantarı
    BadgeState(
      id: 'culture_buff',
      title: 'Kültür Mantarı',
      description: 'En az 50 film veya dizi izle.',
      icon: '🎬',
      isUnlocked: totalWatchCount >= 50,
      progress: (totalWatchCount / 50).clamp(0.0, 1.0),
    ),
    // 4. Gece Kuşu
    _buildNightOwlBadge(list),
    // 5. Sadık İzleyici
    _buildRewatchBadge(list),
    // 6. Nolanist
    _buildNolanistBadge(list),
    // 7. Yerli Sinema Dostu
    _buildTurkishCinemaBadge(list),
  ];

  // Calculate movies watched in the current week (from Monday to Sunday) (v0.9.0)
  final today = DateTime.now();
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final startOfMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final thisWeekWatchCount = list.where((r) => r.record.watchDate.isAfter(startOfMonday) || r.record.watchDate.isAtSameMomentAs(startOfMonday)).length;

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

// Counts occurrences of each item in a comma-separated field (e.g. genres,
// director, actors, tags) across all watch records, sorted by frequency.
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

BadgeState _buildNightOwlBadge(List<WatchRecordWithMovie> list) {
  final nightWatches = list.where((r) {
    final hour = r.record.watchDate.hour;
    return hour >= 22 || hour < 6;
  }).length;

  return BadgeState(
    id: 'night_owl',
    title: 'Gece Kuşu',
    description: 'Gece saat 22:00\'den sonra 5 izleme kaydet.',
    icon: '🦉',
    isUnlocked: nightWatches >= 5,
    progress: (nightWatches / 5).clamp(0.0, 1.0),
  );
}

BadgeState _buildRewatchBadge(List<WatchRecordWithMovie> list) {
  final rewatches = list.where((r) => r.record.watchNumber > 1).length;

  return BadgeState(
    id: 'rewatch_fan',
    title: 'Sadık İzleyici',
    description: 'Aynı içeriği 2 veya daha fazla kez izle.',
    icon: '🔄',
    isUnlocked: rewatches >= 1,
    progress: (rewatches / 1).clamp(0.0, 1.0),
  );
}

BadgeState _buildNolanistBadge(List<WatchRecordWithMovie> list) {
  final nolanWatches = list.where((r) {
    final director = r.movie.director?.toLowerCase() ?? '';
    return director.contains('christopher nolan');
  }).length;

  return BadgeState(
    id: 'nolanist',
    title: 'Nolanist',
    description: 'En az 3 Christopher Nolan filmi izle.',
    icon: '🎥',
    isUnlocked: nolanWatches >= 3,
    progress: (nolanWatches / 3).clamp(0.0, 1.0),
  );
}

BadgeState _buildTurkishCinemaBadge(List<WatchRecordWithMovie> list) {
  final turkishWatches = list.where((r) {
    final title = r.movie.title.toLowerCase();
    final overview = r.movie.overview?.toLowerCase() ?? '';
    final hasTurkishChars = title.contains(RegExp(r'[ığüşöç]'));
    final mentionsTurkish = overview.contains('türk') || title.contains('türk');
    
    // Director/actors Turkish cinema reference
    final director = r.movie.director?.toLowerCase() ?? '';
    final actors = r.movie.actors?.toLowerCase() ?? '';
    final isTurkishArtist = director.contains('nuri bilge') || 
                            director.contains('kemal') || 
                            director.contains('şener') ||
                            actors.contains('şener şen') ||
                            actors.contains('kemal sunal');

    return hasTurkishChars || mentionsTurkish || isTurkishArtist;
  }).length;

  return BadgeState(
    id: 'turkish_cinema',
    title: 'Yerli Sinema Dostu',
    description: 'En az 3 adet yerli/Türkçe yapım izle.',
    icon: '🇹🇷',
    isUnlocked: turkishWatches >= 3,
    progress: (turkishWatches / 3).clamp(0.0, 1.0),
  );
}
