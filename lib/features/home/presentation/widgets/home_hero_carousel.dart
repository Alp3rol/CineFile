import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/episode_logging.dart';
import '../../../../core/ui/ui.dart';
import 'home_hero_shell.dart';

/// Highest-priority hero variant: when the user has actively-watching shows
/// (see UserMovieSettings.isActivelyWatching), the hero shows those instead
/// of the "Bu Hafta Ne İzlesem?" suggestion / last-watched fallback
/// (HomeHeroBanner). Renders as a swipeable PageView with a dot indicator
/// when there's more than one active show.
class HomeActiveHeroCarousel extends StatefulWidget {
  final List<ActivelyWatchingShow> shows;
  final void Function(int tmdbId, bool isTv) onTap;

  const HomeActiveHeroCarousel({super.key, required this.shows, required this.onTap});

  @override
  State<HomeActiveHeroCarousel> createState() => _HomeActiveHeroCarouselState();
}

class _HomeActiveHeroCarouselState extends State<HomeActiveHeroCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: HomeHeroShell.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.shows.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final show = widget.shows[index];
              return _HomeActiveHeroSlide(
                show: show,
                onTap: () => widget.onTap(show.movie.tmdbId, show.movie.isTv),
              );
            },
          ),
        ),
        if (widget.shows.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.shows.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: AppDuration.normal,
                curve: AppDuration.curve,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                height: 6,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent
                      : AppColors.textPrimary.withValues(alpha: AppOpacity.soft),
                  borderRadius: AppRadius.allPill,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.accent
                                .withValues(alpha: AppOpacity.strong),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _HomeActiveHeroSlide extends ConsumerWidget {
  final ActivelyWatchingShow show;
  final VoidCallback onTap;

  const _HomeActiveHeroSlide({required this.show, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = show.movie;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final total = movie.totalEpisodes;
    final next = (show.setting.lastWatchedEpisode ?? 0) + 1;

    return HomeHeroShell(
      backdropPath: movie.backdropPath,
      seed: movie.title,
      onTap: onTap,
      // The continue-watching hero outranks the suggestion hero, so it wears
      // the accent border and glow rather than the neutral one.
      accented: true,
      top: Row(
        children: [
          HeroBadge(
            label: l10n.homeContinueWatching,
            icon: Icons.play_circle_fill_rounded,
            iconColor: AppColors.accent,
            borderColor: AppColors.accent.withValues(alpha: AppOpacity.medium),
            glow: true,
          ),
        ],
      ),
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.onImage.withValues(alpha: AppOpacity.soft),
              borderRadius: AppRadius.allSm,
              border: Border.all(
                color: AppColors.onImage.withValues(alpha: AppOpacity.soft),
                width: AppSize.hairline,
              ),
            ),
            child: Text(
              total != null
                  ? l10n.homeNextEpisodeOf(next, total)
                  : l10n.homeNextEpisode(next),
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.onImage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            movie.title,
            style: textTheme.displayMedium?.copyWith(
              height: 1.2,
              shadows: const [Shadow(color: AppColors.shadow, blurRadius: 12)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: HeroActionButton(
                  label: l10n.homeContinue,
                  icon: Icons.play_arrow_rounded,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              HeroSecondaryButton(
                label: l10n.homeAddOneEpisode,
                icon: Icons.add_rounded,
                onTap: () => advanceEpisodeWithToast(context, ref, show),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
