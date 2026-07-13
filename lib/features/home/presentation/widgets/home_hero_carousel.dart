import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/episode_logging.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';

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
          height: 400,
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.shows.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isActive ? 18 : 6,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accentColor : AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(3),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 400,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  // Never fabricate a backdrop path — fall back to the
                  // title-seeded placeholder gradient when it's missing.
                  imageUrl: backdropPath != null ? '${ApiConstants.imagePathW780}$backdropPath' : '',
                  seed: movie.title,
                  width: MediaQuery.of(context).size.width - 40,
                  height: 400,
                  fit: BoxFit.cover,
                ),
                // Bottom fade for text legibility over the backdrop.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 1.0],
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: GestureDetector(
                    onTap: () => advanceEpisodeWithToast(context, ref, show),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(10),
                      borderRadius: 100,
                      opacity: 0.85,
                      child: const Icon(Icons.add_rounded, color: AppTheme.accentColor, size: 20),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 76,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'İzlemeye Devam Et',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.title,
                        style: textTheme.displayMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total != null ? 'Bölüm $next / $total' : 'Bölüm $next',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
