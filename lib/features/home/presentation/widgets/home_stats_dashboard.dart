import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../insights/presentation/insights_provider.dart';

class HomeStatsDashboard extends StatelessWidget {
  final InsightsData? insights;
  final int weeklyGoal;

  const HomeStatsDashboard({super.key, required this.insights, required this.weeklyGoal});

  /// Below this the three stat tiles cannot sit side by side without the
  /// numbers wrapping, so the goal card drops to its own row.
  static const double _stackBelowWidth = 450;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalWatchCount = insights?.totalWatchCount ?? 0;
    final averageRating = insights?.averageRating ?? 0.0;
    final thisWeekCount = insights?.thisWeekWatchCount ?? 0;
    final progress = weeklyGoal > 0 ? (thisWeekCount / weeklyGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = (weeklyGoal - thisWeekCount).clamp(0, weeklyGoal);
    final goalReached = progress >= 1.0;
    final goalText = totalWatchCount == 0
        ? l10n.homeStatsAddFirst
        : remaining == 0
            ? l10n.homeStatsGoalReached
            : l10n.homeStatsGoalRemaining(remaining);
    final textTheme = Theme.of(context).textTheme;

    final goalCard = Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 56,
              width: 56,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor:
                    AppColors.textPrimary.withValues(alpha: AppOpacity.subtle),
                valueColor: AlwaysStoppedAnimation<Color>(
                  goalReached ? AppColors.success : AppColors.accent,
                ),
              ),
            ),
            Text(
              '$thisWeekCount/$weeklyGoal',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homeStatsWeeklyGoal,
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                goalText,
                style: textTheme.labelSmall?.copyWith(height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    return AppCard(
      tone: AppCardTone.translucent,
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _IconPlate(
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.accent,
                    rounded: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.homeStatsHeader,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              if (weeklyGoal > 0)
                AppBadge(
                  label: goalReached
                      ? l10n.homeStatsGoalDoneCaps
                      : l10n.homeStatsWeeklyGoalCaps,
                  tone: goalReached
                      ? AppBadgeTone.success
                      : AppBadgeTone.neutral,
                  shape: AppBadgeShape.pill,
                  outlined: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final totalTile = _StatTile(
                icon: Icons.movie_outlined,
                iconColor: AppColors.accent,
                label: l10n.homeStatsTotalWatches,
                value: '$totalWatchCount',
                unit: l10n.homeStatsTitlesUnit,
              );

              final ratingTile = _StatTile(
                icon: Icons.star_rounded,
                iconColor: AppColors.rating,
                label: l10n.homeStatsAverageRating,
                value: totalWatchCount == 0 ? '-' : averageRating.toStringAsFixed(1),
                unit: totalWatchCount > 0 ? '/ 10' : '',
              );

              final goalTile = AppCard(
                tone: AppCardTone.translucent,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: goalCard,
              );

              if (constraints.maxWidth < _stackBelowWidth) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: totalTile),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: ratingTile),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    goalTile,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: totalTile),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: ratingTile),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 2, child: goalTile),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tinted backplate behind a small icon.
class _IconPlate extends StatelessWidget {
  const _IconPlate({
    required this.icon,
    required this.color,
    this.rounded = false,
  });

  final IconData icon;
  final Color color;

  /// Square with a small radius rather than a circle. The dashboard header
  /// uses the rounded square; the stat tiles use circles.
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rounded ? AppSpacing.xs : AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: rounded ? AppRadius.allSm : null,
        shape: rounded ? BoxShape.rectangle : BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: rounded ? AppSize.iconSm : AppSize.iconMd,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      tone: AppCardTone.translucent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _IconPlate(icon: icon, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Both texts are Flexible: three of these cards sit side by
                // side in Expanded slots, so on a narrow screen each gets
                // roughly a third of the width — and a four-digit minute
                // total next to its unit ("12.480 dk") overflowed the card by
                // a dozen pixels. The number keeps priority; the unit is what
                // gets clipped first if something has to give.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          unit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// (HomeStreakChip used to live here. The premium-home redesign moved the
// streak indicator into HomeHeaderBar's "N Gün" pill, leaving this class
// unreferenced — removed rather than kept as a second, divergent rendering of
// the same number.)
