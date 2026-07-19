import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: Colors.transparent,
      body: customListsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
        error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.white))),
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
                      'Koleksiyonlarım',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box_rounded, color: AppTheme.accentColor, size: 28),
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
      loading: () => const Card(color: Colors.black26),
      error: (error, stackTrace) => const Card(color: Colors.black26),
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
                                Colors.blueGrey.shade900,
                                Colors.grey.shade900,
                              ],
                            ),
                          ),
                          child: const Icon(Icons.collections_bookmark_rounded, color: Colors.white24, size: 40),
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
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.85),
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
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (list.description != null && list.description!.trim().isNotEmpty)
                        Text(
                          list.description!,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white60,
                          ),
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
                            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '%${(progress * 100).toInt()} İzlendi',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: progress == 1.0 ? Colors.greenAccent : AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Hiç Koleksiyonunuz Yok',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kendinize özel film listeleri oluşturarak (Örn: En İyi Nolan Filmleri, İzlenecek Animeler) sinema keyfinizi kişiselleştirebilirsiniz.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.black),
              label: Text(
                'Koleksiyon Oluştur',
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showCreateListDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
