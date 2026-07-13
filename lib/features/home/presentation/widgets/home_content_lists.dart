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
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Tümünü Gör',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.accentColor),
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
      height: 235,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final movie = items[index];
          final tmdbId = movie.tmdbId;
          return GestureDetector(
            onTap: () => onOpenDetail(tmdbId, movie.isTv),
            child: Container(
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Hero(
                    tag: 'poster_${tmdbId}_${movie.isTv}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppNetworkImage(
                        imageUrl: movie.posterPath != null
                            ? '${ApiConstants.imagePathW500}${movie.posterPath}'
                            : '',
                        seed: movie.title,
                        height: 180,
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    movie.title,
                    style: textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subtitle
                  Text(
                    '${movie.releaseYear ?? "?"} • ${movie.director ?? "Yönetmen Yok"}',
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
