import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/ui/ui.dart';
import 'home_hero_shell.dart';

/// Cinematic hero card at the top of the home screen — a large backdrop with
/// a bottom gradient fade. Prefers a "Bu Hafta Ne İzlesem?" suggestion (an
/// unwatched title); when the library has nothing left unwatched, falls back
/// to the most recently watched title instead of disappearing entirely, so
/// the screen always has a visual anchor at the top for active users too.
class HomeHeroBanner extends StatelessWidget {
  final Movie movie;
  final bool isSuggestion;
  final VoidCallback? onRefresh;
  final VoidCallback onTap;

  const HomeHeroBanner({
    super.key,
    required this.movie,
    required this.isSuggestion,
    this.onRefresh,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return HomeHeroShell(
      backdropPath: movie.backdropPath,
      seed: movie.title,
      onTap: onTap,
      top: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HeroBadge(
            label: isSuggestion
                ? l10n.homeHeroWhatToWatch
                : l10n.homeHeroLastWatched,
            icon: isSuggestion
                ? Icons.auto_awesome_rounded
                : Icons.history_rounded,
            iconColor: isSuggestion ? AppColors.rating : AppColors.accent,
          ),
          if (isSuggestion && onRefresh != null)
            AppPressable(
              onTap: onRefresh,
              borderRadius: AppRadius.pill,
              semanticLabel: l10n.homeHeroWhatToWatch,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.shadow.withValues(alpha: AppOpacity.strong),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.onImage.withValues(alpha: AppOpacity.soft),
                    width: AppSize.hairline,
                  ),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.onImage,
                  size: AppSize.iconSm,
                ),
              ),
            ),
        ],
      ),
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppBadge(
                label: movie.isTv
                    ? l10n.homeHeroShowBadge
                    : l10n.homeHeroMovieBadge,
                tone: AppBadgeTone.accent,
                outlined: true,
              ),
              if (movie.releaseYear != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${movie.releaseYear}',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.onImage.withValues(alpha: AppOpacity.heavy),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            movie.title,
            style: textTheme.displayMedium?.copyWith(
              height: 1.2,
              // The title sits over an unknown frame, so it carries its own
              // drop shadow rather than relying on the gradient alone.
              shadows: const [Shadow(color: AppColors.shadow, blurRadius: 12)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              HeroActionButton(
                label: l10n.homeHeroDetails,
                icon: Icons.play_arrow_rounded,
                onTap: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
