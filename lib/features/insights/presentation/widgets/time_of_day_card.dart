import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class TimeOfDayCard extends StatelessWidget {
  final InsightsData data;
  const TimeOfDayCard({super.key, required this.data});

  Widget _buildTimeOfDayRow(String label, String hours, int count, int total, IconData icon, Color color) {
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
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Text(
                hours,
                style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
              ),
              const Spacer(),
              Text(
                '$count İzleme (${percentage.toStringAsFixed(0)}%)',
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
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
            'Günün Hangi Saatlerinde İzliyorsun?',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 18),
          _buildTimeOfDayRow('Sabah', '06:00 - 12:00', values['Sabah'] ?? 0, total, Icons.wb_sunny_rounded, Colors.orangeAccent),
          _buildTimeOfDayRow('Öğle', '12:00 - 18:00', values['Öğle'] ?? 0, total, Icons.wb_cloudy_rounded, const Color(0xFF29B6F6)),
          _buildTimeOfDayRow('Akşam', '18:00 - 24:00', values['Akşam'] ?? 0, total, Icons.nights_stay_rounded, Colors.indigoAccent),
          _buildTimeOfDayRow('Gece', '00:00 - 06:00', values['Gece'] ?? 0, total, Icons.dark_mode_rounded, Colors.purpleAccent),
        ],
      ),
    );
  }
}
