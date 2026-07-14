import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class SummaryCardsGrid extends StatelessWidget {
  final InsightsData data;
  const SummaryCardsGrid({super.key, required this.data});

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color) {
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
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
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
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
        _buildMiniStatCard('Toplam İzleme', '${data.totalWatchCount}', Icons.movie_filter_rounded, Colors.blueAccent),
        _buildMiniStatCard('Tekil İçerik', '${data.uniqueTitleCount}', Icons.local_play_rounded, Colors.purpleAccent),
        _buildMiniStatCard('Toplam Süre', durationStr, Icons.timelapse_rounded, Colors.tealAccent),
        _buildMiniStatCard('Ort. Puan', '${data.averageRating.toStringAsFixed(1)} / 10', Icons.star_rounded, AppTheme.ratingColor),
      ],
    );
  }
}
