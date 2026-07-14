import '../../../core/database/database_provider.dart';

// Filtering, insights-stat calculation, table-view sorting and drag-reorder
// rank recomputation for JournalScreen — pulled out of the widget because
// none of it touches BuildContext/State, only plain data in/data out.

List<WatchRecordWithMovie> filterJournalRecords({
  required List<WatchRecordWithMovie> records,
  required String activeFilter,
  required Set<MovieKey> favorites,
  required String searchQuery,
}) {
  var filtered = records;
  if (activeFilter == 'favorites') {
    filtered = filtered.where((r) => favorites.contains((tmdbId: r.movie.tmdbId, isTv: r.movie.isTv))).toList();
  } else if (activeFilter == 'cinema') {
    filtered = filtered.where((r) => r.record.watchPlace?.toLowerCase().contains('sinema') ?? false).toList();
  } else if (activeFilter == 'notes') {
    filtered = filtered.where((r) => r.record.notes != null && r.record.notes!.trim().isNotEmpty).toList();
  }

  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((r) {
      final title = r.movie.title.toLowerCase();
      final dir = r.movie.director?.toLowerCase() ?? '';
      final actor = r.movie.actors?.toLowerCase() ?? '';
      final note = r.record.notes?.toLowerCase() ?? '';
      final place = r.record.watchPlace?.toLowerCase() ?? '';
      final comp = r.record.watchCompanion?.toLowerCase() ?? '';
      final tags = r.record.tags?.toLowerCase() ?? '';
      return title.contains(searchQuery) ||
          dir.contains(searchQuery) ||
          actor.contains(searchQuery) ||
          note.contains(searchQuery) ||
          place.contains(searchQuery) ||
          comp.contains(searchQuery) ||
          tags.contains(searchQuery);
    }).toList();
  }

  return filtered;
}

class JournalInsightsStats {
  final int thisMonthCount;
  final double avgRating;
  final String favoriteGenre;
  final int totalHours;
  final int totalRemainingMinutes;

  const JournalInsightsStats({
    required this.thisMonthCount,
    required this.avgRating,
    required this.favoriteGenre,
    required this.totalHours,
    required this.totalRemainingMinutes,
  });
}

JournalInsightsStats computeJournalInsights(List<WatchRecordWithMovie> filtered) {
  final now = DateTime.now();
  final thisMonthCount =
      filtered.where((r) => r.record.watchDate.year == now.year && r.record.watchDate.month == now.month).length;

  double avgRating = 0.0;
  if (filtered.isNotEmpty) {
    final totalRating = filtered.map((r) => r.record.rating).reduce((a, b) => a + b);
    avgRating = totalRating / filtered.length;
  }

  int totalRuntimeMinutes = 0;
  for (final item in filtered) {
    totalRuntimeMinutes += (item.movie.runtime ?? 0) * item.record.episodeCount;
  }
  final totalHours = totalRuntimeMinutes ~/ 60;
  final totalRemainingMinutes = totalRuntimeMinutes % 60;

  String favoriteGenre = 'Belirsiz';
  if (filtered.isNotEmpty) {
    final genreCounts = <String, int>{};
    for (final item in filtered) {
      final genresList = item.movie.genres?.split(', ') ?? [];
      for (final g in genresList) {
        if (g.trim().isNotEmpty) {
          genreCounts[g] = (genreCounts[g] ?? 0) + 1;
        }
      }
    }
    if (genreCounts.isNotEmpty) {
      final sortedGenres = genreCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      favoriteGenre = sortedGenres.first.key;
    }
  }

  return JournalInsightsStats(
    thisMonthCount: thisMonthCount,
    avgRating: avgRating,
    favoriteGenre: favoriteGenre,
    totalHours: totalHours,
    totalRemainingMinutes: totalRemainingMinutes,
  );
}

