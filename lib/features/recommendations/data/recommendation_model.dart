class RecommendationItem {
  final int tmdbId;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final bool isTv;
  final List<int> genreIds;
  final String reason; // E.g., "Nolan Yönettiği İçin"

  const RecommendationItem({
    required this.tmdbId,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.isTv,
    required this.reason,
    this.genreIds = const [],
  });

  /// [fallbackTitle] is supplied by the caller rather than defaulted here so
  /// this data class stays free of user-facing text.
  factory RecommendationItem.fromJson(
    Map<String, dynamic> json, {
    required String reason,
    required String fallbackTitle,
    bool? isTvOverride,
  }) {
    final isTv = isTvOverride ?? (json['media_type'] == 'tv');
    return RecommendationItem(
      tmdbId: (json['id'] as num).toInt(),
      title:
          (isTv
                  ? (json['name'] ?? json['original_name'])
                  : (json['title'] ?? json['original_title']))
              as String? ??
          fallbackTitle,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      isTv: isTv,
      reason: reason,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((id) => id.toInt())
          .toList(growable: false),
    );
  }
}
