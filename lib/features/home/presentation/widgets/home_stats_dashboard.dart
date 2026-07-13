import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
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
        ? 'Bu hafta ilk izlemeni ekle.'
        : remaining == 0
            ? 'Bu haftaki hedefine ulaştın!'
            : 'Bu hafta $remaining film/dizi daha izlemelisin.';
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Switch to a vertical layout if screen width is mobile (< 500px)
        final useVerticalLayout = MediaQuery.of(context).size.width < 500;

        final totalStatsColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniStat(context, 'Toplam İzleme', '$totalWatchCount', Icons.movie_outlined),
            const SizedBox(height: 12),
            _buildMiniStat(
              context,
              'Ortalama Puan',
              totalWatchCount == 0 ? '-' : averageRating.toStringAsFixed(1),
              Icons.star_border_rounded,
              isRating: totalWatchCount > 0,
            ),
          ],
        );

        final weeklyGoalRow = Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                ),
                Text(
                  '$thisWeekCount/$weeklyGoal',
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Haftalık Hedef',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goalText,
                    style: textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ],
        );

        if (useVerticalLayout) {
          return GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildMiniStat(context, 'Toplam İzleme', '$totalWatchCount', Icons.movie_outlined),
                        ),
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: AppTheme.borderColor,
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildMiniStat(
                            context,
                            'Ortalama Puan',
                            totalWatchCount == 0 ? '-' : averageRating.toStringAsFixed(1),
                            Icons.star_border_rounded,
                            isRating: totalWatchCount > 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: AppTheme.borderColor, height: 1),
                const SizedBox(height: 10),
                weeklyGoalRow,
              ],
            ),
          );
        }

        // Default layout for wider screens
        return GlassContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Row(
            children: [
              // Total Stats
              Expanded(
                child: totalStatsColumn,
              ),

              // Divider Line
              Container(
                height: 70,
                width: 1,
                color: AppTheme.borderColor,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // Weekly Goal Progress
              Expanded(
                child: weeklyGoalRow,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value, IconData icon, {bool isRating = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isRating ? AppTheme.ratingColor : AppTheme.accentColor, size: 22),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: textTheme.displayMedium?.copyWith(fontSize: 22),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRating)
                    Text(
                      ' /10',
                      style: textTheme.labelLarge,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Same visual language as insights' contribution_heatmap buildStreakCard
// (icon + color + one-line text), reimplemented locally since that function
// is private to its own file. Uses GlassContainer so it matches the rest of
// the screen's glass-panel language instead of a hand-rolled flat container.
class HomeStreakChip extends StatelessWidget {
  final int streak;

  const HomeStreakChip({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 14,
      opacity: 0.5,
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, size: 22, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$streak günlük seri devam ediyor!',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
