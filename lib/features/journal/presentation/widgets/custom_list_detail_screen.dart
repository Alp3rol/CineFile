import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import 'create_collection_dialog.dart';
import 'custom_list_empty_state.dart';
import 'custom_list_marathon_banner.dart';
import 'custom_list_movie_tile.dart';
import 'custom_list_summary_header.dart';

class CustomListDetailScreen extends ConsumerStatefulWidget {
  final CustomList list;
  const CustomListDetailScreen({super.key, required this.list});

  @override
  ConsumerState<CustomListDetailScreen> createState() => _CustomListDetailScreenState();
}

class _CustomListDetailScreenState extends ConsumerState<CustomListDetailScreen> {
  // Mirrors widget.list.isPublic locally so the badge/button update
  // immediately after _stopSharing — widget.list is a snapshot passed in
  // by the caller, not a reactively-watched provider value.
  late bool _isPublic = widget.list.isPublic;

  Future<void> _stopSharing() async {
    try {
      await setCollectionVisibility(ref, widget.list.id, false);
      if (mounted) setState(() => _isPublic = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşım durdurulamadı, tekrar deneyin.')),
        );
      }
    }
  }

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
                      CustomListSummaryHeader(
                        list: widget.list,
                        coverPath: coverPath,
                        totalCount: totalCount,
                        watchedCount: watchedCount,
                        progress: progress,
                        isPublic: _isPublic,
                        onStopSharing: _stopSharing,
                      ),
                      const SizedBox(height: 8),

                      // Marathon challenge banner (v0.9.0)
                      if (widget.list.targetDate != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: CustomListMarathonBanner(
                            targetDate: widget.list.targetDate!,
                            progress: progress,
                            remainingCount: totalCount - watchedCount,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Movies List Area
                      Expanded(
                        child: movies.isEmpty
                            ? const CustomListEmptyState()
                            : ReorderableListView.builder(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                                itemCount: movies.length,
                                onReorderItem: (oldIdx, newIdx) => _onReorder(movies, oldIdx, newIdx),
                                itemBuilder: (context, index) {
                                  final item = movies[index];
                                  final isWatched = watchedMovieIds
                                      .contains((tmdbId: item.movie.tmdbId, isTv: item.movie.isTv));

                                  return CustomListMovieTile(
                                    item: item,
                                    index: index,
                                    isWatched: isWatched,
                                    onRemove: () => _removeMovie(item.movie.tmdbId, item.movie.isTv),
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
}
