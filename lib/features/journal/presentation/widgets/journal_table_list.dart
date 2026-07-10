import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/widgets/quick_advance_tag.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import 'platform_icon.dart';
import 'watch_record_preview_dialog.dart';

// Clickable header cell with sort icon indicator (table view only).
class JournalHeaderCell extends StatelessWidget {
  final String label;
  final String columnKey;
  final int flex;
  final bool sortable;
  final String activeSortColumn;
  final bool sortAscending;
  final ValueChanged<String> onSort;

  const JournalHeaderCell({
    super.key,
    required this.label,
    required this.columnKey,
    required this.flex,
    required this.activeSortColumn,
    required this.sortAscending,
    required this.onSort,
    this.sortable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = activeSortColumn == columnKey;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: sortable ? () => onSort(columnKey) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppTheme.accentColor : AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 2),
              Icon(
                sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 11,
                color: AppTheme.accentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Sortable table with drag-to-reorder personal ranking (the original journal
// list design, kept alongside the newer month-grouped card list so the user
// can switch between the two).
class JournalRecordsTable extends StatelessWidget {
  final List<WatchRecordWithMovie> items;
  final void Function(List<WatchRecordWithMovie> items, int oldIndex, int newIndex) onReorder;
  final Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking;

  const JournalRecordsTable({
    super.key,
    required this.items,
    required this.onReorder,
    required this.onUpdateRanking,
  });

  // Whether the show this watch record belongs to has been fully watched
  // via "Aktif İzliyorum" episode tracking (see UserMovieSettings).
  bool _isShowCompleted(WatchRecordWithMovie item) {
    final total = item.movie.totalEpisodes;
    final last = item.setting?.lastWatchedEpisode;
    return total != null && last != null && last >= total;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    // Group records to find the latest watch ID for each (tmdbId, isTv)
    final latestWatchIds = <MovieKey, int>{};
    final latestWatches = <MovieKey, WatchRecordWithMovie>{};
    for (final r in items) {
      final key = (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv);
      final currentLatest = latestWatches[key];
      if (currentLatest == null || r.record.watchDate.isAfter(currentLatest.record.watchDate)) {
        latestWatches[key] = r;
        latestWatchIds[key] = r.record.id;
      }
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 20),
      itemCount: items.length,
      onReorder: (oldIdx, newIdx) => onReorder(items, oldIdx, newIdx),
      buildDefaultDragHandles: false, // Turn off default handles on the right to save space
      itemBuilder: (context, index) {
        final item = items[index];
        final record = item.record;
        final movie = item.movie;

        final dateStr = DateFormat('dd.MM.yyyy').format(record.watchDate);
        final year = movie.releaseYear?.toString() ?? '';

        final isLatestWatch = latestWatchIds[(tmdbId: movie.tmdbId, isTv: movie.isTv)] == record.id;
        final displayRank = isLatestWatch ? item.setting?.personalRanking : null;

        return Material(
          key: ValueKey(record.id), // Unique value key for reorderable list
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(tmdbId: movie.tmdbId, isTv: movie.isTv),
                ),
              );
            },
            onLongPress: () => showWatchRecordPreviewDialog(
              context,
              movie,
              record,
              item.setting,
              onUpdateRanking: onUpdateRanking,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
              ),
              child: Row(
                children: [
                  // 1. Sıra Sütunu (Rank Number only — drag handle removed) - flex 1
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayRank != null ? '#$displayRank' : '-',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: displayRank != null ? AppTheme.accentColor : Colors.white30,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // 2. Film Sütunu (Poster + Title) - flex 4 on mobile, 3 on desktop
                  Expanded(
                    flex: isMobile ? 4 : 3,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                            imageUrl: movie.posterPath != null
                                ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                                : '',
                            width: 52,
                            height: 76,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.surfaceColor,
                              width: 52,
                              height: 76,
                              child: const Icon(Icons.movie, size: 18, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                movie.title,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${year.isNotEmpty ? "$year • " : ""}${movie.director ?? "Yönetmen Yok"}',
                                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (record.tags != null && record.tags!.trim().isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  record.tags!,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentColor.withOpacity(0.85),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. İzleme Bilgisi Sütunu - flex 3 on mobile, 2 on desktop
                  Expanded(
                    flex: isMobile ? 3 : 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (record.watchPlace != null) ...[
                              buildPlatformIcon(record.watchPlace),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                isMobile
                                    ? '${record.watchNumber}. İzleme'
                                    : (record.watchPlace ?? ''),
                                style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (isMobile && record.watchNumber > 1) ...[
                              const SizedBox(width: 3),
                              const Icon(Icons.sync_rounded, color: Colors.greenAccent, size: 10),
                            ],
                            if (isMobile && _isShowCompleted(item)) ...[
                              const SizedBox(width: 3),
                              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 10),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 4. İzleme Sırası Sütunu (Desktop Only) - flex 2
                  if (!isMobile)
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '${record.watchNumber}. İzleme',
                                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (record.watchNumber > 1) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.sync_rounded, color: Colors.greenAccent, size: 10),
                              ],
                              if (_isShowCompleted(item)) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 10),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 5. Puanım Sütunu - flex 2
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 13),
                            const SizedBox(width: 2),
                            Text(
                              '${record.rating}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (!(isLatestWatch && item.setting?.isActivelyWatching == true)) ...[
                              const SizedBox(width: 4),
                              Text(
                                record.mood ?? '🍿',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                        if (isLatestWatch && item.setting?.isActivelyWatching == true) ...[
                          const SizedBox(height: 3),
                          QuickAdvanceTag(item: item),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
