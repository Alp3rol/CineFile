import '../data/recommendation_model.dart';

enum EveningMood { exciting, light, thoughtful, emotional }

enum EveningTitleType { any, movie, tv }

class EveningCandidate {
  const EveningCandidate({
    required this.item,
    required this.runtimeMinutes,
    this.providerNames = const {},
  });
  final RecommendationItem item;
  final int? runtimeMinutes;
  final Set<String> providerNames;
}

class EveningPicker {
  const EveningPicker();

  List<EveningCandidate> select({
    required List<EveningCandidate> candidates,
    required EveningMood mood,
    required EveningTitleType type,
    required int maxMinutes,
    String? providerName,
    Set<int> excludedIds = const {},
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
            final providerMatches =
                providerName == null ||
                candidate.providerNames.contains(providerName);
            final moodMatches =
                item.genreIds.isEmpty || item.genreIds.any(genres.contains);
            return !excludedIds.contains(item.tmdbId) &&
                typeMatches &&
                durationMatches &&
                providerMatches &&
                moodMatches;
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
