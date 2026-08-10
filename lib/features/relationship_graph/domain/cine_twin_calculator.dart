import '../../../l10n/app_localizations.dart';
import 'dart:math' as math;

/// Single movie/tv watch record input for CineTwin calculation.
class CineTwinUserRecord {
  final int tmdbId;
  final String title;
  final bool isTv;
  final String? posterPath;
  final double? rating;
  final String? director;
  final List<String> genres;

  const CineTwinUserRecord({
    required this.tmdbId,
    required this.title,
    this.isTv = false,
    this.posterPath,
    this.rating,
    this.director,
    this.genres = const [],
  });
}

/// Compatibility status badge based on overall match percentage.
enum CineTwinBadge {
  soulmates('🌌'),
  buddies('🎬'),
  genreMatch('🎭'),
  complements('⚖️'),
  opposites('⚡');

  final String emoji;

  const CineTwinBadge(this.emoji);

  factory CineTwinBadge.fromScore(int score) {
    if (score >= 85) return CineTwinBadge.soulmates;
    if (score >= 70) return CineTwinBadge.buddies;
    if (score >= 50) return CineTwinBadge.genreMatch;
    if (score >= 25) return CineTwinBadge.complements;
    return CineTwinBadge.opposites;
  }
}

extension CineTwinBadgeLabels on CineTwinBadge {
  String title(AppLocalizations l10n) => switch (this) {
    CineTwinBadge.soulmates => l10n.cineTwinBadgeSoulmatesTitle,
    CineTwinBadge.buddies => l10n.cineTwinBadgeBuddiesTitle,
    CineTwinBadge.genreMatch => l10n.cineTwinBadgeGenreMatchTitle,
    CineTwinBadge.complements => l10n.cineTwinBadgeComplementsTitle,
    CineTwinBadge.opposites => l10n.cineTwinBadgeOppositesTitle,
  };

  String description(AppLocalizations l10n) => switch (this) {
    CineTwinBadge.soulmates => l10n.cineTwinBadgeSoulmatesDescription,
    CineTwinBadge.buddies => l10n.cineTwinBadgeBuddiesDescription,
    CineTwinBadge.genreMatch => l10n.cineTwinBadgeGenreMatchDescription,
    CineTwinBadge.complements => l10n.cineTwinBadgeComplementsDescription,
    CineTwinBadge.opposites => l10n.cineTwinBadgeOppositesDescription,
  };
}

/// Rating disagreement item for shared watch titles.
class CineTwinDispute {
  final CineTwinUserRecord recordA;
  final CineTwinUserRecord recordB;
  final double ratingDifference;

  const CineTwinDispute({
    required this.recordA,
    required this.recordB,
    required this.ratingDifference,
  });
}

/// Movie recommendation produced by cross-matching both watch histories.
class CineTwinRecommendation {
  final int tmdbId;
  final String title;
  final bool isTv;
  final String? posterPath;
  final String reason;
  final double? ratingByFriend;

  const CineTwinRecommendation({
    required this.tmdbId,
    required this.title,
    required this.isTv,
    this.posterPath,
    required this.reason,
    this.ratingByFriend,
  });
}

/// Full computed CineTwin analytical result.
class CineTwinResult {
  final int matchPercentage;
  final CineTwinBadge badge;
  final int sharedCount;
  final List<CineTwinUserRecord> sharedFavorites;
  final List<CineTwinDispute> ratingDisputes;
  final List<CineTwinRecommendation> recommendations;
  final Map<String, int> sharedGenres;

  const CineTwinResult({
    required this.matchPercentage,
    required this.badge,
    required this.sharedCount,
    required this.sharedFavorites,
    required this.ratingDisputes,
    required this.recommendations,
    required this.sharedGenres,
  });
}

/// Calculator engine for CineTwin compatibility score & recommendations.
class CineTwinCalculator {
  CineTwinCalculator._();

