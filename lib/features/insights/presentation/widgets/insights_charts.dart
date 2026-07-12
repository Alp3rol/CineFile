import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

class MonthlyChartCard extends StatelessWidget {
  final InsightsData data;
  const MonthlyChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    // Convert to fl_chart BarGroups
    final barGroups = <BarChartGroupData>[];
    for (int month = 1; month <= 12; month++) {
      final value = data.monthlyWatchTrend[month]?.toDouble() ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: value,
              color: AppTheme.accentColor,
              width: 10,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5.0, // default max bar helper background
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$currentYear Aylık İzleme Grafiği',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (data.monthlyWatchTrend.values.reduce((a, b) => a > b ? a : b).toDouble() + 2).clamp(5.0, 100.0),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surfaceColor,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} İzleme',
                        GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
                        final index = value.toInt() - 1;
                        if (index >= 0 && index < 12) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Text(
                              months[index],
                              style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GenreChartCard extends StatelessWidget {
  final InsightsData data;
  const GenreChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.topGenres.isEmpty) return const SizedBox.shrink();

    // Use top 5 genres, group others
    final displayedGenres = data.topGenres.take(4).toList();
    final othersCount = data.topGenres.skip(4).fold<int>(0, (sum, item) => sum + item.value);

    if (othersCount > 0) {
      displayedGenres.add(MapEntry('Diğer', othersCount));
    }

    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.purpleAccent,
    ];

    // Compute total values for percentage
    final totalValue = displayedGenres.fold<int>(0, (sum, item) => sum + item.value);

    final sections = List.generate(displayedGenres.length, (i) {
      final item = displayedGenres[i];
      final percentage = totalValue > 0 ? (item.value / totalValue) * 100 : 0.0;
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: item.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En Popüler Türler (Tür Dağılımı)',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 25,
                      sections: sections,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(displayedGenres.length, (i) {
                    final item = displayedGenres[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.key,
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.value}',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RatingDistributionCard extends StatelessWidget {
  final InsightsData data;
  const RatingDistributionCard({super.key, required this.data});

  static String _criticProfileText(double avg) {
    if (avg >= 7.8) {
      return "🍿 Cömert Bir İzleyicisin!\nİzlediğin yapımları genelde çok beğeniyorsun ve yüksek puanlar vermekten çekinmiyorsun. Pozitif yönleri görmeyi seviyorsun!";
    } else if (avg >= 5.5) {
      return "⚖️ Dengeli Bir İzleyicisin!\nNe çok cömert ne de çok sertsin. Yapımın hakkı neyse onu veriyorsun, puanların tam kıvamında!";
    } else {
      return "🧐 Sıkı Bir Eleştirmensin!\nKolay kolay yüksek puan vermiyorsun. Sinema zevkin oldukça seçici, puanın aslanın ağzında!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];
    double maxVal = 0;
    for (int rating = 1; rating <= 10; rating++) {
      final val = data.ratingDistribution[rating]?.toDouble() ?? 0.0;
      if (val > maxVal) maxVal = val;
      barGroups.add(
        BarChartGroupData(
          x: rating,
          barRods: [
            BarChartRodData(
              toY: val,
              color: AppTheme.ratingColor,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5.0,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kişisel Puan Dağılımı',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal + 1).clamp(5.0, 100.0),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surfaceColor,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} Adet',
                        GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(
                            '${value.toInt()}★',
                            style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Critic Profile box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📝', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eleştirmen Profilin',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _criticProfileText(data.averageRating),
                        style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
