class RecommendationItem {
  final int tmdbId;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final bool isTv;
  final String reason; // E.g., "Nolan Yönettiği İçin"

  const RecommendationItem({
    required this.tmdbId,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.isTv,
    required this.reason,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json, {required String reason, bool? isTvOverride}) {
    final isTv = isTvOverride ?? (json['media_type'] == 'tv');
    return RecommendationItem(
      tmdbId: json['id'] as int,
      title: (isTv ? (json['name'] ?? json['original_name']) : (json['title'] ?? json['original_title'])) as String? ?? 'Bilinmeyen Yapım',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      isTv: isTv,
      reason: reason,
    );
  }
}
