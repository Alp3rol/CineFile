import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../constants/api_constants.dart';
import '../database/database_provider.dart';
import 'app_network_image.dart';
import 'glass_container.dart';
import 'quick_episode_dialog.dart';

// Horizontal "Aktif İzlediklerin" strip — shared by Home and Journal so a
// show being actively tracked (see UserMovieSettings.isActivelyWatching)
// can get its next episode logged in one tap, without opening the full
// "İzleme Kaydı Ekle" sheet. Renders nothing when there's nothing active.
class ActivelyWatchingRow extends ConsumerWidget {
  final void Function(int tmdbId, bool isTv)? onOpenDetail;

  const ActivelyWatchingRow({super.key, this.onOpenDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shows = ref.watch(activelyWatchingProvider).value ?? const [];
    if (shows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Aktif İzlediklerin',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 235,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: shows.length,
            itemBuilder: (context, index) {
              final show = shows[index];
              final movie = show.movie;
              final total = movie.totalEpisodes;
              final next = (show.setting.lastWatchedEpisode ?? 0) + 1;

              return GestureDetector(
                onTap: () => onOpenDetail?.call(movie.tmdbId, movie.isTv),
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppNetworkImage(
                              imageUrl: movie.posterPath != null ? '${ApiConstants.imagePathW500}${movie.posterPath}' : '',
                              seed: movie.title,
                              height: 180,
                              width: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: GestureDetector(
                              onTap: () => showQuickEpisodeDialog(context, ref, show),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(6),
                                borderRadius: 100,
                                opacity: 0.85,
                                child: const Icon(Icons.add_rounded, color: AppTheme.accentColor, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        total != null ? 'Bölüm $next / $total' : 'Bölüm $next',
                        style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
