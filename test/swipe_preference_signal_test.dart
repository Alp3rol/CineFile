import 'package:cinefile/features/recommendations/data/recommendation_model.dart';
import 'package:cinefile/features/swipe_discovery/data/swipe_preference_signal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'right swipes outweigh a single pass and genres are ranked by score',
    () {
      final ranked = rankedSwipeGenreIds(const [
        SwipePreferenceSignal(isInterested: true, genreIds: [878, 18]),
        SwipePreferenceSignal(isInterested: true, genreIds: [878]),
        SwipePreferenceSignal(isInterested: false, genreIds: [878, 18]),
        SwipePreferenceSignal(isInterested: false, genreIds: [35]),
      ]);

      expect(ranked, [878, 18]);
      expect(ranked, isNot(contains(35)));
    },
  );

  test('recommendation conversion preserves TMDb genre identifiers', () {
    final item = RecommendationItem.fromJson(
      {
        'id': 42,
        'title': 'Test',
        'genre_ids': [878, 12],
      },
      reason: 'Test reason',
      fallbackTitle: 'Unknown',
      isTvOverride: false,
    );

    expect(item.genreIds, [878, 12]);
  });

  test(
    'watch history stays foundational while repeated swipes can adapt it',
    () {
      final stable = rankedBlendedGenreIds(
        watchedGenres: const [MapEntry(18, 4), MapEntry(35, 3)],
        swipeSignals: const [
          SwipePreferenceSignal(isInterested: true, genreIds: [878]),
        ],
      );
      expect(stable, [18, 35]);

      final adapted = rankedBlendedGenreIds(
        watchedGenres: const [MapEntry(18, 2), MapEntry(35, 1)],
        swipeSignals: const [
          SwipePreferenceSignal(isInterested: true, genreIds: [878]),
          SwipePreferenceSignal(isInterested: true, genreIds: [878]),
          SwipePreferenceSignal(isInterested: true, genreIds: [878]),
          SwipePreferenceSignal(isInterested: true, genreIds: [878]),
        ],
      );
      expect(adapted, [878, 18]);
    },
  );
}
