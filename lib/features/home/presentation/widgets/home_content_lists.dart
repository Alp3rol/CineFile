import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Section heading on the home screen: an accent rule, the title, and a
/// "see all" action.
///
/// Kept separate from the plain [AppSection] in core/ui because of that accent
/// rule — home marks its sections with it, settings marks them by colouring
/// the heading text. Those are two section languages in one app and only one
/// should survive, but picking which is a design decision rather than a
/// mechanical one, so both stand for now.
class HomeSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const HomeSectionTitle({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.xs,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadius.allXs,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent
                          .withValues(alpha: AppOpacity.strong),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context).homeSeeAll),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.accent,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Shown when a section has no real data yet.
class HomeEmptySection extends StatelessWidget {
  final String message;

  const HomeEmptySection({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppCard(
        tone: AppCardTone.translucent,
        child: Row(
          children: [
            Icon(
              Icons.movie_filter_outlined,
              color: AppColors.textSecondary
                  .withValues(alpha: AppOpacity.strong),
              size: AppSize.iconLg,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeRecentlyAddedList extends StatelessWidget {
  final List<Movie> items;
  final void Function(int tmdbId, bool isTv) onOpenDetail;

  const HomeRecentlyAddedList({super.key, required this.items, required this.onOpenDetail});

  static const double _posterWidth = 132;
  static const double _posterHeight = 185;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 245,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final movie = items[index];
          final tmdbId = movie.tmdbId;

          return AppPressable(
            onTap: () => onOpenDetail(tmdbId, movie.isTv),
            borderRadius: AppRadius.lg,
            semanticLabel: movie.title,
            child: Container(
              width: _posterWidth,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'poster_${tmdbId}_${movie.isTv}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.allLg,
                        border: Border.all(
                          color: AppColors.textPrimary
                              .withValues(alpha: AppOpacity.subtle),
                          width: AppSize.hairline,
                        ),
                        boxShadow: AppElevation.low(AppColors.shadow),
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.allLg,
                        child: Stack(
                          children: [
                            AppNetworkImage(
                              imageUrl: movie.posterPath != null
                                  ? '${ApiConstants.imagePathW500}${movie.posterPath}'
                                  : '',
                              seed: movie.title,
                              height: _posterHeight,
                              width: _posterWidth,
                              fit: BoxFit.cover,
                            ),
                            if (movie.releaseYear != null)
                              Positioned(
                                top: AppSpacing.sm,
                                right: AppSpacing.sm,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    // A dark scrim rather than a themed tint:
                                    // this sits on poster art, where a
                                    // translucent surface colour would be
                                    // illegible over a bright frame.
                                    color: AppColors.shadow
                                        .withValues(alpha: AppOpacity.heavy),
                                    borderRadius: AppRadius.allXs,
                                  ),
                                  child: Text(
                                    '${movie.releaseYear}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.onImage,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    movie.title,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    movie.director != null && movie.director!.isNotEmpty
                        ? movie.director!
                        : (movie.isTv
                            ? AppLocalizations.of(context).graphNodeShow
                            : AppLocalizations.of(context).graphNodeMovie),
                    style: textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
