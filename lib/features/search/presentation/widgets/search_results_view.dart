import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../movie_detail/presentation/movie_detail_screen.dart';
import '../search_provider.dart';
import '../trending_provider.dart';

// Loading/error/empty-query/no-results/results-grid states for
// SearchScreen's main body, driven by SearchState plus the already
// genre-filtered results list (filtering itself stays in SearchScreen,
// which also owns the currentUser-independent dynamic-background sync).
class SearchResultsView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Default view: If search is empty, show a discoverable trend/popular/top-rated grid
    if (state.query.trim().isEmpty) {
      final trendingAsync = ref.watch(trendingProvider);
      final category = ref.watch(discoverCategoryProvider);
      final timeWindow = ref.watch(discoverTimeWindowProvider);
      return trendingAsync.when(
        data: (items) {
          if (items.isEmpty) return _buildStaticEmptyState();

          final mediaFilter = ref.watch(discoverMediaFilterProvider);
          final filtered = switch (mediaFilter) {
            DiscoverMediaFilter.all => items,
            DiscoverMediaFilter.movie => items.where((m) => m['media_type'] != 'tv').toList(),
            DiscoverMediaFilter.tv => items.where((m) => m['media_type'] == 'tv').toList(),
          };

          return Column(
            children: [
              _buildCategoryTimeRow(ref, category, timeWindow),
              const SizedBox(height: 8),
              _buildMediaFilterRow(ref, mediaFilter),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _headingFor(category, timeWindow),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _buildFilteredEmptyState(mediaFilter)
                    : _buildGrid(context, filtered, scrollController),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
        error: (e, st) => _buildStaticEmptyState(),
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
    return _buildGrid(context, results, scrollController);
  }

  String _headingFor(DiscoverCategory category, DiscoverTimeWindow timeWindow) {
    switch (category) {
      case DiscoverCategory.trend:
        return timeWindow == DiscoverTimeWindow.today ? 'Bugün Trend Film/Dizileri' : 'Bu Hafta Trend Film/Dizileri';
      case DiscoverCategory.popular:
        return 'Popüler Film/Dizileri';
      case DiscoverCategory.topRated:
        return 'En Çok Oy Alan Film/Dizileri';
    }
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.accentColor,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: isSelected ? Colors.transparent : AppTheme.borderColor),
      ),
    );
  }

  Widget _chipPadded(Widget chip) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: chip);
  }

  Widget _buildCategoryTimeRow(WidgetRef ref, DiscoverCategory category, DiscoverTimeWindow timeWindow) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chipPadded(_chip(
            label: 'Trend',
            isSelected: category == DiscoverCategory.trend,
            onSelected: (selected) {
              if (selected) ref.read(discoverCategoryProvider.notifier).state = DiscoverCategory.trend;
            },
          )),
          if (category == DiscoverCategory.trend) ...[
            _chipPadded(_chip(
              label: 'Bu Hafta',
              isSelected: timeWindow == DiscoverTimeWindow.week,
              onSelected: (selected) {
                if (selected) ref.read(discoverTimeWindowProvider.notifier).state = DiscoverTimeWindow.week;
              },
            )),
            _chipPadded(_chip(
              label: 'Bugün',
              isSelected: timeWindow == DiscoverTimeWindow.today,
              onSelected: (selected) {
                if (selected) ref.read(discoverTimeWindowProvider.notifier).state = DiscoverTimeWindow.today;
              },
            )),
          ],
          _chipPadded(_chip(
            label: 'Popüler',
            isSelected: category == DiscoverCategory.popular,
            onSelected: (selected) {
              if (selected) ref.read(discoverCategoryProvider.notifier).state = DiscoverCategory.popular;
            },
          )),
          _chipPadded(_chip(
            label: 'En Çok Oy Alan',
            isSelected: category == DiscoverCategory.topRated,
            onSelected: (selected) {
              if (selected) ref.read(discoverCategoryProvider.notifier).state = DiscoverCategory.topRated;
            },
          )),
        ],
      ),
    );
  }

  Widget _buildMediaFilterRow(WidgetRef ref, DiscoverMediaFilter mediaFilter) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chipPadded(_chip(
            label: 'Hepsi',
            isSelected: mediaFilter == DiscoverMediaFilter.all,
            onSelected: (selected) {
              if (selected) ref.read(discoverMediaFilterProvider.notifier).state = DiscoverMediaFilter.all;
            },
          )),
          _chipPadded(_chip(
            label: 'Film',
            isSelected: mediaFilter == DiscoverMediaFilter.movie,
            onSelected: (selected) {
              if (selected) ref.read(discoverMediaFilterProvider.notifier).state = DiscoverMediaFilter.movie;
            },
          )),
          _chipPadded(_chip(
            label: 'Dizi',
            isSelected: mediaFilter == DiscoverMediaFilter.tv,
            onSelected: (selected) {
              if (selected) ref.read(discoverMediaFilterProvider.notifier).state = DiscoverMediaFilter.tv;
            },
          )),
        ],
      ),
    );
  }

  Widget _buildFilteredEmptyState(DiscoverMediaFilter filter) {
    final label = filter == DiscoverMediaFilter.movie ? 'film' : 'dizi';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu kategoride $label bulunamadı',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticEmptyState() {
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

  Widget _buildGrid(
    BuildContext context,
    List<Map<String, dynamic>> items,
    ScrollController? controller,
  ) {
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // Ratio for standard movie posters
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final movie = items[index];
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