// Sorts `filtered` in place for the table view (personal ranking / title /
// rating / date columns).
void sortJournalRecordsForTableView(
  List<WatchRecordWithMovie> filtered, {
  required String sortColumn,
  required bool sortAscending,
}) {
  final latestWatchIds = <MovieKey, int>{};
  final latestWatches = <MovieKey, WatchRecordWithMovie>{};
  for (final r in filtered) {
    final key = (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv);
    final currentLatest = latestWatches[key];
    if (currentLatest == null || r.record.watchDate.isAfter(currentLatest.record.watchDate)) {
      latestWatches[key] = r;
      latestWatchIds[key] = r.record.id;
    }
  }
  filtered.sort((a, b) {
    if (sortColumn == 'title') {
      final cmp = a.movie.title.compareTo(b.movie.title);
      return sortAscending ? cmp : -cmp;
    } else if (sortColumn == 'rating') {
      final cmp = a.record.rating.compareTo(b.record.rating);
      return sortAscending ? cmp : -cmp;
    } else if (sortColumn == 'date') {
      final cmp = a.record.watchDate.compareTo(b.record.watchDate);
      return sortAscending ? cmp : -cmp;
    } else {
      // personal_ranking (default)
      final isLatestA = latestWatchIds[(tmdbId: a.movie.tmdbId, isTv: a.movie.isTv)] == a.record.id;
      final isLatestB = latestWatchIds[(tmdbId: b.movie.tmdbId, isTv: b.movie.isTv)] == b.record.id;

      final rankA = isLatestA ? a.setting?.personalRanking : null;
      final rankB = isLatestB ? b.setting?.personalRanking : null;

      if (rankA != null && rankB != null) {
        final cmp = rankA.compareTo(rankB);
        return sortAscending ? cmp : -cmp;
      } else if (rankA != null) {
        return sortAscending ? -1 : 1;
      } else if (rankB != null) {
        return sortAscending ? 1 : -1;
      } else {
        return b.record.watchDate.compareTo(a.record.watchDate);
      }
    }
  });
}

// Recomputes personal rankings after a drag-reorder in the table view.
// Only the latest watch of each unique movie carries a rank; everything
// else in `list` is left unranked (null).
Map<MovieKey, int?> computeReorderedRankings(
  List<WatchRecordWithMovie> list,
  int oldIndex,
  int newIndex,
) {
  // Find the latest watch record ID for each unique movie (tmdbId, isTv) (based on watchDate)
  final latestWatchIds = <MovieKey, int>{};
  final latestWatches = <MovieKey, WatchRecordWithMovie>{};
  for (final r in list) {
    final key = (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv);
    final currentLatest = latestWatches[key];
    if (currentLatest == null || r.record.watchDate.isAfter(currentLatest.record.watchDate)) {
      latestWatches[key] = r;
      latestWatchIds[key] = r.record.id;
    }
  }

  final updatedList = List<WatchRecordWithMovie>.from(list);
  final movedItem = updatedList.removeAt(oldIndex);
  updatedList.insert(newIndex, movedItem);

  final newRanks = <MovieKey, int?>{};

  // Find the last index of a ranked item in the list BEFORE the move, excluding the moved item.
  int lastRankedIndexBeforeMove = -1;
  for (int i = 0; i < list.length; i++) {
    final key = (tmdbId: list[i].movie.tmdbId, isTv: list[i].movie.isTv);
    final isLatest = latestWatchIds[key] == list[i].record.id;
    final rank = isLatest ? list[i].setting?.personalRanking : null;
    if (i != oldIndex && rank != null) {
      lastRankedIndexBeforeMove = i;
    }
  }

  int lastRankedBoundary = lastRankedIndexBeforeMove;
  if (lastRankedIndexBeforeMove > oldIndex) {
    lastRankedBoundary = lastRankedIndexBeforeMove - 1;
  }

  final isDroppedInRankedArea = newIndex <= (lastRankedBoundary + 1);

  int currentRank = 1;
  for (int i = 0; i < updatedList.length; i++) {
    final item = updatedList[i];
    final key = (tmdbId: item.movie.tmdbId, isTv: item.movie.isTv);
    final isLatest = latestWatchIds[key] == item.record.id;

    if (!isLatest) continue; // Only assign ranks to the latest watches to avoid setting duplicates

    if (i == newIndex) {
      if (isDroppedInRankedArea) {
        newRanks[key] = currentRank++;
      } else {
        newRanks[key] = null; // Unranked
      }
    } else {
      final wasRanked = item.setting?.personalRanking != null;
      if (wasRanked) {
        if (i <= (isDroppedInRankedArea ? lastRankedBoundary + 1 : lastRankedBoundary)) {
          newRanks[key] = currentRank++;
        } else {
          newRanks[key] = null;
        }
      } else {
        newRanks[key] = null;
      }
    }
  }

  return newRanks;
}
