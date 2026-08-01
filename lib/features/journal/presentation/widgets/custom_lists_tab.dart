import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import 'custom_list_detail_screen.dart';
import 'create_collection_dialog.dart';

class CustomListsTab extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  const CustomListsTab({super.key, this.scrollController});

  @override
  ConsumerState<CustomListsTab> createState() => _CustomListsTabState();
}

class _CustomListsTabState extends ConsumerState<CustomListsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final customListsAsync = ref.watch(customListsProvider);
    final allWatchRecordsAsync = ref.watch(allWatchRecordsProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: customListsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(child: Text(AppLocalizations.of(context).collectionsLoadFailed, style: const TextStyle(color: AppColors.textPrimary))),
        data: (lists) {
          if (lists.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          // Build a list of all watched movie IDs to calculate progress
          final watchedMovieIds =
              allWatchRecordsAsync.value?.map((r) => (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv)).toSet() ?? {};

          return Column(
            children: [
              // Add List button row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).collectionsTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box_rounded, color: AppColors.accent, size: 28),
                      onPressed: () => _showCreateListDialog(context, ref),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    return _buildListCard(context, ref, list, watchedMovieIds);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Cover Card for each list
  Widget _buildListCard(BuildContext context, WidgetRef ref, CustomList list, Set<MovieKey> watchedIds) {
    // Watch movies stream to calculate cover image & progress
    final moviesAsync = ref.watch(moviesInCustomListProvider(list.id));

    return moviesAsync.when(
      loading: () => const Card(color: AppColors.surface),
      error: (error, stackTrace) => const Card(color: AppColors.surface),
      data: (movies) {
        final totalCount = movies.length;
        final watchedCount =
            movies.where((m) => watchedIds.contains((tmdbId: m.movie.tmdbId, isTv: m.movie.isTv))).length;
        final progress = totalCount == 0 ? 0.0 : watchedCount / totalCount;
        
        // Use first movie poster as cover, if exists
        final coverPath = movies.isNotEmpty ? movies.first.movie.posterPath : null;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomListDetailScreen(list: list),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // 1. Cover Image Background
                Positioned.fill(
                  child: coverPath != null
                      ? LayoutBuilder(
                          builder: (context, constraints) => AppNetworkImage(
                            imageUrl: '${ApiConstants.imagePathW500}$coverPath',
                            width: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
                            height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
                            fit: BoxFit.cover,
                            seed: list.name,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.surfaceRaised,
                                AppColors.surface,
                              ],
                            ),
                          ),
                          child: const Icon(Icons.collections_bookmark_rounded, color: AppColors.textTertiary, size: 40),
                        ),
                ),

                // 2. Fading gradient mask
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.shadow.withValues(alpha: AppOpacity.subtle),
                          AppColors.shadow.withValues(alpha: AppOpacity.overlay),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Info text & Neon Progress bar
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        list.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (list.description != null && list.description!.trim().isNotEmpty)
                        Text(
                          list.description!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),

                      // Metrics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$totalCount Film',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            AppLocalizations.of(context).collectionProgressPercent((progress * 100).toInt()),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: progress == 1.0 ? AppColors.success : AppColors.accent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Neon Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0 ? AppColors.success : AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Create List Modal Dialog
  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateCollectionDialog(),
    );
  }

  // Empty state placeholder
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppEmptyState(
      icon: Icons.collections_bookmark_rounded,
      title: l10n.collectionsEmptyTitle,
      subtitle: l10n.collectionsEmptyHint,
      ctaLabel: l10n.collectionsCreate,
      onCta: () => _showCreateListDialog(context, ref),
    );
  }
}
