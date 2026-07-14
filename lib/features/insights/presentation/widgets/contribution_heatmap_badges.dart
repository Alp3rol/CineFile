import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
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

  Widget _badge(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10, width: 0.5),
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
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
        _badge(Icons.event_available_rounded, 'Aktif Gün', '$activeDays', HeatmapColors.neonCyan),
        const SizedBox(width: 8),
        _badge(Icons.local_fire_department_rounded, 'Mevcut Seri', '${currentStreak}g', Colors.orange),
        const SizedBox(width: 8),
        _badge(Icons.schedule_rounded, 'Yoğun Saat', peakTimeOfDay, HeatmapColors.neonPink),
      ],
    );
  }
}
