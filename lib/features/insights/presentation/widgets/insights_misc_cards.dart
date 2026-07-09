import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../settings/presentation/settings_provider.dart';
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
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = data.totalDurationMinutes ~/ 60;
    final totalMinutes = data.totalDurationMinutes % 60;
    final durationStr = totalHours > 0 ? '${totalHours}sa ${totalMinutes}dk' : '${totalMinutes}dk';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _buildMiniStatCard('Toplam İzleme', '${data.totalWatchCount}', Icons.movie_filter_rounded, Colors.blueAccent),
        _buildMiniStatCard('Tekil İçerik', '${data.uniqueTitleCount}', Icons.local_play_rounded, Colors.purpleAccent),
        _buildMiniStatCard('Toplam Süre', durationStr, Icons.timelapse_rounded, Colors.tealAccent),
        _buildMiniStatCard('Ort. Puan', '${data.averageRating.toStringAsFixed(1)} / 10', Icons.star_rounded, AppTheme.ratingColor),
      ],
    );
  }
}

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
              backgroundColor: Colors.white.withOpacity(0.05),
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

class TimeVisualizerCard extends StatelessWidget {
  final InsightsData data;
  const TimeVisualizerCard({super.key, required this.data});

  Widget _buildComparisonRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalMins = data.totalDurationMinutes;
    final lotrMarathons = (totalMins / 682).toStringAsFixed(1); // Extended LotR trilogy is approx 682 mins
    final flights = (totalMins / 210).toStringAsFixed(1);       // Istanbul-London is approx 210 mins (3.5 hours)
    final seriesWatches = (totalMins / 40).toStringAsFixed(0);   // Approx single episode is 40 mins

    return GlassContainer(
      borderRadius: 20,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍿 Bu Sürede Neler Yapabilirdin?',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 18),
          _buildComparisonRow('💍', 'Yüzüklerin Efendisi (Uzatılmış Versiyon) Üçlemesi\'ni aralıksız $lotrMarathons kez baştan sona izleyebilirdin!'),
          _buildComparisonRow('✈️', 'İstanbul - Londra arası uçakla tam $flights kez gidiş-dönüş seyahat edebilirdin!'),
          _buildComparisonRow('📺', 'Ortalama 40 dakikalık dizilerden tam $seriesWatches bölüm tüketebilirdin!'),
        ],
      ),
    );
  }
}

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
              backgroundColor: Colors.white.withOpacity(0.04),
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
                  color: AppTheme.accentColor.withOpacity(0.15),
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

class WeeklyGoalCard extends ConsumerWidget {
  final InsightsData data;
  const WeeklyGoalCard({super.key, required this.data});

  void _showEditGoalDialog(BuildContext context, WidgetRef ref, int weeklyGoal) {
    int tempGoal = weeklyGoal;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Haftalık Hedefi Ayarla',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Haftada kaç film/dizi izlemek istersiniz?',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$tempGoal İçerik',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.accentColor,
                      inactiveTrackColor: Colors.grey.shade800,
                      thumbColor: AppTheme.ratingColor,
                    ),
                    child: Slider(
                      value: tempGoal.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (val) {
                        setDialogState(() {
                          tempGoal = val.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                  onPressed: () {
                    ref.read(weeklyGoalProvider.notifier).saveGoal(tempGoal);
                    Navigator.pop(context);
                  },
                  child: const Text('Kaydet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyGoal = ref.watch(weeklyGoalProvider);
    final count = data.thisWeekWatchCount;
    final progress = weeklyGoal > 0 ? (count / weeklyGoal).clamp(0.0, 1.0) : 1.0;

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
              Row(
                children: [
                  const Icon(Icons.track_changes_rounded, color: AppTheme.accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '🎯 Haftalık İzleme Hedefi',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white60, size: 16),
                onPressed: () => _showEditGoalDialog(context, ref, weeklyGoal),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                        children: [
                          const TextSpan(text: 'Bu hafta '),
                          TextSpan(
                            text: '$count ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                          ),
                          const TextSpan(text: 'film/dizi izlediniz. (Hedef: '),
                          TextSpan(
                            text: '$weeklyGoal',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const TextSpan(text: ')'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress >= 1.0
                          ? 'Tebrikler, bu haftaki hedefinize ulaştınız! 🎉'
                          : 'Hedefe ulaşmak için ${weeklyGoal - count} film daha izlemelisiniz.',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: progress >= 1.0 ? Colors.greenAccent : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.04),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Colors.greenAccent : AppTheme.accentColor,
                      ),
                      strokeWidth: 4,
                    ),
                  ),
                  Text(
                    '%${(progress * 100).toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
