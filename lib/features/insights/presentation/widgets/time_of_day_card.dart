import 'insight_palette.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/insight_buckets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class TimeOfDayCard extends StatelessWidget {
  final InsightsData data;
  const TimeOfDayCard({super.key, required this.data});

  Widget _buildTimeOfDayRow(BuildContext context, TimeOfDayBand band, int count, int total, IconData icon, Color color) {
    final label = band.label(AppLocalizations.of(context));
    final hours = band.hoursLabel;
    final percentage = total > 0 ? (count / total) * 100 : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                hours,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
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
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final values = data.timeOfDayTrend;
    final total = values.values.fold<int>(0, (sum, v) => sum + v);

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).insightsTimeOfDayTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 18),
          _buildTimeOfDayRow(context, TimeOfDayBand.morning, values[TimeOfDayBand.morning] ?? 0, total, Icons.wb_sunny_rounded, InsightPalette.morning),
          _buildTimeOfDayRow(context, TimeOfDayBand.midday, values[TimeOfDayBand.midday] ?? 0, total, Icons.wb_cloudy_rounded, InsightPalette.midday),
          _buildTimeOfDayRow(context, TimeOfDayBand.evening, values[TimeOfDayBand.evening] ?? 0, total, Icons.nights_stay_rounded, InsightPalette.evening),
          _buildTimeOfDayRow(context, TimeOfDayBand.night, values[TimeOfDayBand.night] ?? 0, total, Icons.dark_mode_rounded, InsightPalette.night),
        ],
      ),
    );
  }
}
