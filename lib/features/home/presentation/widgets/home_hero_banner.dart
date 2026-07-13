import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/app_network_image.dart';

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
    final backdropPath = movie.backdropPath;
    final textTheme = Theme.of(context).textTheme;

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
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isSuggestion ? 'Bu Hafta Ne İzlesem?' : 'Son İzlediğin',
                              style: textTheme.titleMedium,
                            ),
                          ),
                          if (isSuggestion && onRefresh != null)
                            GestureDetector(
                              onTap: onRefresh,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                        ],
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
                        '${movie.releaseYear ?? "?"} • ${movie.isTv ? "Dizi" : "Film"}',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSuggestion ? 'Kütüphanende henüz izlemediğin bir yapım.' : 'En son izlediğin yapım.',
                        style: textTheme.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
