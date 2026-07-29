import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/episode_logging.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';

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
          height: 360,
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.shows.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accentColor : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 0,
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
    final backdropPath = movie.backdropPath;
    final textTheme = Theme.of(context).textTheme;
    final total = movie.totalEpisodes;
    final next = (show.setting.lastWatchedEpisode ?? 0) + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: 0.2),
                blurRadius: 26,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: 360,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: backdropPath != null ? '${ApiConstants.imagePathW780}$backdropPath' : '',
                    seed: movie.title,
                    width: MediaQuery.of(context).size.width - 40,
                    height: 360,
                    fit: BoxFit.cover,
                  ),
                  // Multi-stop cinematic gradient
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.25, 0.65, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),

                  // Top Header Badge Row
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.4), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_circle_fill_rounded, color: AppTheme.accentColor, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context).homeContinueWatching,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Content & Quick Episode Increment Action
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Episode Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                          ),
                          child: Text(
                            total != null ? AppLocalizations.of(context).homeNextEpisodeOf(next, total) : AppLocalizations.of(context).homeNextEpisode(next),
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Movie Title
                        Text(
                          movie.title,
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 12),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons Row
                        Row(
                          children: [
                            // Primary Watch / Detail Action
                            Expanded(
                              child: GestureDetector(
                                onTap: onTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentColor,
                                        AppTheme.accentColor.withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentColor.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppLocalizations.of(context).homeContinue,
                                        style: textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Quick Episode Increment Button (+1)
                            GestureDetector(
                              onTap: () => advanceEpisodeWithToast(context, ref, show),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add_rounded, color: AppTheme.accentColor, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context).homeAddOneEpisode,
                                      style: textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
