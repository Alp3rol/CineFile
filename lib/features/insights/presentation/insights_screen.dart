import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../wrapped/presentation/cinefile_wrapped_screen.dart';
import 'insights_provider.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/insights_charts.dart';
import 'widgets/insights_lists.dart';
import 'widgets/seasonal_trends_card.dart';
import 'widgets/summary_cards_grid.dart';
import 'widgets/time_of_day_card.dart';
import 'widgets/time_visualizer_card.dart';
import 'widgets/weekly_goal_card.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  const InsightsScreen({super.key, this.scrollController});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final insights = ref.watch(insightsProvider);

    if (insights == null) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Extra bottom padding for bottom navigation bar

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. CineFile Wrapped Banner
          AppPressable(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CineFileWrappedScreen(),
                ),
              );
            },
            borderRadius: AppRadius.lg,
            child: GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.lg,
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CineFile Wrapped',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Yıllık sinema özetini ve özel kartını keşfet!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 1. Summary Cards Grid
          SummaryCardsGrid(data: insights),
          const SizedBox(height: 12),

          // 1b. Haftalık İzleme Hedefi (v0.9.0)
          WeeklyGoalCard(data: insights),
          const SizedBox(height: 12),

          // 1c. Yıllık İzleme Isı Haritası (Neon Contribution Heatmap)
          ContributionHeatmap(insights: insights),
          const SizedBox(height: 12),

          // 2. Monthly Trend Chart Card
          MonthlyChartCard(data: insights),
          const SizedBox(height: 12),

          // 3. Genre Breakdown Chart Card
          GenreChartCard(data: insights),
          const SizedBox(height: 12),

          // 3b. Puan Dağılım Grafiği & Eleştirmen Profili (v0.8.3)
          RatingDistributionCard(data: insights),
          const SizedBox(height: 12),

          // 4. Time of Day Analysis
          TimeOfDayCard(data: insights),
          const SizedBox(height: 12),

          // 4b. Zaman Kıyaslama Paneli (v0.8.4)
          TimeVisualizerCard(data: insights),
          const SizedBox(height: 12),

          // 4c. Mevsimsel Analiz (v0.8.4)
          SeasonalTrendsCard(data: insights),
          const SizedBox(height: 12),

          // 5. Leaders Column (Directors & Actors)
          LeadersCard(data: insights),
          const SizedBox(height: 12),

          // 5b. En Popüler Etiketler (v0.9.0)
          TagsSection(data: insights),
          const SizedBox(height: 12),

          // 6. Badges Grid Section
          BadgesSection(data: insights),
        ],
      ),
    );
  }

  // Empty state placeholder
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 72,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).insightsInsufficientData,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).insightsEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
