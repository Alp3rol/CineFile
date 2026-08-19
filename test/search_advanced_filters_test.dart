import 'package:flutter_test/flutter_test.dart';

import 'package:cinefile/features/search/presentation/search_provider.dart';

void main() {
  group('SearchState advanced filters tests', () {
    test('initial state has default filter values', () {
      final state = SearchState.initial();
      expect(state.mediaTypeFilter, 'all');
      expect(state.minRating, isNull);
      expect(state.decadeFilter, isNull);
    });

    test('copyWith updates filters correctly', () {
      final state = SearchState.initial();
      final updated = state.copyWith(
        mediaTypeFilter: 'movie',
        minRating: 8.0,
        decadeFilter: '2020s',
      );

      expect(updated.mediaTypeFilter, 'movie');
      expect(updated.minRating, 8.0);
      expect(updated.decadeFilter, '2020s');

      final cleared = updated.copyWith(
        minRating: null,
        decadeFilter: null,
      );
      expect(cleared.minRating, isNull);
      expect(cleared.decadeFilter, isNull);
    });
  });
}
