import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import 'create_collection_dialog.dart';

class CustomListDetailScreen extends ConsumerStatefulWidget {
  final CustomList list;
  const CustomListDetailScreen({super.key, required this.list});

  @override
  ConsumerState<CustomListDetailScreen> createState() => _CustomListDetailScreenState();
}

class _CustomListDetailScreenState extends ConsumerState<CustomListDetailScreen> {
  // Handles reordering of list movies
  void _onReorder(List<CustomListMovieWithMovie> items, int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final updated = List<CustomListMovieWithMovie>.from(items);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);

    // Map: (tmdbId, isTv) -> new rankingOrder (1-based index)
    final newRankings = <MovieKey, int>{};
    for (int i = 0; i < updated.length; i++) {
      newRankings[(tmdbId: updated[i].movie.tmdbId, isTv: updated[i].movie.isTv)] = i + 1;
    }

    try {
      await reorderCustomListMovies(ref, widget.list.id, newRankings);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sıralama kaydedilemedi, tekrar deneyin.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moviesAsync = ref.watch(moviesInCustomListProvider(widget.list.id));
    final allWatchRecordsAsync = ref.watch(allWatchRecordsProvider);
    final watchedMovieIds =
        allWatchRecordsAsync.value?.map((r) => (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv)).toSet() ?? {};

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Floating Header Bar (Back button, Title, Settings)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 12,
                      opacity: 0.7,
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  Row(
                    children: [
                      // Edit List Button
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.white70, size: 24),
                        onPressed: () => _showEditListDialog(context),
                      ),
                      // Delete List Button
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 24),
                        onPressed: () => _showDeleteConfirmDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            moviesAsync.when(
              loading: () => const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.accentColor))),
              error: (err, _) => Expanded(child: Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white)))),
              data: (movies) {
                final totalCount = movies.length;
                final watchedCount =
                    movies.where((m) => watchedMovieIds.contains((tmdbId: m.movie.tmdbId, isTv: m.movie.isTv))).length;
                final progress = totalCount == 0 ? 0.0 : watchedCount / totalCount;
                final coverPath = movies.isNotEmpty ? movies.first.movie.posterPath : null;

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List Summary Header (Collage Cover + Progress bar)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GlassContainer(
                          borderRadius: 16,
                          opacity: 0.5,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Mini Cover Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: coverPath != null
                                    ? AppNetworkImage(
                                        imageUrl: '${ApiConstants.imagePathW185}$coverPath',
                                        width: 50,
                                        height: 75,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.white12,
                                        width: 50,
                                        height: 75,
                                        child: const Icon(Icons.collections_bookmark_rounded, color: Colors.white24, size: 24),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Info and Progress Bar
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.list.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (widget.list.description != null && widget.list.description!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.list.description!,
                                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    
                                    // Progress indicators
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$totalCount Film • $watchedCount İzlenen',
                                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '%${(progress * 100).toInt()}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: progress == 1.0 ? Colors.greenAccent : AppTheme.accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 4,
                                        backgroundColor: Colors.white12,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          progress == 1.0 ? Colors.greenAccent : AppTheme.accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),

                      // Marathon challenge banner (v0.9.0)
                      if (widget.list.targetDate != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.4), width: 1.5),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentColor.withValues(alpha: 0.08),
                                  Colors.purple.withValues(alpha: 0.04),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, color: AppTheme.accentColor, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '🏁 Maraton Mücadelesi',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd.MM.yyyy').format(widget.list.targetDate!),
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.list.targetDate!.isBefore(DateTime.now())
                                            ? 'Süre Doldu! ⚠️'
                                            : 'Hedefe ulaşmak için ${widget.list.targetDate!.difference(DateTime.now()).inDays + 1} gün kaldı.',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        progress == 1.0
                                            ? 'Tebrikler, maratonu tamamladınız! 🎉'
                                            : 'Kalan: ${totalCount - watchedCount} film.',
                                        style: GoogleFonts.inter(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: progress == 1.0 ? Colors.greenAccent : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Movies List Area
                      Expanded(
                        child: movies.isEmpty
                            ? _buildEmptyMoviesState()
                            : ReorderableListView.builder(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                                itemCount: movies.length,
                                onReorderItem: (oldIdx, newIdx) => _onReorder(movies, oldIdx, newIdx),
                                itemBuilder: (context, index) {
                                  final item = movies[index];
                                  final movie = item.movie;
                                  final isWatched =
                                      watchedMovieIds.contains((tmdbId: movie.tmdbId, isTv: movie.isTv));

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
                                              imageUrl: movie.posterPath != null
                                                  ? '${ApiConstants.imagePathW185}${movie.posterPath}'
                                                  : '',
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
                                            onPressed: () => _removeMovie(movie.tmdbId, movie.isTv),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Remove film from this list
  void _removeMovie(int tmdbId, bool isTv) async {
    await removeMovieFromCustomList(ref, widget.list.id, tmdbId, isTv);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Film koleksiyondan çıkarıldı.')),
      );
    }
  }

  // Edit dialog
  void _showEditListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateCollectionDialog(list: widget.list),
    );
  }

  // Delete confirm
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text('Koleksiyonu Sil?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text(
            'Bu koleksiyonu silmek istediğinize emin misiniz? İçindeki filmler ve sıralamanız tamamen silinecektir. (Veritabanındaki filmleriniz kaybolmaz).',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                await deleteCustomList(ref, widget.list.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to collections grid
                }
              },
              child: const Text('Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyMoviesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_rounded, size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'Bu Koleksiyon Boş',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Text(
              'Keşfet sekmesinden filmler arayarak veya detay sayfalarından bu koleksiyona filmler ekleyebilirsiniz.',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
