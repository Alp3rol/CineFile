import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'insights_provider.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/insights_charts.dart';
import 'widgets/insights_lists.dart';
import 'widgets/insights_misc_cards.dart';

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
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Yetersiz Veri',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Grafiklerin ve istatistiklerin oluşturulabilmesi için günlüğünüze en az 1 adet izleme kaydı eklemelisiniz.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
