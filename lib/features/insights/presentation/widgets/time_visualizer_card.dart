import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../insights_provider.dart';

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
                  color: Colors.white.withValues(alpha: 0.05),
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
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ama film/dizi izlemek de harika bir tercih! 🎬',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
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
