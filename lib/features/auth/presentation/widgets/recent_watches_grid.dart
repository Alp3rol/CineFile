import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_provider.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import 'profile_section_header.dart';

class RecentWatchesGrid extends ConsumerWidget {
  final String userId;
  const RecentWatchesGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(title: 'Son İzlediklerim'),
        const SizedBox(height: 16),
        ref.watch(watchRecordsForUserProvider(userId)).when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
          error: (err, stack) => Text('Hata: $err', style: const TextStyle(color: Colors.redAccent)),
          data: (records) {
            if (records.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Henüz hiç izleme kaydı eklenmemiş.',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.67,
              ),
              itemCount: records.length > 6 ? 6 : records.length,
              itemBuilder: (context, index) {
                final item = records[index];
                final posterPath = item.movie.posterPath;
                final rating = item.record.rating;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(
                          tmdbId: item.movie.tmdbId,
                          isTv: item.movie.isTv,
                        ),
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
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