  static CineTwinResult calculate({
    required List<CineTwinUserRecord> userALogs,
    required List<CineTwinUserRecord> userBLogs,
    required String userAName,
    required String userBName,
    List<String> userATasteGenres = const [],
    List<String> userBTasteGenres = const [],

    /// Recommendation reasons are sentences, so the calculator needs the
    /// user's language; the provider resolves it and passes it in.
    required AppLocalizations l10n,
  }) {
    // If either user has no records, match is 0%
    final userAHasTaste = userALogs.isNotEmpty || userATasteGenres.isNotEmpty;
    final userBHasTaste = userBLogs.isNotEmpty || userBTasteGenres.isNotEmpty;
    if (!userAHasTaste || !userBHasTaste) {
      return CineTwinResult(
        matchPercentage: 0,
        badge: CineTwinBadge.opposites,
        sharedCount: 0,
        sharedFavorites: const [],
        ratingDisputes: const [],
        recommendations: const [],
        sharedGenres: const {},
      );
    }

    final mapA = <int, CineTwinUserRecord>{
      for (final r in userALogs) r.tmdbId: r,
    };
    final mapB = <int, CineTwinUserRecord>{
      for (final r in userBLogs) r.tmdbId: r,
    };

    final sharedIds = mapA.keys.toSet().intersection(mapB.keys.toSet());
    final allIds = mapA.keys.toSet().union(mapB.keys.toSet());

    // 1. Overlap Score (25% weight if shared titles exist, else 0%)
    final overlapRatio = allIds.isEmpty
        ? 0.0
        : (sharedIds.length / allIds.length);

    // 2. Rating Correlation / Similarity (45% weight if shared titles exist, else 0%)
    double ratingSimilarity = 0.0;
    final disputes = <CineTwinDispute>[];
    final sharedFavs = <CineTwinUserRecord>[];

    if (sharedIds.isNotEmpty) {
      double totalDiff = 0;
      int ratedCount = 0;

      for (final id in sharedIds) {
        final recA = mapA[id]!;
        final recB = mapB[id]!;

        if (recA.rating != null && recB.rating != null) {
          final diff = (recA.rating! - recB.rating!).abs();
          totalDiff += diff;
          ratedCount++;

          if (diff >= 2.5) {
            disputes.add(
              CineTwinDispute(
                recordA: recA,
                recordB: recB,
                ratingDifference: diff,
              ),
            );
          }

          if (recA.rating! >= 7.5 && recB.rating! >= 7.5) {
            sharedFavs.add(recA);
          }
        } else {
          sharedFavs.add(recA);
        }
      }

      if (ratedCount > 0) {
        final avgDiff = totalDiff / ratedCount;
        ratingSimilarity = (1.0 - (avgDiff / 9.0)).clamp(0.0, 1.0);
      } else {
        ratingSimilarity = 0.8; // Shared movies exist but no ratings given yet
      }
    }

    // Sort disputes by biggest difference descending
    disputes.sort((a, b) => b.ratingDifference.compareTo(a.ratingDifference));

    // 3. Genre Affinity (30% weight)
    final genresA = _extractGenreCounts(userALogs);
    final genresB = _extractGenreCounts(userBLogs);
    for (final genre in userATasteGenres) {
      genresA[genre] = (genresA[genre] ?? 0) + 1;
    }
    for (final genre in userBTasteGenres) {
      genresB[genre] = (genresB[genre] ?? 0) + 1;
    }
    final genreSimilarity = _computeJaccardGenreSimilarity(genresA, genresB);

    // Combine Weighted Score
    double totalScore;
    if (sharedIds.isNotEmpty) {
      totalScore =
          (overlapRatio * 0.25) +
          (ratingSimilarity * 0.45) +
          (genreSimilarity * 0.30);
    } else {
      // 0 shared movies: score comes strictly from shared genre overlap (max 30%)
      totalScore = genreSimilarity * 0.30;
    }

    // Normalize to percentage between 0% and 99%
    int percentage = (totalScore * 100).round().clamp(0, 99);

    if (sharedIds.length >= 5 && disputes.isEmpty && ratingSimilarity > 0.85) {
      percentage = math.min(99, percentage + 5);
    }

    final badge = CineTwinBadge.fromScore(percentage);

    // 4. Generate Recommendations (Cross-Match)
    final recs = <CineTwinRecommendation>[];

    // High rated by B, not seen by A
    for (final recB in userBLogs) {
      if (!mapA.containsKey(recB.tmdbId) &&
          (recB.rating == null || recB.rating! >= 7.5)) {
        recs.add(
          CineTwinRecommendation(
            tmdbId: recB.tmdbId,
            title: recB.title,
            isTv: recB.isTv,
            posterPath: recB.posterPath,
            reason: recB.rating != null
                ? l10n.cineTwinReasonRated(
                    userBName,
                    recB.rating!.toStringAsFixed(1),
                  )
                : l10n.cineTwinReasonRatedHighly(userBName),
            ratingByFriend: recB.rating,
          ),
        );
      }
    }

    // Shared top genres map for UI breakdown
    final sharedGenres = <String, int>{};
    for (final g in genresA.keys) {
      if (genresB.containsKey(g)) {
        sharedGenres[g] = (genresA[g]! + genresB[g]!);
      }
    }

    return CineTwinResult(
      matchPercentage: percentage,
      badge: badge,
      sharedCount: sharedIds.length,
      sharedFavorites: sharedFavs.take(6).toList(),
      ratingDisputes: disputes.take(4).toList(),
      recommendations: recs.take(8).toList(),
      sharedGenres: sharedGenres,
    );
  }

  static Map<String, int> _extractGenreCounts(
    List<CineTwinUserRecord> records,
  ) {
    final counts = <String, int>{};
    for (final r in records) {
      for (final g in r.genres) {
        counts[g] = (counts[g] ?? 0) + 1;
      }
    }
    return counts;
  }

  static double _computeJaccardGenreSimilarity(
    Map<String, int> a,
    Map<String, int> b,
  ) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final keysA = a.keys.toSet();
    final keysB = b.keys.toSet();
    final intersection = keysA.intersection(keysB).length;
    final union = keysA.union(keysB).length;
    return union == 0 ? 0.0 : (intersection / union);
  }
}
