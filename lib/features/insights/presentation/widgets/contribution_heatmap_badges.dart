import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import 'contribution_heatmap_utils.dart';

// The three stat badges (active days / current streak / peak hour) shown
// under the heatmap's year navigation row.
class ContributionHeatmapBadges extends StatelessWidget {
  final int activeDays;
  final int currentStreak;
  final String peakTimeOfDay;

  const ContributionHeatmapBadges({
    super.key,
    required this.activeDays,
    required this.currentStreak,
    required this.peakTimeOfDay,
  });

  Widget _badge(BuildContext context, IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: AppOpacity.faint),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _badge(context, Icons.event_available_rounded, AppLocalizations.of(context).heatmapActiveDays, '$activeDays', HeatmapColors.neonCyan),
        const SizedBox(width: 8),
        _badge(context, Icons.local_fire_department_rounded, AppLocalizations.of(context).heatmapCurrentStreak, '${currentStreak}g', AppColors.rating),
        const SizedBox(width: 8),
        _badge(context, Icons.schedule_rounded, AppLocalizations.of(context).heatmapPeakHour, peakTimeOfDay, HeatmapColors.neonPink),
      ],
    );
  }
}
