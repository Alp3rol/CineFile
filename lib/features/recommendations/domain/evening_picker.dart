import '../data/recommendation_model.dart';

enum EveningMood { exciting, light, thoughtful, emotional }

enum EveningTitleType { any, movie, tv }

class EveningCandidate {
  const EveningCandidate({required this.item, required this.runtimeMinutes});
  final RecommendationItem item;
  final int? runtimeMinutes;
}

class EveningPicker {
  const EveningPicker();

  List<EveningCandidate> select({
    required List<EveningCandidate> candidates,
    required EveningMood mood,
    required EveningTitleType type,
    required int maxMinutes,
  }) {
    final genres = _genresFor(mood);
    final filtered =
        candidates.where((candidate) {
            final item = candidate.item;
            final typeMatches = switch (type) {
              EveningTitleType.any => true,
              EveningTitleType.movie => !item.isTv,
              EveningTitleType.tv => item.isTv,
            };
            final runtime = candidate.runtimeMinutes;
            final durationMatches = runtime == null || runtime <= maxMinutes;
            final moodMatches =
                item.genreIds.isEmpty || item.genreIds.any(genres.contains);
            return typeMatches && durationMatches && moodMatches;
          }).toList()
          ..sort((a, b) => b.item.voteAverage.compareTo(a.item.voteAverage));
    return filtered.take(3).toList(growable: false);
  }

  Set<int> _genresFor(EveningMood mood) => switch (mood) {
    EveningMood.exciting => const {12, 28, 53, 80, 10759},
    EveningMood.light => const {16, 35, 10751, 10762},
    EveningMood.thoughtful => const {18, 36, 99, 878, 9648},
    EveningMood.emotional => const {18, 10749},
  };
}
