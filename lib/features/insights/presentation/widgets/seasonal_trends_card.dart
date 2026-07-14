import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class SeasonalTrendsCard extends StatelessWidget {
  final InsightsData data;
  const SeasonalTrendsCard({super.key, required this.data});

  Widget _buildSeasonalBar(String label, int count, int total, Color color) {
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
                style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600),
              ),
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
              backgroundColor: Colors.white.withValues(alpha: 0.04),
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

    final weekdays = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final goldenDayStr = weekdays[data.goldenWeekday];

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
                '📅 Mevsimsel Dağılım',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Altın Gün: $goldenDayStr 🏆',
                  style: GoogleFonts.outfit(fontSize: 9.5, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSeasonalBar('❄️ Kış (Ara-Oca-Şub)', values['Kış'] ?? 0, total, Colors.lightBlueAccent),
          _buildSeasonalBar('🌱 İlkbahar (Mar-Nis-May)', values['İlkbahar'] ?? 0, total, Colors.lightGreenAccent),
          _buildSeasonalBar('☀️ Yaz (Haz-Tem-Ağu)', values['Yaz'] ?? 0, total, Colors.amberAccent),
          _buildSeasonalBar('🍂 Sonbahar (Eyl-Eki-Kas)', values['Sonbahar'] ?? 0, total, Colors.deepOrangeAccent),
        ],
      ),
    );
  }
}
