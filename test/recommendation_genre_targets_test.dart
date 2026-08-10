import 'package:cinefile/features/recommendations/presentation/recommendations_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds separate movie and TV targets for each learned genre', () {
    final targets = recommendationGenreTargets([18, 10759, -1]);

    expect(targets, [
      (genreId: 18, isTv: false),
      (genreId: 18, isTv: true),
      (genreId: 10759, isTv: true),
    ]);
  });
}
