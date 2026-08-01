import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import 'contribution_heatmap_utils.dart';

// The two legend rows (color-intensity swatches + film/tv/both labels)
// under the heatmap grid.
class ContributionHeatmapLegend extends StatelessWidget {
  const ContributionHeatmapLegend({super.key});

  Widget _legendCell(Color color, double alpha) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _legendLabel(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              AppLocalizations.of(context).heatmapLegendLess,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            _legendCell(HeatmapColors.neonCyan, 0.3),
            _legendCell(HeatmapColors.neonCyan, 1.0),
            const SizedBox(width: 10),
            _legendCell(HeatmapColors.neonPink, 0.3),
            _legendCell(HeatmapColors.neonPink, 1.0),
            const SizedBox(width: 10),
            _legendCell(HeatmapColors.neonPurple, 0.3),
            _legendCell(HeatmapColors.neonPurple, 1.0),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).heatmapLegendMore,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _legendLabel(context, AppLocalizations.of(context).heatmapLegendMovie, HeatmapColors.neonCyan),
            const SizedBox(width: 14),
            _legendLabel(context, AppLocalizations.of(context).heatmapLegendShow, HeatmapColors.neonPink),
            const SizedBox(width: 14),
            _legendLabel(context, AppLocalizations.of(context).heatmapLegendBoth, HeatmapColors.neonPurple),
          ],
        ),
      ],
    );
  }
}
