import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_provider.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';

// Live view of a shared collection — unlike UserPublicDiaryScreen (a frozen
// snapshot), this screen watches sharedCollectionProvider directly, so it
// reflects the owner's edits in real time. Renders a graceful "no longer
// shared" state if the owner has turned sharing off (the doc is deleted,
// not just emptied — see movie_repository.dart's setCollectionVisibility).
class SharedCollectionDetailScreen extends ConsumerWidget {
  final String collectionRefId;
  const SharedCollectionDetailScreen({super.key, required this.collectionRefId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(sharedCollectionProvider(collectionRefId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Koleksiyon', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
          error: (err, stack) => Center(
            child: Text('Hata: $err', style: const TextStyle(color: Colors.redAccent)),
          ),
          data: (data) {
            if (data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.collections_bookmark_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'Bu koleksiyon artık paylaşılmıyor',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final name = data['name'] as String? ?? '';
            final description = data['description'] as String?;
            final movies = (data['movies'] as List<dynamic>? ?? []).map((m) => Map<String, dynamic>.from(m as Map)).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (description != null && description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: movies.isEmpty
                      ? Center(
                          child: Text(
                            'Bu koleksiyonda henüz film yok.',
                            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.67,
                          ),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            final posterPath = movie['posterPath'] as String?;
                            final tmdbId = movie['tmdbId'] as int;
                            final isTv = movie['isTv'] as bool? ?? false;

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailScreen(tmdbId: tmdbId, isTv: isTv),
                                  ),
                                );
                              },
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
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
