import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../auth/controllers/auth_controller.dart';

class SwipePreferenceSignal {
  const SwipePreferenceSignal({
    required this.isInterested,
    required this.genreIds,
    this.key,
  });

  final bool isInterested;
  final List<int> genreIds;
  final MovieKey? key;
}

List<int> rankedSwipeGenreIds(Iterable<SwipePreferenceSignal> signals) {
  final scores = <int, int>{};
  for (final signal in signals) {
    for (final genreId in signal.genreIds) {
      scores.update(
        genreId,
        (score) => score + (signal.isInterested ? 2 : -1),
        ifAbsent: () => signal.isInterested ? 2 : -1,
      );
    }
  }
  final ranked = scores.entries.where((entry) => entry.value > 0).toList()
    ..sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      return byScore != 0 ? byScore : a.key.compareTo(b.key);
    });
  return ranked.map((entry) => entry.key).toList(growable: false);
}

List<int> rankedBlendedGenreIds({
  required Iterable<MapEntry<int, int>> watchedGenres,
  required Iterable<SwipePreferenceSignal> swipeSignals,
  int limit = 2,
}) {
  final scores = <int, int>{};
  for (final genre in watchedGenres) {
    // A completed watch is deliberately stronger than a single card gesture.
    scores[genre.key] = genre.value * 3;
  }
  for (final signal in swipeSignals) {
    for (final genreId in signal.genreIds) {
      scores.update(
        genreId,
        (score) => score + (signal.isInterested ? 2 : -1),
        ifAbsent: () => signal.isInterested ? 2 : -1,
      );
    }
  }
  final ranked = scores.entries.where((entry) => entry.value > 0).toList()
    ..sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      return byScore != 0 ? byScore : a.key.compareTo(b.key);
    });
  return ranked.take(limit).map((entry) => entry.key).toList(growable: false);
}

final swipePreferenceSignalsProvider =
    StreamProvider<List<SwipePreferenceSignal>>((ref) {
      final user = ref.watch(authStateProvider).value;
      if (user == null) return Stream.value(const <SwipePreferenceSignal>[]);

      return ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((document) {
                  final data = document.data();
                  final decision = data['swipeDecision'] as String?;
                  final movieId = (data['movieId'] as num?)?.toInt();
                  if (decision == null || movieId == null) return null;
                  final genreIds =
                      (data['swipeGenreIds'] as List<dynamic>? ?? const [])
                          .whereType<num>()
                          .map((id) => id.toInt())
                          .toList(growable: false);
                  return SwipePreferenceSignal(
                    isInterested: decision == 'interested',
                    genreIds: genreIds,
                    key: (
                      tmdbId: movieId,
                      isTv: data['isTv'] == true || data['isTv'] == 1,
                    ),
                  );
                })
                .whereType<SwipePreferenceSignal>()
                .toList(growable: false),
          );
    });
