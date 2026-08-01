import 'insight_palette.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/insight_buckets.dart';
import '../../../../core/l10n/date_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class SeasonalTrendsCard extends StatelessWidget {
  final InsightsData data;
  const SeasonalTrendsCard({super.key, required this.data});

  Widget _buildSeasonalBar(BuildContext context, Season season, int count, int total, Color color) {
    final label = season.longLabel(AppLocalizations.of(context));
    final percentage = total > 0 ? (count / total) * 100 : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Text(
                AppLocalizations.of(context).insightsWatchesWithPercent(count, percentage.toStringAsFixed(0)),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final values = data.seasonalCounts;
    final total = values.values.fold<int>(0, (sum, v) => sum + v);

    final goldenDayStr = weekdayName(context, data.goldenWeekday);

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).insightsSeasonalTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context).insightsGoldenDay(goldenDayStr),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSeasonalBar(context, Season.winter, values[Season.winter] ?? 0, total, InsightPalette.winter),
          _buildSeasonalBar(context, Season.spring, values[Season.spring] ?? 0, total, InsightPalette.spring),
          _buildSeasonalBar(context, Season.summer, values[Season.summer] ?? 0, total, AppColors.rating),
          _buildSeasonalBar(context, Season.autumn, values[Season.autumn] ?? 0, total, InsightPalette.autumn),
        ],
      ),
    );
  }
}
