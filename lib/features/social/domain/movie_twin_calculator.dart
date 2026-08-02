import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';

typedef MovieKey = ({int tmdbId, bool isTv});

/// Represents calculated taste statistics for a user's movie library.
class UserTasteVector {
  const UserTasteVector({
    required this.genreScores,
    required this.directorScores,
    required this.movieRatings,
    required this.topMovieKeys,
  });

  final Map<int, double> genreScores;
  final Map<String, double> directorScores;
  final Map<MovieKey, double> movieRatings;
  final Set<MovieKey> topMovieKeys;

  /// Builds a [UserTasteVector] from a user's watch records, movie settings, and movie metadata.
  factory UserTasteVector.fromData({
    required List<WatchRecord> watchRecords,
    required Map<MovieKey, UserMovieSetting> settings,
    required Map<MovieKey, Movie> movies,
  }) {
    final genreCounts = <int, int>{};
    final genreRatingSums = <int, double>{};
    final directorCounts = <String, int>{};
    final directorRatingSums = <String, double>{};
    final movieRatings = <MovieKey, double>{};
    final topMovieKeys = <MovieKey>{};

    for (final record in watchRecords) {
      final key = (tmdbId: record.movieId, isTv: record.isTv);
      final rating = record.rating;
      movieRatings[key] = rating;

      if (rating >= 7.5) {
        topMovieKeys.add(key);
      }

      final movie = movies[key];
      if (movie != null) {
        // Process genres
        if (movie.genreIds != null && movie.genreIds!.isNotEmpty) {
          final gIds = movie.genreIds!
              .split(',')
              .map((s) => int.tryParse(s.trim()))
              .whereType<int>();
          for (final gId in gIds) {
            genreCounts[gId] = (genreCounts[gId] ?? 0) + 1;
            genreRatingSums[gId] = (genreRatingSums[gId] ?? 0.0) + rating;
          }
        }

        // Process director
        if (movie.director != null && movie.director!.trim().isNotEmpty) {
          final director = movie.director!.trim();
          directorCounts[director] = (directorCounts[director] ?? 0) + 1;
          directorRatingSums[director] = (directorRatingSums[director] ?? 0.0) + rating;
        }
      }
    }

    // Include favorited items in topMovieKeys
    for (final entry in settings.entries) {
      if (entry.value.isFavorite) {
        topMovieKeys.add(entry.key);
      }
    }

    // Normalize genre scores: average rating * log(1 + count)
    final genreScores = <int, double>{};
    genreRatingSums.forEach((gId, sum) {
      final count = genreCounts[gId] ?? 1;
      final avg = sum / count;
      genreScores[gId] = avg * math.log(1 + count);
    });

    // Normalize director scores
    final directorScores = <String, double>{};
    directorRatingSums.forEach((director, sum) {
      final count = directorCounts[director] ?? 1;
      final avg = sum / count;
      directorScores[director] = avg * math.log(1 + count);
    });

    return UserTasteVector(
      genreScores: genreScores,
      directorScores: directorScores,
      movieRatings: movieRatings,
      topMovieKeys: topMovieKeys,
    );
  }
}

/// Detailed result of comparing two users' movie taste vectors.
@immutable
class MovieTwinMatchResult {
  const MovieTwinMatchResult({
    required this.matchPercentage,
    required this.sharedTopMovieKeys,
    required this.sharedGenreIds,
    required this.sharedDirectors,
    required this.recommendationsFromTwin,
  });

  final int matchPercentage;
  final List<MovieKey> sharedTopMovieKeys;
  final List<int> sharedGenreIds;
  final List<String> sharedDirectors;
  final List<MovieKey> recommendationsFromTwin;
}

/// Pure domain calculator for computing AI Movie Twin match metrics.
class MovieTwinCalculator {
  const MovieTwinCalculator();

  /// Calculates the compatibility score between user A (current user) and user B (twin target).
  MovieTwinMatchResult calculateMatch({
    required UserTasteVector userA,
    required UserTasteVector userB,
  }) {
    if (userA.movieRatings.isEmpty || userB.movieRatings.isEmpty) {
      return const MovieTwinMatchResult(
        matchPercentage: 0,
        sharedTopMovieKeys: [],
        sharedGenreIds: [],
        sharedDirectors: [],
        recommendationsFromTwin: [],
      );
    }

    // 1. Genre Cosine Similarity (Weight: 45%)
    final genreSim = _calculateCosineSimilarity(userA.genreScores, userB.genreScores);

    // 2. Rating Correlation on Overlapping Movies (Weight: 40%)
    final overlappingKeys = userA.movieRatings.keys
        .where((k) => userB.movieRatings.containsKey(k))
        .toList();

    double ratingSim = 0.5; // Neutral baseline if no overlapping movies
    if (overlappingKeys.isNotEmpty) {
      double totalDiff = 0;
      for (final key in overlappingKeys) {
        final rA = userA.movieRatings[key]!;
        final rB = userB.movieRatings[key]!;
        totalDiff += (rA - rB).abs();
      }
      final avgDiff = totalDiff / overlappingKeys.length;
      ratingSim = (1.0 - (avgDiff / 10.0)).clamp(0.0, 1.0);
    }

    // 3. Director Overlap (Weight: 15%)
    final directorSim = _calculateJaccardSimilarity(
      userA.directorScores.keys.toSet(),
      userB.directorScores.keys.toSet(),
    );

    // Combined score calculation (range 0.0 to 100.0)
    final rawScore = (genreSim * 0.45 + ratingSim * 0.40 + directorSim * 0.15) * 100;
    final matchPercentage = rawScore.round().clamp(0, 100);

    // Identify shared top movies
    final sharedTopMovieKeys = userA.topMovieKeys
        .intersection(userB.topMovieKeys)
        .toList();

    // Identify shared genres (sorted by combined score)
    final sharedGenreIds = userA.genreScores.keys
        .where((g) => userB.genreScores.containsKey(g))
        .toList()
      ..sort((a, b) =>
          ((userB.genreScores[b]! + userA.genreScores[b]!) -
                  (userB.genreScores[a]! + userA.genreScores[a]!))
              .toInt());

    // Identify shared directors
    final sharedDirectors = userA.directorScores.keys
        .where((d) => userB.directorScores.containsKey(d))
        .toList();

    // Twin recommendations: Movies rated >= 8.0 by Twin (B) that User A hasn't watched
    final recommendationsFromTwin = userB.topMovieKeys
        .where((k) => !userA.movieRatings.containsKey(k))
        .toList();

    return MovieTwinMatchResult(
      matchPercentage: matchPercentage,
      sharedTopMovieKeys: sharedTopMovieKeys,
      sharedGenreIds: sharedGenreIds,
      sharedDirectors: sharedDirectors,
      recommendationsFromTwin: recommendationsFromTwin,
    );
  }

  double _calculateCosineSimilarity(Map<dynamic, double> vecA, Map<dynamic, double> vecB) {
    if (vecA.isEmpty || vecB.isEmpty) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (final v in vecA.values) {
      normA += v * v;
    }
    for (final v in vecB.values) {
      normB += v * v;
    }

    if (normA == 0 || normB == 0) return 0.0;

    for (final entry in vecA.entries) {
      final key = entry.key;
      if (vecB.containsKey(key)) {
        dotProduct += entry.value * vecB[key]!;
      }
    }

    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  double _calculateJaccardSimilarity(Set<dynamic> setA, Set<dynamic> setB) {
    if (setA.isEmpty && setB.isEmpty) return 0.0;
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    if (union == 0) return 0.0;
    return intersection / union;
  }
}
