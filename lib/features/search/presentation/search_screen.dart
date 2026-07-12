import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dynamic_background_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import 'search_provider.dart';
import '../../movie_detail/presentation/movie_detail_screen.dart';
import '../../auth/presentation/widgets/user_profile_avatar_button.dart';
import '../../../../core/widgets/scroll_to_top_button.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  // TMDb Genre IDs
  final Map<String, int> _genres = {
    'Aksiyon': 28,
    'Komedi': 35,
    'Dram': 18,
    'Bilim Kurgu': 878,
    'Gerilim': 53,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 200;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Only update the background when the API results list itself changes —
    // NOT on every keystroke. ref.listen fires only when the value differs,
    // so typing that changes query but hasn't gotten new results yet won't
    // trigger a background update at all.
    ref.listen<SearchState>(searchProvider, (prev, next) {
      // Skip if results haven't changed (e.g. only query text changed mid-typing)
      if (prev?.results == next.results && prev?.selectedGenreId == next.selectedGenreId) return;

      final query = next.query.trim();
      var filtered = next.results;
      if (next.selectedGenreId != null) {
        filtered = filtered.where((m) {
          final g = m['genre_ids'] as List<dynamic>?;
          return g != null && g.contains(next.selectedGenreId);
        }).toList();
      }

      if (query.isNotEmpty && filtered.isNotEmpty) {
        ref.read(dynamicBackgroundProvider.notifier).updateMoviesFromMapList([filtered.first]);
      } else if (query.isEmpty) {
        ref.read(dynamicBackgroundProvider.notifier).clearColors();
      }
      // If query is non-empty but results are empty (still loading / no match),
      // leave the background as-is rather than flickering to dark.
    });

    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);
    final isApiKeyEmpty = ApiConstants.tmdbApiKey.isEmpty;

    // Filter results locally
    var displayResults = searchState.results;
    if (searchState.selectedGenreId != null) {
      displayResults = displayResults.where((movie) {
        final genreIds = movie['genre_ids'] as List<dynamic>?;
        return genreIds != null && genreIds.contains(searchState.selectedGenreId);
      }).toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Keşfet',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const UserProfileAvatarButton(),
                ],
              ),
            ),

            // Demo Mode Warning Banner
            if (isApiKeyEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: 12,
                  opacity: 0.8,
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'TMDb API anahtarı girilmedi. Şu an deneme modundasınız ("dune", "interstellar", "inception" veya "dark" aramalarını test edebilirsiniz).',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.amber.shade200,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Film veya dizi ara...',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            searchNotifier.reset();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  // SetState to update clear button visibility
                  setState(() {});
                  // Fast query search
                  searchNotifier.search(value);
                },
                onSubmitted: (value) {
                  searchNotifier.search(value);
                },
              ),
            ),

            // Filter Chips Row
            const SizedBox(height: 4),
            _buildGenreChips(searchState, searchNotifier),
            const SizedBox(height: 12),

            // Search Results Grid
            Expanded(
              child: _buildResultsSection(searchState, displayResults, isApiKeyEmpty),
            ),
          ],
        ),
      ),
      floatingActionButton: ScrollToTopButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        show: _showScrollToTop,
      ),
    );
  }

  // Genre Filters Horizontal List
  Widget _buildGenreChips(SearchState state, SearchNotifier notifier) {
    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          // "Tümü" (All) Chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildGenreChip(
              label: 'Tümü',
              isSelected: state.selectedGenreId == null,
              onSelected: (selected) {
                if (selected) notifier.setGenre(null);
              },
            ),
          ),

          // Genre Chips mapping
          ..._genres.entries.map((entry) {
            final isSelected = state.selectedGenreId == entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildGenreChip(
                label: entry.key,
                isSelected: isSelected,
                onSelected: (selected) {
                  notifier.setGenre(selected ? entry.value : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGenreChip({
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

  // Results Screen Logic
  Widget _buildResultsSection(SearchState state, List<Map<String, dynamic>> results, bool isApiKeyEmpty) {
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

    // Default view: If search is empty
    if (state.query.trim().isEmpty) {
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
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // Ratio for standard movie posters
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
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
                      imageUrl: posterPath != null
                          ? '${ApiConstants.imagePathW500}$posterPath'
                          : '',
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
