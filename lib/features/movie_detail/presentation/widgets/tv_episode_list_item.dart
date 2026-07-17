import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';

// A single episode row in the episode guide: still image, name/date/overview,
// and a tap-to-toggle watched checkmark.
class TvEpisodeListItem extends StatelessWidget {
  final Map<String, dynamic> episode;
  final int episodeNumber;
  final bool isWatched;
  // Whether this is the next unwatched episode in overall watch order —
  // shows a "Sıradaki" badge and an amber accent border instead of the
  // default unwatched styling.
  final bool isNextUp;
  final VoidCallback onToggleWatched;

  const TvEpisodeListItem({
    super.key,
    required this.episode,
    required this.episodeNumber,
    required this.isWatched,
    this.isNextUp = false,
    required this.onToggleWatched,
  });

  @override
  Widget build(BuildContext context) {
    final epName = episode['name'] as String? ?? '$episodeNumber. Bölüm';
    final overview = episode['overview'] as String? ?? 'Bölüm özeti bulunmuyor.';
    final stillPath = episode['still_path'] as String?;
    final airDateStr = episode['air_date'] as String? ?? '';

    String formattedDate = '';
    if (airDateStr.isNotEmpty) {
      final date = DateTime.tryParse(airDateStr);
      if (date != null) {
        formattedDate = DateFormat('d MMMM y', 'tr_TR').format(date);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        opacity: isWatched ? 0.6 : 0.4,
        useBlur: false, // Turn off blur for item rows to optimize list scroll performance
        border: Border.all(
          color: isWatched
              ? AppTheme.accentColor.withValues(alpha: 0.3)
              : (isNextUp ? Colors.amberAccent.withValues(alpha: 0.5) : AppTheme.borderColor),
          width: isWatched || isNextUp ? 1.5 : 1,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode Still Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(
                imageUrl: stillPath != null ? '${ApiConstants.imagePathW500}$stillPath' : '',
                seed: epName,
                width: 100,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Title, Date, Overview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNextUp && !isWatched) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '▶ SIRADAKİ',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    '$episodeNumber. $epName',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    overview,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white54,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Checked circle / checkmark toggle button
            GestureDetector(
              key: ValueKey('episode_check_$episodeNumber'),
              onTap: onToggleWatched,
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWatched ? AppTheme.accentColor : Colors.white30,
                    width: 1.5,
                  ),
                  color: isWatched ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.transparent,
                ),
                child: isWatched
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppTheme.accentColor,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
