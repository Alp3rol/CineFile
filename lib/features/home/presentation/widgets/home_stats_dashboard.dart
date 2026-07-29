import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../insights/presentation/insights_provider.dart';

class HomeStatsDashboard extends StatelessWidget {
  final InsightsData? insights;
  final int weeklyGoal;

  const HomeStatsDashboard({super.key, required this.insights, required this.weeklyGoal});

  @override
  Widget build(BuildContext context) {
    final totalWatchCount = insights?.totalWatchCount ?? 0;
    final averageRating = insights?.averageRating ?? 0.0;
    final thisWeekCount = insights?.thisWeekWatchCount ?? 0;
    final progress = weeklyGoal > 0 ? (thisWeekCount / weeklyGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = (weeklyGoal - thisWeekCount).clamp(0, weeklyGoal);
    final goalText = totalWatchCount == 0
        ? AppLocalizations.of(context).homeStatsAddFirst
        : remaining == 0
            ? AppLocalizations.of(context).homeStatsGoalReached
            : AppLocalizations.of(context).homeStatsGoalRemaining(remaining);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: AppTheme.accentColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).homeStatsHeader,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              if (weeklyGoal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: progress >= 1.0 ? Colors.green.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: progress >= 1.0 ? Colors.green.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    progress >= 1.0 ? AppLocalizations.of(context).homeStatsGoalDoneCaps : AppLocalizations.of(context).homeStatsWeeklyGoalCaps,
                    style: TextStyle(
                      color: progress >= 1.0 ? Colors.greenAccent : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Stats Content
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 450;

              final totalCard = _buildStatTile(
                context,
                icon: Icons.movie_outlined,
                iconColor: AppTheme.accentColor,
                label: AppLocalizations.of(context).homeStatsTotalWatches,
                value: '$totalWatchCount',
                unit: AppLocalizations.of(context).homeStatsTitlesUnit,
              );

              final ratingCard = _buildStatTile(
                context,
                icon: Icons.star_rounded,
                iconColor: Colors.amberAccent,
                label: AppLocalizations.of(context).homeStatsAverageRating,
                value: totalWatchCount == 0 ? '-' : averageRating.toStringAsFixed(1),
                unit: totalWatchCount > 0 ? '/ 10' : '',
              );

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
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.greenAccent : AppTheme.accentColor,
                          ),
                        ),
                      ),
                      Text(
                        '$thisWeekCount/$weeklyGoal',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context).homeStatsWeeklyGoal,
                          style: textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          goalText,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (isMobile) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: totalCard),
                        const SizedBox(width: 10),
                        Expanded(child: ratingCard),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
                      ),
                      child: goalCard,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: totalCard),
                  const SizedBox(width: 12),
                  Expanded(child: ratingCard),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
                      ),
                      child: goalCard,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
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
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          unit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
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
