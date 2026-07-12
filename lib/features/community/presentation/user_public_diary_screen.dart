import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';

// Renders a "Günlüğünü Paylaş" post's FROZEN entries snapshot — the list
// passed in is exactly what was captured at share time (see
// CommunityPost.entries / share_movie_picker_sheet.dart), not a live query.
// Movies the owner adds to their diary afterward intentionally never show
// up here; that's the whole point of a snapshot post.
class UserPublicDiaryScreen extends StatelessWidget {
  final String username;
  final List<Map<String, dynamic>> entries;
  const UserPublicDiaryScreen({super.key, required this.username, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('@$username', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Text(
                  'Paylaşılmış bir kayıt yok.',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.67,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final posterPath = entry['moviePosterPath'] as String?;
                  final rating = (entry['rating'] as num?)?.toDouble();
                  final movieId = entry['movieId'] as int;
                  final isTv = entry['isTv'] as bool? ?? false;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(tmdbId: movieId, isTv: isTv),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              posterPath != null && posterPath.isNotEmpty
                                  ? 'https://image.tmdb.org/t/p/w185$posterPath'
                                  : 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?q=80&w=185',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppTheme.surfaceColor,
                                child: const Icon(Icons.movie_rounded, color: Colors.white24),
                              ),
                            ),
                          ),
                        ),
                        if (rating != null)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: AppTheme.ratingColor, size: 10),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
