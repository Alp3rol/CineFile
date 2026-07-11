import 'dart:math';
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

class TimeVisualizerCard extends StatefulWidget {
  final InsightsData data;
  const TimeVisualizerCard({super.key, required this.data});

  @override
  State<TimeVisualizerCard> createState() => _TimeVisualizerCardState();
}

class _TimeVisualizerCardState extends State<TimeVisualizerCard> {
  late final int _randomIndex;

  @override
  void initState() {
    super.initState();
    _randomIndex = Random().nextInt(16); // 16 different fun options
  }

  @override
  Widget build(BuildContext context) {
    final totalMins = widget.data.totalDurationMinutes;

    String formatNum(double val, int decimals) => val.toStringAsFixed(decimals);

    final comparisons = [
      (
        emoji: '💍',
        text: 'Yüzüklerin Efendisi (Uzatılmış Versiyon) Üçlemesi\'ni aralıksız ${formatNum(totalMins / 682, 1)} kez baştan sona izleyebilirdin!'
      ),
      (
        emoji: '✈️',
        text: 'İstanbul - Londra arası uçakla tam ${formatNum(totalMins / 210, 1)} kez gidiş-dönüş seyahat edebilirdin!'
      ),
      (
        emoji: '🧪',
        text: 'Kült dizi Breaking Bad\'i baştan sona tam ${formatNum(totalMins / 3100, 1)} kez maraton yapabilirdin!'
      ),
      (
        emoji: '🥾',
        text: 'Hiç durmadan yürüyerek İstanbul\'dan Ankara\'ya tam ${formatNum(totalMins / 5400, 1)} kez gidip gelebilirdin!'
      ),
      (
        emoji: '📚',
        text: 'Ortalama 8 saatlik okuma süresiyle tam ${formatNum(totalMins / 480, 0)} adet kitap bitirebilirdin!'
      ),
      (
        emoji: '🌯',
        text: 'Arka arkaya hiç durmadan tam ${formatNum(totalMins / 3, 0)} lahmacun yiyebilirdin! (Afiyet olsun)'
      ),
      (
        emoji: '🛰️',
        text: 'Uluslararası Uzay İstasyonu (ISS) Dünya\'nın etrafını tam ${formatNum(totalMins / 90, 0)} kez turlardı!'
      ),
      (
        emoji: '⚡',
        text: 'Bu sürede ışık uzay boşluğunda tam ${formatNum(totalMins * 18.0, 0)} milyon kilometre yol alırdı!'
      ),
      (
        emoji: '🧱',
        text: 'Minecraft\'ta hiç durmadan tam ${formatNum(totalMins * 120.0, 0)} blok yerleştirebilirdin!'
      ),
      (
        emoji: '☕',
        text: 'Arkadaşlarınla sohbet edip tam ${formatNum(totalMins / 15, 0)} fincan kahve içebilirdin!'
      ),
      (
        emoji: '🎵',
        text: 'Spotify\'da favori çalma listenden tam ${formatNum(totalMins / 3.5, 0)} şarkı dinleyebilirdin!'
      ),
      (
        emoji: '🎲',
        text: 'Hiç bitmeyecekmiş gibi hissettiren tam ${formatNum(totalMins / 180, 1)} Monopoly partisi yapabilirdin!'
      ),
      (
        emoji: '😴',
        text: 'Deliksiz ve huzurlu bir şekilde tam ${formatNum(totalMins / 480, 1)} gece uykusu çekebilirdin!'
      ),
      (
        emoji: '💇',
        text: 'Bu sürede saç tellerin toplamda tam ${formatNum(totalMins * 0.000287, 3)} milimetre uzardı!'
      ),
      (
        emoji: '🧬',
        text: 'Vücudun sen ekran karşısındayken tam ${formatNum(totalMins * 200.0, 0)} milyon yeni hücre üretti!'
      ),
      (
        emoji: '🌍',
        text: 'Dünya güneşin etrafındaki yörüngesinde tam ${formatNum(totalMins * 1.785, 0)} bin kilometre yol katetti!'
      ),
    ];

    final selected = comparisons[_randomIndex % comparisons.length];

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
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  selected.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.text,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ama film/dizi izlemek de harika bir tercih! 🎬',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.track_changes_rounded, color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '🎯 Haftalık İzleme Hedefi',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
