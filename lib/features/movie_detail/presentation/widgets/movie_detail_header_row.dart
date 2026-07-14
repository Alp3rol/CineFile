import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import 'movie_watch_status_badge.dart';

// Poster + title + tagline + year/runtime/genres + TMDb rating badge row at
// the top of the movie detail screen.
class MovieDetailHeaderRow extends StatelessWidget {
  final int tmdbId;
  final bool isTv;
  final String? posterPath;
  final String title;
  final String tagline;
  final String year;
  final int runtime;
  final String genresString;
  final num? voteAverage;
  final int? voteCount;
  final UserMovieSetting? settings;
  final int? totalEpisodes;

  const MovieDetailHeaderRow({
    super.key,
    required this.tmdbId,
    required this.isTv,
    required this.posterPath,
    required this.title,
    required this.tagline,
    required this.year,
    required this.runtime,
    required this.genresString,
    required this.voteAverage,
    required this.voteCount,
    required this.settings,
    required this.totalEpisodes,
  });

  static String _formatVoteCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero animation for poster
        Hero(
          tag: 'poster_${tmdbId}_$isTv',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(
              imageUrl: posterPath != null ? '${ApiConstants.imagePathW500}$posterPath' : '',
              seed: title,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Movie Metadata
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (tagline.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '"$tagline"',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                [
                  if (year.isNotEmpty) year,
                  if (runtime > 0) '$runtime dk',
                  if (genresString.isNotEmpty) genresString,
                ].join(' • '),
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
              ),
              if (voteAverage != null && voteAverage! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0d253f).withValues(alpha: 0.7), // TMDb dark blue
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF90cea1).withValues(alpha: 0.5), // TMDb light green
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFF90cea1),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            voteAverage!.toStringAsFixed(1),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (voteCount != null && voteCount! > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${_formatVoteCount(voteCount!)})',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (isTv) MovieWatchStatusBadge(setting: settings, totalEpisodes: totalEpisodes),
            ],
          ),
        ),
      ],
    );
  }
}
