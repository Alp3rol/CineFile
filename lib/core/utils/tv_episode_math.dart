// Pure helpers for mapping between TMDb's per-season episode numbering and
// a single "overall" sequential episode index (used by UserMovieSettings.
// lastWatchedEpisode, which counts episodes across all regular seasons as
// one running total). Shared by the episode guide UI
// (tv_episodes_section.dart) and NotificationService's next-episode
// reminder scheduling, so the two stay consistent instead of drifting.

// Seasons with a positive season_number (excludes TMDb "Specials", which
// use season_number 0), sorted ascending by season_number. TMDb usually
// returns seasons in order already, but the cumulative episode-count math
// below depends on it, so sort explicitly rather than assume.
List<dynamic> sortedRegularSeasons(List<dynamic> seasons) {
  final result = seasons.where((s) => (s['season_number'] as int? ?? 0) > 0).toList();
  result.sort((a, b) => (a['season_number'] as int? ?? 0).compareTo(b['season_number'] as int? ?? 0));
  return result;
}

// Maps a season number and in-season episode number to a single overall
// sequential index. [sortedSeasons] must already be sorted (see
// sortedRegularSeasons above) and each entry must carry an episode_count.
int calculateOverallEpisodeNumber(List<dynamic> sortedSeasons, int seasonNumber, int episodeNumber) {
  int count = 0;
  for (final season in sortedSeasons) {
    final sNum = season['season_number'] as int? ?? 1;
    if (sNum < seasonNumber) {
      count += season['episode_count'] as int? ?? 0;
    }
  }
  return count + episodeNumber;
}

// The reverse of calculateOverallEpisodeNumber: maps an overall sequential
// episode index back to its (seasonNumber, episodeNumberInSeason). Returns
// null if the index falls beyond the last episode of the last season (e.g.
// the show has been fully watched, or seasons/episode_count data is
// missing/empty).
({int seasonNumber, int episodeNumberInSeason})? mapOverallIndexToSeasonEpisode(
  List<dynamic> sortedSeasons,
  int overallIndex,
) {
  if (overallIndex < 1) return null;
  int consumed = 0;
  for (final season in sortedSeasons) {
    final sNum = season['season_number'] as int? ?? 1;
    final epCount = season['episode_count'] as int? ?? 0;
    if (overallIndex <= consumed + epCount) {
      return (seasonNumber: sNum, episodeNumberInSeason: overallIndex - consumed);
    }
    consumed += epCount;
  }
  return null;
}
