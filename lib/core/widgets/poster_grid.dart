import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../constants/api_constants.dart';
import 'app_network_image.dart';
import '../../features/movie_detail/presentation/movie_detail_screen.dart';

class PosterGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  const PosterGrid({
    super.key,
    required this.items,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // Ratio for standard movie posters
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final movie = items[index];
        final posterPath = movie['poster_path'] as String?;
        final title = (movie['title'] ?? movie['name'] ?? 'Bilinmeyen Yapım') as String;
        final releaseDate = (movie['release_date'] ?? movie['first_air_date'] ?? '') as String;
        final year = releaseDate.split('-').first;

        final movieId = movie['id'] as int;
        final isTv = movie['media_type'] == 'tv';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(tmdbId: movieId, isTv: isTv),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Frame
              Expanded(
                child: Hero(
                  tag: 'poster_${movieId}_$isTv',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AppNetworkImage(
                      imageUrl: posterPath != null && posterPath.isNotEmpty
                          ? '${ApiConstants.imagePathW500}$posterPath'
                          : '',
                      seed: title,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Film Title (Grid subtitle)
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Year and Rating Info
              Text(
                year.isNotEmpty ? year : 'Bilinmeyen Yıl',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
