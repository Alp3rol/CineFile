import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
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
          SnackBar(content: Text(AppLocalizations.of(context).collectionStopSharingFailed)),
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
          SnackBar(content: Text(AppLocalizations.of(context).collectionReorderFailed)),
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  Row(
                    children: [
                      // Edit List Button
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: AppColors.textSecondary, size: 24),
                        onPressed: () => _showEditListDialog(context),
                      ),
                      // Delete List Button
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 24),
                        onPressed: () => _showDeleteConfirmDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            moviesAsync.when(
              loading: () => const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.accent))),
              error: (err, _) => Expanded(child: Center(child: Text(AppLocalizations.of(context).collectionsLoadFailed, style: const TextStyle(color: AppColors.textPrimary)))),
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
        SnackBar(content: Text(AppLocalizations.of(context).collectionRemovedMovie)),
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
  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.collectionDeleteTitle,
      message: l10n.collectionDeleteConfirm,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );

    if (confirmed != true) return;

    await deleteCustomList(ref, widget.list.id);
    // Only one pop now: AppDialog.confirm has already closed the dialog by the
    // time it returns, where the old inline version popped it itself and then
    // popped the screen. Popping twice from here would take the user back past
    // the collections grid.
    navigator.pop();
  }
}
