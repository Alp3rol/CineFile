import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/quick_advance_tag.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/database/database_provider.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import 'watch_record_preview_dialog.dart';

String _formatDayMonthYear(BuildContext context, DateTime date) {
  return formatLongDate(context, date);
}

bool _isShowCompleted(WatchRecordWithMovie item) {
  final total = item.movie.totalEpisodes;
  final last = item.setting?.lastWatchedEpisode;
  return total != null && last != null && last >= total;
}

class JournalRecordsList extends ConsumerWidget {
  final List<WatchRecordWithMovie> items;
  final Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking;
  final ScrollController? scrollController;

  const JournalRecordsList({
    super.key,
    required this.items,
    required this.onUpdateRanking,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = List<WatchRecordWithMovie>.from(items)
      ..sort((a, b) => b.record.watchDate.compareTo(a.record.watchDate));

    final latestWatchIds = <MovieKey, int>{};
    for (final item in sorted) {
      latestWatchIds.putIfAbsent((tmdbId: item.movie.tmdbId, isTv: item.movie.isTv), () => item.record.id);
    }

    final groups = <String, List<WatchRecordWithMovie>>{};
    final groupOrder = <String>[];
    for (final item in sorted) {
      final date = item.record.watchDate;
      final key = formatMonthHeading(context, date);
      if (!groups.containsKey(key)) {
        groups[key] = [];
        groupOrder.add(key);
      }
      groups[key]!.add(item);
    }

    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 24),
      itemCount: groupOrder.length,
      itemBuilder: (context, groupIndex) {
        final monthLabel = groupOrder[groupIndex];
        final monthItems = groups[monthLabel]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: groupIndex == 0 ? 4 : 20, bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 0.8,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
            ...monthItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
    final dateStr = _formatDayMonthYear(context, record.watchDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
          onDelete: () => deleteWatchRecord(ref, record),
          onUpdateDate: (newDate) => updateWatchRecord(ref, record, watchDate: newDate),
          onUpdateEpisodes: (newCount) => updateWatchRecord(ref, record, episodeCount: newCount),
          onUpdatePrivacy: (newValue) => updateWatchRecord(ref, record, isPublic: newValue),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3D Shadowed Poster Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(
                    imageUrl: movie.posterPath != null
                        ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                        : '',
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                    seed: movie.title,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            movie.title,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isShowCompleted(item)) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),

                    // Pills Row: Place & Companion
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (record.watchPlace != null && record.watchPlace!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 10, color: AppTheme.accentColor),
                                const SizedBox(width: 3),
                                Text(
                                  record.watchPlace!,
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        if (record.watchCompanion != null && record.watchCompanion!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_rounded, size: 10, color: Colors.purpleAccent),
                                const SizedBox(width: 3),
                                Text(
                                  record.watchCompanion!,
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Rating Badge Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.ratingColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.ratingColor.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          record.rating.toStringAsFixed(1),
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  if (isLatestWatch && item.setting?.isActivelyWatching == true) ...[
                    const SizedBox(height: 6),
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
