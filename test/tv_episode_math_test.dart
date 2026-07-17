import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/utils/tv_episode_math.dart';

const _seasons = [
  {'season_number': 0, 'episode_count': 3, 'name': 'Özel Bölümler'}, // Specials, excluded
  {'season_number': 2, 'episode_count': 3, 'name': '2. Sezon'}, // deliberately out of order
  {'season_number': 1, 'episode_count': 2, 'name': '1. Sezon'},
];

void main() {
  group('sortedRegularSeasons', () {
    test('excludes season 0 (Specials) and sorts ascending by season_number', () {
      final result = sortedRegularSeasons(_seasons);
      expect(result.map((s) => s['season_number']), [1, 2]);
    });

    test('returns an empty list when there are no regular seasons', () {
      expect(sortedRegularSeasons(const [
        {'season_number': 0, 'episode_count': 5},
      ]), isEmpty);
    });
  });

  group('calculateOverallEpisodeNumber', () {
    test('maps season 1 episodes directly', () {
      final sorted = sortedRegularSeasons(_seasons);
      expect(calculateOverallEpisodeNumber(sorted, 1, 1), 1);
      expect(calculateOverallEpisodeNumber(sorted, 1, 2), 2);
    });

    test('offsets season 2 episodes by season 1\'s episode_count', () {
      final sorted = sortedRegularSeasons(_seasons);
      expect(calculateOverallEpisodeNumber(sorted, 2, 1), 3);
      expect(calculateOverallEpisodeNumber(sorted, 2, 3), 5);
    });
  });

  group('mapOverallIndexToSeasonEpisode', () {
    test('maps indices within season 1', () {
      final sorted = sortedRegularSeasons(_seasons);
      expect(mapOverallIndexToSeasonEpisode(sorted, 1), (seasonNumber: 1, episodeNumberInSeason: 1));
      expect(mapOverallIndexToSeasonEpisode(sorted, 2), (seasonNumber: 1, episodeNumberInSeason: 2));
    });

    test('maps indices into season 2 (first and last episode)', () {
      final sorted = sortedRegularSeasons(_seasons);
      expect(mapOverallIndexToSeasonEpisode(sorted, 3), (seasonNumber: 2, episodeNumberInSeason: 1));
      expect(mapOverallIndexToSeasonEpisode(sorted, 5), (seasonNumber: 2, episodeNumberInSeason: 3));
    });

    test('is the exact inverse of calculateOverallEpisodeNumber across the full range', () {
      final sorted = sortedRegularSeasons(_seasons);
      for (var overall = 1; overall <= 5; overall++) {
        final mapping = mapOverallIndexToSeasonEpisode(sorted, overall)!;
        expect(
          calculateOverallEpisodeNumber(sorted, mapping.seasonNumber, mapping.episodeNumberInSeason),
          overall,
        );
      }
    });

    test('returns null when the index is beyond the last episode', () {
      final sorted = sortedRegularSeasons(_seasons);
      expect(mapOverallIndexToSeasonEpisode(sorted, 6), isNull);
    });

    test('returns null for a non-positive index', () {
      final sorted = sortedRegularSeasons(_seasons);
      expect(mapOverallIndexToSeasonEpisode(sorted, 0), isNull);
      expect(mapOverallIndexToSeasonEpisode(sorted, -1), isNull);
    });

    test('returns null when the seasons list is empty', () {
      expect(mapOverallIndexToSeasonEpisode(const [], 1), isNull);
    });
  });
}
