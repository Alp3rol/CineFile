import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/glass_container.dart';

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const HomeSectionTitle({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümünü Gör',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.accentColor, size: 12),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        opacity: 0.4,
        child: Row(
          children: [
            Icon(Icons.movie_filter_outlined, color: AppTheme.textSecondary.withValues(alpha: 0.6), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(height: 1.4),
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 245,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final movie = items[index];
          final tmdbId = movie.tmdbId;
          return GestureDetector(
            onTap: () => onOpenDetail(tmdbId, movie.isTv),
            child: Container(
              width: 132,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster Container with Border & Shadow
                  Hero(
                    tag: 'poster_${tmdbId}_${movie.isTv}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            AppNetworkImage(
                              imageUrl: movie.posterPath != null
                                  ? '${ApiConstants.imagePathW500}${movie.posterPath}'
                                  : '',
                              seed: movie.title,
                              height: 185,
                              width: 132,
                              fit: BoxFit.cover,
                            ),
                            if (movie.releaseYear != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${movie.releaseYear}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    movie.title,
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    movie.director != null && movie.director!.isNotEmpty
                        ? movie.director!
                        : (movie.isTv ? 'Dizi' : 'Film'),
                    style: textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
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
