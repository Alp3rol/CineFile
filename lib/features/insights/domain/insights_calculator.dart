import 'insight_buckets.dart';

class InsightRecord {
  final int tmdbId;
  final bool isTv;
  final DateTime watchDate;
  final double rating;
  final int episodeCount;
  final int watchNumber;
  final int runtime;
  final List<int> genreIds;
  final String? director;
  final String? actors;
  final String? tags;
  final int? releaseYear;
  final String title;
  final String? overview;
  final String? personalNotes;

  const InsightRecord({
    required this.tmdbId,
    required this.isTv,
    required this.watchDate,
    required this.rating,
    required this.episodeCount,
    required this.watchNumber,
    required this.runtime,
    required this.genreIds,
    required this.director,
    required this.actors,
    required this.tags,
    required this.releaseYear,
    required this.title,
    required this.overview,
    required this.personalNotes,
  });
}

class InsightsMetrics {
  final int totalWatchCount;
  final int uniqueTitleCount;
  final int totalDurationMinutes;
  final double averageRating;
  final List<MapEntry<int, int>> topGenres;
  final List<MapEntry<String, int>> topDirectors;
  final List<MapEntry<String, int>> topActors;
  final Map<int, int> monthlyWatchTrend;
  final Map<TimeOfDayBand, int> timeOfDayTrend;
  final Map<int, int> dayOfWeekTrend;
  final Map<String, int> dailyWatchCounts;
  final Map<String, int> dailyMovieWatchCounts;
  final Map<String, int> dailyTvWatchCounts;
  final int currentStreak;
  final int longestStreak;
  final Map<int, int> ratingDistribution;
  final int mostFrequentRating;
  final Map<Season, int> seasonalCounts;
  final int goldenWeekday;
  final List<MapEntry<String, int>> topTags;
  final int thisWeekWatchCount;

  const InsightsMetrics({
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

abstract final class InsightsCalculator {
  static InsightsMetrics calculate({
    required List<InsightRecord> records,
    Set<DateTime> progressOnlyDates = const {},
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final totalDuration = records.fold<int>(
      0,
      (sum, r) => sum + (r.runtime * r.episodeCount),
    );
    final averageRating = records.isEmpty
        ? 0.0
        : records.fold<double>(0, (sum, r) => sum + r.rating) / records.length;

    final monthly = {for (var i = 1; i <= 12; i++) i: 0};
    final timeOfDay = {for (final band in TimeOfDayBand.values) band: 0};
    final weekdays = {for (var i = 1; i <= 7; i++) i: 0};
    final daily = <String, int>{};
    final dailyMovies = <String, int>{};
    final dailyTv = <String, int>{};
    final ratings = {for (var i = 1; i <= 10; i++) i: 0};
    final seasons = {for (final season in Season.values) season: 0};

    for (final record in records) {
      if (record.watchDate.year == clock.year) {
        monthly[record.watchDate.month] = monthly[record.watchDate.month]! + 1;
      }
      final band = TimeOfDayBand.forHour(record.watchDate.hour);
      timeOfDay[band] = timeOfDay[band]! + 1;
      weekdays[record.watchDate.weekday] =
          weekdays[record.watchDate.weekday]! + 1;
      final key = _dateKey(record.watchDate);
      final increment = record.isTv ? record.episodeCount : 1;
      daily[key] = (daily[key] ?? 0) + increment;
      final typedDaily = record.isTv ? dailyTv : dailyMovies;
      typedDaily[key] = (typedDaily[key] ?? 0) + increment;
      final rounded = record.rating.round().clamp(1, 10);
      ratings[rounded] = ratings[rounded]! + 1;
      final season = Season.forMonth(record.watchDate.month);
      seasons[season] = seasons[season]! + 1;
    }
    for (final date in progressOnlyDates) {
      final key = _dateKey(date);
      daily[key] = (daily[key] ?? 0) + 1;
    }

    final dates = <DateTime>{
      for (final r in records) _day(r.watchDate),
      for (final date in progressOnlyDates) _day(date),
    }.toList()..sort();
    final (currentStreak, longestStreak) = _streaks(dates, clock);

    final mostFrequentRating = ratings.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
    final goldenWeekday = weekdays.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
    final monday = _day(clock).subtract(Duration(days: clock.weekday - 1));

    return InsightsMetrics(
      totalWatchCount: records.length,
      uniqueTitleCount: records.map((r) => (r.tmdbId, r.isTv)).toSet().length,
      totalDurationMinutes: totalDuration,
      averageRating: averageRating,
      topGenres: _countGenres(records),
      topDirectors: _countText(records.map((r) => r.director)),
      topActors: _countText(records.map((r) => r.actors)),
      monthlyWatchTrend: monthly,
      timeOfDayTrend: timeOfDay,
      dayOfWeekTrend: weekdays,
      dailyWatchCounts: daily,
      dailyMovieWatchCounts: dailyMovies,
      dailyTvWatchCounts: dailyTv,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      ratingDistribution: ratings,
      mostFrequentRating: mostFrequentRating,
      seasonalCounts: seasons,
      goldenWeekday: goldenWeekday,
      topTags: _countText(records.map((r) => r.tags)),
      thisWeekWatchCount: records
          .where((r) => !r.watchDate.isBefore(monday))
          .length,
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static (int, int) _streaks(List<DateTime> dates, DateTime now) {
    if (dates.isEmpty) return (0, 0);
    var longest = 1;
    var run = 1;
    for (var i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }
    final set = dates.toSet();
    final today = _day(now);
    final yesterday = today.subtract(const Duration(days: 1));
    var cursor = set.contains(today)
        ? today
        : (set.contains(yesterday) ? yesterday : null);
    var current = 0;
    while (cursor != null && set.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return (current, longest);
  }

  static List<MapEntry<int, int>> _countGenres(List<InsightRecord> records) {
    final counts = <int, int>{};
    for (final record in records) {
      for (final id in record.genreIds) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  static List<MapEntry<String, int>> _countText(Iterable<String?> fields) {
    final counts = <String, int>{};
    for (final field in fields) {
      for (final value in (field ?? '').split(',').map((v) => v.trim())) {
        if (value.isNotEmpty) counts[value] = (counts[value] ?? 0) + 1;
      }
    }
    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }
}
