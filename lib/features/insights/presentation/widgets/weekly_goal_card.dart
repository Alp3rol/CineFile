import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../insights_provider.dart';

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
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
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
