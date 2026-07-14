// Pure episode-count/progress bookkeeping for AddWatchRecordSheet's
// _saveRecord, extracted because none of it touches ref/context/State —
// just the sheet's current field values in, the record's episodeCount plus
// the show's new isActivelyWatching/lastWatchedEpisode out.
class WatchRecordEpisodeFields {
  final int episodeCount;
  final bool isActivelyWatching;
  final int? lastWatchedEpisode;

  const WatchRecordEpisodeFields({
    required this.episodeCount,
    required this.isActivelyWatching,
    required this.lastWatchedEpisode,
  });
}

WatchRecordEpisodeFields computeWatchRecordEpisodeFields({
  required bool isTv,
  required bool isActivelyWatching,
  required bool finishedWholeShow,
  required int episodeCount,
  required int selectedEpisode,
  required int? totalEpisodes,
  required int? lastWatchedEpisode,
}) {
  if (!isTv) {
    return WatchRecordEpisodeFields(
      episodeCount: episodeCount,
      isActivelyWatching: false,
      lastWatchedEpisode: lastWatchedEpisode,
    );
  }

  if (isActivelyWatching) {
    final selected = totalEpisodes != null ? selectedEpisode.clamp(1, totalEpisodes) : selectedEpisode;
    return WatchRecordEpisodeFields(
      episodeCount: (selected - (lastWatchedEpisode ?? 0)).clamp(1, selected),
      lastWatchedEpisode: selected,
      isActivelyWatching: totalEpisodes == null || selected < totalEpisodes,
    );
  }

  if (finishedWholeShow && totalEpisodes != null) {
    final selected = totalEpisodes;
    return WatchRecordEpisodeFields(
      episodeCount: (selected - (lastWatchedEpisode ?? 0)).clamp(1, selected),
      lastWatchedEpisode: selected,
      isActivelyWatching: false,
    );
  }

  final count = totalEpisodes != null ? episodeCount.clamp(1, totalEpisodes) : episodeCount;
  return WatchRecordEpisodeFields(
    episodeCount: count,
    lastWatchedEpisode: count,
    isActivelyWatching: false,
  );
}
