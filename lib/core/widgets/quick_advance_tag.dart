import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_provider.dart';
import '../database/episode_logging.dart';

// Compact "Bölüm X/Y +" pill for the latest watch record of an
// actively-watched show (see UserMovieSettings.isActivelyWatching). Tapping
// "+" logs the next episode immediately — no dialog, no screen — reusing
// the last given rating for that show as the new record's rating. Shared by
// the Journal table and card list views so the two can't drift out of sync.
class QuickAdvanceTag extends ConsumerWidget {
  final WatchRecordWithMovie item;
  const QuickAdvanceTag({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = item.movie.totalEpisodes;
    final last = item.setting!.lastWatchedEpisode ?? 0;

    return GestureDetector(
      onTap: () async {
        try {
          await logNextEpisode(ref: ref, movie: item.movie, setting: item.setting!, rating: item.record.rating);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bölüm kaydedilemedi: $e'), backgroundColor: Colors.redAccent),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.accentColor.withOpacity(0.4), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              total != null ? '$last/$total' : '$last',
              style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.add_circle_rounded, color: AppTheme.accentColor, size: 12),
          ],
        ),
      ),
    );
  }
}
