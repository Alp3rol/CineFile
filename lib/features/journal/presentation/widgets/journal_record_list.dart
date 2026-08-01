import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
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
      latestWatchIds.putIfAbsent(
          (tmdbId: item.movie.tmdbId, isTv: item.movie.isTv),
          () => item.record.id);
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
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xs,
        bottom: AppSpacing.xl,
      ),
      itemCount: groupOrder.length,
      itemBuilder: (context, groupIndex) {
        final monthLabel = groupOrder[groupIndex];
        final monthItems = groups[monthLabel]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: groupIndex == 0 ? AppSpacing.xs : AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: _MonthHeading(label: monthLabel),
            ),
            ...monthItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _JournalRecordCard(
                  item: item,
                  onUpdateRanking: onUpdateRanking,
                  isLatestWatch: latestWatchIds[
                          (tmdbId: item.movie.tmdbId, isTv: item.movie.isTv)] ==
                      item.record.id,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Month separator: an accent rule, the month, and a hairline running out to
/// the edge.
class _MonthHeading extends StatelessWidget {
  const _MonthHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: AppRadius.allPill,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: 0.8,
            color: AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
          ),
        ),
      ],
    );
  }
}

/// Small labelled pill under a record's title — where it was watched, and
/// with whom. Written out twice, identically, before this.
class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
        borderRadius: AppRadius.allSm,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: iconColor),
          const SizedBox(width: 3),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _JournalRecordCard extends ConsumerWidget {
  final WatchRecordWithMovie item;
  final Future<void> Function(Map<MovieKey, int?> rankings) onUpdateRanking;
  final bool isLatestWatch;

  const _JournalRecordCard({
    required this.item,
    required this.onUpdateRanking,
    required this.isLatestWatch,
  });

  static const double _posterWidth = 60;
  static const double _posterHeight = 90;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = item.movie;
    final record = item.record;
    final textTheme = Theme.of(context).textTheme;
    final dateStr = _formatDayMonthYear(context, record.watchDate);

    return AppPressable(
      borderRadius: AppRadius.xl,
      semanticLabel: movie.title,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MovieDetailScreen(tmdbId: movie.tmdbId, isTv: movie.isTv),
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
        onUpdateDate: (newDate) =>
            updateWatchRecord(ref, record, watchDate: newDate),
        onUpdateEpisodes: (newCount) =>
            updateWatchRecord(ref, record, episodeCount: newCount),
        onUpdatePrivacy: (newValue) =>
            updateWatchRecord(ref, record, isPublic: newValue),
      ),
      // Was a hand-built gradient from 5% to 2% white. A flat translucent card
      // at the same starting alpha is indistinguishable at this size and is
      // the treatment every other card on the screen now uses.
      child: AppCard(
        tone: AppCardTone.translucent,
        borderRadius: AppRadius.xl,
        padding: const EdgeInsets.all(AppSpacing.md),
        elevated: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D Shadowed Poster Card
            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.allMd,
                boxShadow: AppElevation.low(AppColors.shadow),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.allMd,
                child: AppNetworkImage(
                  imageUrl: movie.posterPath != null
                      ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                      : '',
                  width: _posterWidth,
                  height: _posterHeight,
                  fit: BoxFit.cover,
                  seed: movie.title,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

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
                          style: textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isShowCompleted(item)) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: AppSize.iconSm,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(dateStr, style: textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),

                  // Pills Row: Place & Companion
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (record.watchPlace != null &&
                          record.watchPlace!.trim().isNotEmpty)
                        _MetaPill(
                          icon: Icons.location_on_rounded,
                          iconColor: AppColors.accent,
                          label: record.watchPlace!,
                        ),
                      if (record.watchCompanion != null &&
                          record.watchCompanion!.trim().isNotEmpty)
                        _MetaPill(
                          icon: Icons.people_rounded,
                          iconColor: AppColors.info,
                          label: record.watchCompanion!,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Rating Badge Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppBadge(
                  label: record.rating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                  tone: AppBadgeTone.rating,
                  outlined: true,
                ),
                if (isLatestWatch &&
                    item.setting?.isActivelyWatching == true) ...[
                  const SizedBox(height: AppSpacing.xs),
                  QuickAdvanceTag(item: item),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
