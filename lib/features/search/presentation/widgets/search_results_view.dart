import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import '../search_provider.dart';

// Loading/error/empty-query/no-results/results-grid states for
// SearchScreen's main body, driven by SearchState plus the already
// genre-filtered results list (filtering itself stays in SearchScreen,
// which also owns the currentUser-independent dynamic-background sync).
class SearchResultsView extends StatelessWidget {
  final SearchState state;
  final List<Map<String, dynamic>> results;
  final ScrollController scrollController;

  const SearchResultsView({
    super.key,
    required this.state,
    required this.results,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Hata oluştu: ${state.errorMessage}',
            style: GoogleFonts.inter(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Default view: If search is empty
    if (state.query.trim().isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Keşfetmeye Başlayın',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Milyonlarca film arasından arama yapın.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            // TMDB Attribution
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Veriler ',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Image.asset(
                    'assets/images/tmdb_logo.png',
                    height: 10,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    ' tarafından sağlanmaktadır.',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Sonuç Bulunamadı',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Farklı bir kelime aramayı deneyin.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Grid presentation (Letterboxd stili 3'lü poster grid)
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // Ratio for standard movie posters
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
        final posterPath = movie['poster_path'] as String?;
        final title = movie['title'] as String;
        final releaseDate = movie['release_date'] as String? ?? '';
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
                      imageUrl: posterPath != null ? '${ApiConstants.imagePathW500}$posterPath' : '',
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
