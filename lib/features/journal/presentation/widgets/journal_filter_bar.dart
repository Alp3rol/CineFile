import 'package:flutter/material.dart';
import '../../../../core/l10n/genre_names.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../l10n/app_localizations.dart';

// Quick Filter Chips Bar — full-width, no horizontal scroll.
// Each chip gets an equal Expanded share of the available width.
//
// Not AppChip: these are a segmented bar stretched across the screen with the
// icon stacked above the label, where a chip hugs its content in a single
// line. Same reasoning as the episode-tracking choice buttons — a chip that
// fills a quarter of the screen stops reading as a chip.
class JournalFiltersBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const JournalFiltersBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String filterKey,
    IconData icon,
  ) {
    final isActive = activeFilter == filterKey;
    final foreground =
        isActive ? AppColors.onAccent : AppColors.textSecondary;

    return Expanded(
      child: AppPressable(
        onTap: () => onFilterChanged(isActive ? 'all' : filterKey),
        borderRadius: AppRadius.pill,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppDuration.curve,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accent
                : AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
            borderRadius: AppRadius.allPill,
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.border,
              width: AppSize.hairline,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: foreground),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _buildFilterChip(context, l10n.journalFilterAll, 'all',
              Icons.format_list_bulleted_rounded),
          const SizedBox(width: AppSpacing.xs),
          _buildFilterChip(context, l10n.journalFilterFavorites, 'favorites',
              Icons.favorite_rounded),
          const SizedBox(width: AppSpacing.xs),
          _buildFilterChip(context, l10n.journalFilterCinema, 'cinema',
              Icons.local_movies_rounded),
          const SizedBox(width: AppSpacing.xs),
          _buildFilterChip(context, l10n.journalFilterWithNotes, 'notes',
              Icons.rate_review_rounded),
        ],
      ),
    );
  }
}

// v0.6.1: Mini Insights Bar UI — full-width, no horizontal scroll.
// Each card gets an equal Expanded share; IntrinsicHeight keeps rows aligned.
class JournalMiniInsightsBar extends StatelessWidget {
  final int thisMonthCount;
  final double avgRating;

  /// Most-watched genre id, or null when nothing in the current filter has
  /// genre data. Resolved to a name here rather than upstream so it follows
  /// the user's language.
  final int? favoriteGenreId;
  final int totalHours;
  final int totalMinutes;

  const JournalMiniInsightsBar({
    super.key,
    required this.thisMonthCount,
    required this.avgRating,
    required this.favoriteGenreId,
    required this.totalHours,
    required this.totalMinutes,
  });

  // Matches HomeStatsDashboard's mini-stat treatment (icon + label/value
  // column, alternating accent/rating, shared textTheme) so the Journal's top
  // panel reads as the same design system as Home instead of four
  // disconnected floating cards with ad-hoc colors/font sizes.
  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSize.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge
                      ?.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 30,
        width: AppSize.hairline,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final days = totalHours ~/ 24;
    final hours = totalHours % 24;
    final durationParts = <String>[];
    if (days > 0) durationParts.add(l10n.durationDays(days));
    if (hours > 0 || days == 0) durationParts.add(l10n.durationHours(hours));
    if (totalMinutes > 0) durationParts.add(l10n.durationMinutes(totalMinutes));
    final durationStr = durationParts.join('');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: GlassContainer(
        borderRadius: AppRadius.xl,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                _buildStat(
                  context,
                  l10n.journalStatThisMonth,
                  l10n.journalMoviesCount(thisMonthCount),
                  Icons.calendar_month_rounded,
                  AppColors.accent,
                ),
                _divider(),
                _buildStat(
                  context,
                  l10n.journalStatAvgRating,
                  '${avgRating.toStringAsFixed(1)} ★',
                  Icons.star_rounded,
                  AppColors.rating,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildStat(
                  context,
                  l10n.journalStatFavoriteGenre,
                  favoriteGenreId == null
                      ? l10n.journalStatUndetermined
                      : genreName(l10n, favoriteGenreId!),
                  Icons.movie_filter_rounded,
                  AppColors.accent,
                ),
                _divider(),
                _buildStat(
                  context,
                  l10n.journalStatTotalTime,
                  durationStr,
                  Icons.hourglass_bottom_rounded,
                  AppColors.rating,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
