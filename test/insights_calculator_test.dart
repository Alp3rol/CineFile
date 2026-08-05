import 'package:cinefile/features/insights/domain/insight_buckets.dart';
import 'package:cinefile/features/insights/domain/insights_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

InsightRecord record({
  required int id,
  required DateTime date,
  bool isTv = false,
  int episodes = 1,
  double rating = 8,
  List<int> genres = const [],
  String? director,
  String? actors,
  String? tags,
}) => InsightRecord(
  tmdbId: id,
  isTv: isTv,
  watchDate: date,
  rating: rating,
  episodeCount: episodes,
  watchNumber: 1,
  runtime: 60,
  genreIds: genres,
  director: director,
  actors: actors,
  tags: tags,
  releaseYear: 2020,
  title: 'Title $id',
  overview: null,
  personalNotes: null,
);

void main() {
  test(
    'calculates summaries and stable id-based rankings without Riverpod',
    () {
      final result = InsightsCalculator.calculate(
        now: DateTime(2026, 8, 5, 12),
        records: [
          record(
            id: 1,
            date: DateTime(2026, 8, 4, 23),
            genres: const [18, 878],
            director: 'Nolan',
            actors: 'A, B',
            tags: 'gece',
            rating: 10,
          ),
          record(
            id: 2,
            date: DateTime(2026, 8, 5, 7),
            isTv: true,
            episodes: 3,
            genres: const [18],
            director: 'Nolan',
            actors: 'B, C',
            tags: 'gece, maraton',
            rating: 6,
          ),
        ],
      );

      expect(result.totalWatchCount, 2);
      expect(result.uniqueTitleCount, 2);
      expect(result.totalDurationMinutes, 240);
      expect(result.averageRating, 8);
      expect(
        (result.topGenres.first.key, result.topGenres.first.value),
        (18, 2),
      );
      expect(
        (result.topDirectors.first.key, result.topDirectors.first.value),
        ('Nolan', 2),
      );
      expect(
        (result.topActors.first.key, result.topActors.first.value),
        ('B', 2),
      );
      expect(
        (result.topTags.first.key, result.topTags.first.value),
        ('gece', 2),
      );
      expect(result.timeOfDayTrend[TimeOfDayBand.evening], 1);
      expect(result.timeOfDayTrend[TimeOfDayBand.morning], 1);
      expect(result.dailyTvWatchCounts['2026-08-05'], 3);
      expect(result.currentStreak, 2);
      expect(result.longestStreak, 2);
      expect(result.thisWeekWatchCount, 2);
    },
  );

  test(
    'progress-only dates extend heatmap and streak without changing watches',
    () {
      final result = InsightsCalculator.calculate(
        now: DateTime(2026, 8, 5),
        records: [record(id: 1, date: DateTime(2026, 8, 3))],
        progressOnlyDates: {DateTime(2026, 8, 4), DateTime(2026, 8, 5)},
      );

      expect(result.totalWatchCount, 1);
      expect(result.dailyWatchCounts, {
        '2026-08-03': 1,
        '2026-08-04': 1,
        '2026-08-05': 1,
      });
      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    },
  );
}
