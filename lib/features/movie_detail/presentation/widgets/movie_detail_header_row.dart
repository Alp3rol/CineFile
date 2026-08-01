import 'package:flutter/material.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
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

  static const double _posterWidth = 120;
  static const double _posterHeight = 180;

  static String _formatVoteCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero animation for poster
        Hero(
          tag: 'poster_${tmdbId}_$isTv',
          child: ClipRRect(
            borderRadius: AppRadius.allMd,
            child: AppNetworkImage(
              imageUrl: posterPath != null
                  ? '${ApiConstants.imagePathW500}$posterPath'
                  : '',
              seed: title,
              width: _posterWidth,
              height: _posterHeight,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),

        // Movie Metadata
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.displayMedium),
              if (tagline.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '"$tagline"',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                [
                  if (year.isNotEmpty) year,
                  if (runtime > 0) '$runtime dk',
                  if (genresString.isNotEmpty) genresString,
                ].join(' • '),
                style: textTheme.labelLarge
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              if (voteAverage != null && voteAverage! > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    // TMDb's own colours, from BrandColors rather than
                    // AppColors: this badge represents someone else's brand,
                    // so it must not move when ours does.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: BrandColors.tmdbNavy
                            .withValues(alpha: AppOpacity.heavy),
                        borderRadius: AppRadius.allSm,
                        border: Border.all(
                          color: BrandColors.tmdbGreen
                              .withValues(alpha: AppOpacity.strong),
                          width: AppSize.hairline,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: BrandColors.tmdbGreen,
                            size: AppSize.iconSm,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            voteAverage!.toStringAsFixed(1),
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.onImage,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (voteCount != null && voteCount! > 0) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '(${_formatVoteCount(voteCount!)})',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.onImage
                                    .withValues(alpha: AppOpacity.heavy),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (isTv)
                MovieWatchStatusBadge(
                  setting: settings,
                  totalEpisodes: totalEpisodes,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
