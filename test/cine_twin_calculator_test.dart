import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/l10n/app_localizations.dart';
import 'package:cinefile/l10n/app_localizations_en.dart';
import 'package:cinefile/features/relationship_graph/domain/cine_twin_calculator.dart';

/// Recommendation reasons are localized, so the calculator takes an
/// AppLocalizations. These tests assert scores, not copy.
final AppLocalizations _l10n = AppLocalizationsEn();

void main() {
  group('CineTwinCalculator Tests', () {
    test('Empty watch histories return 0% match percentage', () {
      final result = CineTwinCalculator.calculate(
        userALogs: [
          const CineTwinUserRecord(
            tmdbId: 101,
            title: 'Inception',
            rating: 9.0,
          ),
        ],
        userBLogs: [],
        userAName: 'Sen',
        userBName: '@Şüko35',
        l10n: _l10n,
      );

      expect(result.matchPercentage, equals(0));
      expect(result.sharedCount, equals(0));
      expect(result.ratingDisputes, isEmpty);
      expect(result.recommendations, isEmpty);
      expect(result.badge, equals(CineTwinBadge.opposites));
    });

    test(
      'Identical watch histories with high ratings return top match score and soulmates badge',
      () {
        final logsA = [
          const CineTwinUserRecord(
            tmdbId: 101,
            title: 'Inception',
            rating: 9.0,
            genres: ['Bilim Kurgu', 'Aksiyon'],
          ),
          const CineTwinUserRecord(
            tmdbId: 102,
            title: 'Interstellar',
            rating: 9.5,
            genres: ['Bilim Kurgu', 'Drama'],
          ),
          const CineTwinUserRecord(
            tmdbId: 103,
            title: 'The Dark Knight',
            rating: 10.0,
            genres: ['Aksiyon', 'Suç'],
          ),
        ];

        final result = CineTwinCalculator.calculate(
          userALogs: logsA,
          userBLogs: logsA,
          userAName: 'Ahmet',
          userBName: 'Mehmet',
          l10n: _l10n,
        );

        expect(result.matchPercentage, greaterThanOrEqualTo(85));
        expect(result.badge, equals(CineTwinBadge.soulmates));
        expect(result.sharedCount, equals(3));
        expect(result.ratingDisputes, isEmpty);
        expect(result.sharedFavorites.length, equals(3));
      },
    );

    test('Disagreeing ratings create disputes list', () {
      final logsA = [
        const CineTwinUserRecord(tmdbId: 101, title: 'Movie A', rating: 10.0),
        const CineTwinUserRecord(tmdbId: 102, title: 'Movie B', rating: 9.0),
      ];
      final logsB = [
        const CineTwinUserRecord(tmdbId: 101, title: 'Movie A', rating: 2.0),
        const CineTwinUserRecord(tmdbId: 102, title: 'Movie B', rating: 8.5),
      ];

      final result = CineTwinCalculator.calculate(
        userALogs: logsA,
        userBLogs: logsB,
        userAName: 'UserA',
        userBName: 'UserB',
        l10n: _l10n,
      );

      expect(result.ratingDisputes.length, equals(1));
      expect(result.ratingDisputes.first.recordA.tmdbId, equals(101));
      expect(result.ratingDisputes.first.ratingDifference, equals(8.0));
    });

    test('Recommends highly rated unwatched movies from B to A', () {
      final logsA = [
        const CineTwinUserRecord(tmdbId: 101, title: 'Movie A', rating: 9.0),
      ];
      final logsB = [
        const CineTwinUserRecord(tmdbId: 101, title: 'Movie A', rating: 9.0),
        const CineTwinUserRecord(
          tmdbId: 201,
          title: 'Recommended Movie',
          rating: 9.5,
        ),
      ];

      final result = CineTwinCalculator.calculate(
        userALogs: logsA,
        userBLogs: logsB,
        userAName: 'UserA',
        userBName: 'UserB',
        l10n: _l10n,
      );

      expect(result.recommendations.length, equals(1));
      expect(result.recommendations.first.tmdbId, equals(201));
      expect(result.recommendations.first.title, equals('Recommended Movie'));
    });

    test('opted-in swipe genres can create a privacy-safe taste match', () {
      final result = CineTwinCalculator.calculate(
        userALogs: const [],
        userBLogs: const [],
        userAName: 'UserA',
        userBName: 'UserB',
        userATasteGenres: const ['Science Fiction', 'Drama'],
        userBTasteGenres: const ['Science Fiction', 'Drama'],
        l10n: _l10n,
      );

      expect(result.matchPercentage, 30);
      expect(
        result.sharedGenres.keys,
        containsAll(['Science Fiction', 'Drama']),
      );
      expect(result.sharedCount, 0);
    });
  });
}
