import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/features/social/domain/movie_twin_calculator.dart';

void main() {
  group('MovieTwinCalculator & UserTasteVector Tests', () {
    test('UserTasteVector correctly extracts genres and top movies', () {
      final records = [
        WatchRecord(
          id: 1,
          movieId: 101,
          isTv: false,
          watchDate: DateTime.now(),
          rating: 9.0,
          watchNumber: 1,
          episodeCount: 1,
          createdAt: DateTime.now(),
          isPublic: true,
        ),
      ];

      final movies = {
        (tmdbId: 101, isTv: false): Movie(
          tmdbId: 101,
          title: 'Inception',
          originalTitle: 'Inception',
          isTv: false,
          genres: 'Aksiyon, Bilim Kurgu',
          genreIds: '28,878',
          director: 'Christopher Nolan',
          createdAt: DateTime.now(),
        ),
      };

      final settings = <MovieKey, UserMovieSetting>{};

      final tasteVector = UserTasteVector.fromData(
        watchRecords: records,
        settings: settings,
        movies: movies,
      );

      expect(tasteVector.genreScores.containsKey(28), isTrue);
      expect(tasteVector.genreScores.containsKey(878), isTrue);
      expect(tasteVector.directorScores.containsKey('Christopher Nolan'), isTrue);
      expect(tasteVector.topMovieKeys.contains((tmdbId: 101, isTv: false)), isTrue);
    });

    test('Identical taste vectors produce high match percentage', () {
      final records = [
        WatchRecord(
          id: 1,
          movieId: 101,
          isTv: false,
          watchDate: DateTime.now(),
          rating: 9.0,
          watchNumber: 1,
          episodeCount: 1,
          createdAt: DateTime.now(),
          isPublic: true,
        ),
      ];

      final movies = {
        (tmdbId: 101, isTv: false): Movie(
          tmdbId: 101,
          title: 'Inception',
          originalTitle: 'Inception',
          isTv: false,
          genres: 'Aksiyon, Bilim Kurgu',
          genreIds: '28,878',
          director: 'Christopher Nolan',
          createdAt: DateTime.now(),
        ),
      };

      final tasteA = UserTasteVector.fromData(
        watchRecords: records,
        settings: {},
        movies: movies,
      );

      const calculator = MovieTwinCalculator();
      final match = calculator.calculateMatch(userA: tasteA, userB: tasteA);

      expect(match.matchPercentage, equals(100));
      expect(match.sharedGenreIds, containsAll([28, 878]));
      expect(match.sharedDirectors, contains('Christopher Nolan'));
    });

    test('Empty vectors return 0% match percentage', () {
      final emptyTaste = UserTasteVector.fromData(
        watchRecords: [],
        settings: {},
        movies: {},
      );

      const calculator = MovieTwinCalculator();
      final match = calculator.calculateMatch(userA: emptyTaste, userB: emptyTaste);

      expect(match.matchPercentage, equals(0));
      expect(match.sharedTopMovieKeys, isEmpty);
    });
  });
}
