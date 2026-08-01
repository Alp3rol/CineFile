import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';

// One reorderable row in CustomListDetailScreen's movie list.
class CustomListMovieTile extends StatelessWidget {
  final CustomListMovieWithMovie item;
  final int index;
  final bool isWatched;
  final VoidCallback onRemove;

  const CustomListMovieTile({
    super.key,
    required this.item,
    required this.index,
    required this.isWatched,
    required this.onRemove,
  });

  static const double _posterWidth = 32;
  static const double _posterHeight = 48;

  @override
  Widget build(BuildContext context) {
    final movie = item.movie;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      key: ValueKey('${movie.tmdbId}_${movie.isTv}'),
      color: AppColors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Reorder drag listener
            ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_indicator_rounded,
                size: AppSize.iconSm,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Movie Poster
            ClipRRect(
              borderRadius: AppRadius.allXs,
              child: AppNetworkImage(
                imageUrl: movie.posterPath != null
                    ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                    : '',
                seed: movie.title,
                width: _posterWidth,
                height: _posterHeight,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Title & Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isWatched) ...[
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: AppSize.iconSm,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.recordYearDirector(
                      movie.releaseYear?.toString() ?? l10n.yearUnknown,
                      movie.director ?? l10n.directorMissing,
                    ),
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // View Details Button
            IconButton(
              tooltip: movie.title,
              icon: const Icon(
                Icons.info_outline_rounded,
                size: AppSize.iconMd,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(
                      tmdbId: movie.tmdbId,
                      isTv: movie.isTv,
                    ),
                  ),
                );
              },
            ),

            // Delete Movie Button
            IconButton(
              tooltip: l10n.commonDelete,
              color: AppColors.error,
              icon: const Icon(
                Icons.remove_circle_outline_rounded,
                size: AppSize.iconMd,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
