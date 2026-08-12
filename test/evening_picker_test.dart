import 'package:cinefile/features/recommendations/data/recommendation_model.dart';
import 'package:cinefile/features/recommendations/domain/evening_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  EveningCandidate candidate(
    int id, {
    bool isTv = false,
    int runtime = 100,
    double rating = 7,
    List<int> genres = const [28],
    Set<String> providers = const {},
  }) => EveningCandidate(
    runtimeMinutes: runtime,
    providerNames: providers,
    item: RecommendationItem(
      tmdbId: id,
      title: 'Title $id',
      voteAverage: rating,
      isTv: isTv,
      reason: 'reason',
      genreIds: genres,
    ),
  );

  test('filters mood duration and title type', () {
    final results = const EveningPicker().select(
      candidates: [
        candidate(1, runtime: 90),
        candidate(2, runtime: 150),
        candidate(3, isTv: true),
        candidate(4, genres: const [10749]),
      ],
      mood: EveningMood.exciting,
      type: EveningTitleType.movie,
      maxMinutes: 120,
    );

    expect(results.map((item) => item.item.tmdbId), [1]);
  });

  test('returns at most three strongest results', () {
    final results = const EveningPicker().select(
      candidates: [
        candidate(1, rating: 5),
        candidate(2, rating: 9),
        candidate(3, rating: 8),
        candidate(4, rating: 7),
      ],
      mood: EveningMood.exciting,
      type: EveningTitleType.any,
      maxMinutes: 180,
    );

    expect(results.map((item) => item.item.tmdbId), [2, 3, 4]);
  });

  test('filters by provider and excluded feedback ids', () {
    final results = const EveningPicker().select(
      candidates: [
        candidate(1, providers: const {'Netflix'}),
        candidate(2, providers: const {'Netflix'}),
        candidate(3, providers: const {'MUBI'}),
      ],
      mood: EveningMood.exciting,
      type: EveningTitleType.any,
      maxMinutes: 180,
      providerName: 'Netflix',
      excludedIds: const {1},
    );

    expect(results.map((item) => item.item.tmdbId), [2]);
  });
}
