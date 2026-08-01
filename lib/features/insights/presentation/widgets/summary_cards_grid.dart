import 'insight_palette.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class SummaryCardsGrid extends StatelessWidget {
  final InsightsData data;
  const SummaryCardsGrid({super.key, required this.data});

  Widget _buildMiniStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return GlassContainer(
      borderRadius: 16,
      opacity: 0.5,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: color),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = data.totalDurationMinutes ~/ 60;
    final totalMinutes = data.totalDurationMinutes % 60;

    final days = totalHours ~/ 24;
    final hours = totalHours % 24;
    final durationParts = <String>[];
    if (days > 0) durationParts.add('${days}g');
    if (hours > 0 || days == 0) durationParts.add('${hours}s');
    if (totalMinutes > 0) durationParts.add('${totalMinutes}dk');
    final durationStr = durationParts.join('');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.0,
      children: [
        _buildMiniStatCard(context, AppLocalizations.of(context).insightsSummaryTotalWatches, '${data.totalWatchCount}', Icons.movie_filter_rounded, InsightPalette.summaryWatches),
        _buildMiniStatCard(context, AppLocalizations.of(context).insightsSummaryUniqueTitles, '${data.uniqueTitleCount}', Icons.local_play_rounded, InsightPalette.summaryTitles),
        _buildMiniStatCard(context, AppLocalizations.of(context).insightsSummaryTotalTime, durationStr, Icons.timelapse_rounded, InsightPalette.summaryTime),
        _buildMiniStatCard(context, AppLocalizations.of(context).insightsSummaryAvgRating, '${data.averageRating.toStringAsFixed(1)} / 10', Icons.star_rounded, AppColors.rating),
      ],
    );
  }
}
