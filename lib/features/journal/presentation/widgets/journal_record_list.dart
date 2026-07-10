import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/quick_advance_tag.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import 'watch_record_preview_dialog.dart';

const _monthsTr = [
  'OCAK', 'ŞUBAT', 'MART', 'NİSAN', 'MAYIS', 'HAZİRAN',
  'TEMMUZ', 'AĞUSTOS', 'EYLÜL', 'EKİM', 'KASIM', 'ARALIK',
];

const _monthsTrTitleCase = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

String _formatDayMonthYear(DateTime date) {
  return '${date.day} ${_monthsTrTitleCase[date.month - 1]} ${date.year}';
}

// Whether the show this watch record belongs to has been fully watched via
// "Aktif İzliyorum" episode tracking (see UserMovieSettings).
bool _isShowCompleted(WatchRecordWithMovie item) {
  final total = item.movie.totalEpisodes;
  final last = item.setting?.lastWatchedEpisode;
  return total != null && last != null && last >= total;
}

// Renders watch records grouped by month (newest month first), matching the
// simplified card-list design. Replaces the former sortable table +
// drag-to-reorder list; personal ranking can still be edited via the
// long-press preview dialog.
class JournalRecordsList extends ConsumerWidget {
  final List<WatchRecordWithMovie> items;
  final Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking;

  const JournalRecordsList({
    super.key,
    required this.items,
    required this.onUpdateRanking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = List<WatchRecordWithMovie>.from(items)
      ..sort((a, b) => b.record.watchDate.compareTo(a.record.watchDate));

    // The quick-advance tag only makes sense on a show's most recent watch
    // record, matching the table view's behavior (see journal_table_list.dart).
    final latestWatchIds = <MovieKey, int>{};
    for (final item in sorted) {
      latestWatchIds.putIfAbsent((tmdbId: item.movie.tmdbId, isTv: item.movie.isTv), () => item.record.id);
    }

    final groups = <String, List<WatchRecordWithMovie>>{};
    final groupOrder = <String>[];
    for (final item in sorted) {
      final date = item.record.watchDate;
      final key = '${_monthsTr[date.month - 1]} ${date.year}';
      if (!groups.containsKey(key)) {
        groups[key] = [];
        groupOrder.add(key);
      }
      groups[key]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 20),
      itemCount: groupOrder.length,
      itemBuilder: (context, groupIndex) {
        final monthLabel = groupOrder[groupIndex];
        final monthItems = groups[monthLabel]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: groupIndex == 0 ? 4 : 20, bottom: 10),
              child: Text(
                monthLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ...monthItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _JournalRecordCard(
                    item: item,
                    onUpdateRanking: onUpdateRanking,
                    isLatestWatch:
                        latestWatchIds[(tmdbId: item.movie.tmdbId, isTv: item.movie.isTv)] == item.record.id,
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _JournalRecordCard extends ConsumerWidget {
  final WatchRecordWithMovie item;
  final Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking;
  final bool isLatestWatch;

  const _JournalRecordCard({required this.item, required this.onUpdateRanking, required this.isLatestWatch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = item.movie;
    final record = item.record;
    final dateStr = _formatDayMonthYear(record.watchDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
          onDelete: () => deleteWatchRecord(ref, record.id),
          onUpdateDate: (newDate) => updateWatchRecord(ref, record.id, watchDate: newDate),
          onUpdateEpisodes: (newCount) => updateWatchRecord(ref, record.id, episodeCount: newCount),
        ),
        child: GlassContainer(
          borderRadius: 16,
          opacity: 0.5,
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: movie.posterPath != null
                      ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                      : '',
                  width: 56,
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            movie.title,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isShowCompleted(item)) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 12),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        dateStr,
                        if (record.watchPlace != null && record.watchPlace!.trim().isNotEmpty) record.watchPlace!,
                      ].join(' • '),
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (record.watchCompanion != null && record.watchCompanion!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          record.watchCompanion!,
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 15),
                      const SizedBox(width: 2),
                      Text(
                        record.rating.toStringAsFixed(1),
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  if (isLatestWatch && item.setting?.isActivelyWatching == true) ...[
                    const SizedBox(height: 4),
                    QuickAdvanceTag(item: item),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
