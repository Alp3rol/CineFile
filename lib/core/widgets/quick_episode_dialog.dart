import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../database/episode_logging.dart';

// A lightweight "log the next episode" dialog for actively-watched shows —
// used from both Home and Journal's "Aktif İzlediklerin" quick-add sections,
// so logging an episode doesn't require opening the full "İzleme Kaydı Ekle"
// sheet (date/time/mood/place/companion/notes/tags) every time.
Future<void> showQuickEpisodeDialog(BuildContext context, WidgetRef ref, ActivelyWatchingShow show) async {
  final totalEpisodes = show.movie.totalEpisodes;
  final lastWatched = show.setting.lastWatchedEpisode ?? 0;
  final nextEpisode = totalEpisodes != null ? (lastWatched + 1).clamp(1, totalEpisodes) : lastWatched + 1;

  double rating = 7.0;
  var isSaving = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: Text(
              show.movie.title,
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalEpisodes != null ? 'Bölüm $nextEpisode / $totalEpisodes izlendi olarak kaydedilecek.' : 'Bölüm $nextEpisode izlendi olarak kaydedilecek.',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puanın:',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Text(
                      '$rating / 10',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.ratingColor),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(dialogContext).copyWith(
                    activeTrackColor: AppTheme.accentColor,
                    inactiveTrackColor: Colors.grey.shade800,
                    thumbColor: AppTheme.ratingColor,
                  ),
                  child: Slider(
                    value: rating,
                    min: 1.0,
                    max: 10.0,
                    divisions: 18,
                    label: rating.toString(),
                    onChanged: isSaving ? null : (val) => setDialogState(() => rating = val),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text('İptal', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await logNextEpisode(ref: ref, movie: show.movie, setting: show.setting, rating: rating);
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Bölüm kaydedilemedi: $e'), backgroundColor: Colors.redAccent),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Bölümü Ekle', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    },
  );
}
