import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_provider.dart';
import '../database/episode_logging.dart';

import '../widgets/premium_toast.dart';

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
    final next = (item.setting!.lastWatchedEpisode ?? 0) + 1;

    return TextButton(
      onPressed: () async {
        try {
          await logNextEpisode(ref: ref, movie: item.movie, setting: item.setting!, rating: item.record.rating);
        } catch (e) {
          if (context.mounted) {
            showPremiumToast(context, 'Bölüm kaydedilemedi: $e', isError: true);
          }
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: AppTheme.accentColor.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.4), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            total != null ? '$next/$total' : '$next',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.add_circle_rounded,
            color: AppTheme.accentColor,
            size: 14,
          ),
        ],
      ),
    );
  }
}
