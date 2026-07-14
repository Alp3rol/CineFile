import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final movie = item.movie;

    return Material(
      key: ValueKey('${movie.tmdbId}_${movie.isTv}'),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          children: [
            // Reorder drag listener
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_indicator_rounded, size: 18, color: Colors.white30),
            ),
            const SizedBox(width: 8),

            // Movie Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AppNetworkImage(
                imageUrl: movie.posterPath != null ? '${ApiConstants.imagePathW185}${movie.posterPath}' : '',
                width: 32,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

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
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isWatched) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${movie.releaseYear != null ? "${movie.releaseYear} • " : ""}${movie.director ?? "Yönetmen Yok"}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // View Details Button
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white60, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(tmdbId: movie.tmdbId, isTv: movie.isTv),
                  ),
                );
              },
            ),

            // Delete Movie Button
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
