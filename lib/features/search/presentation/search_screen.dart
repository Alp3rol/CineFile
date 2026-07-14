import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dynamic_background_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import 'search_provider.dart';
import 'widgets/search_api_key_warning_banner.dart';
import 'widgets/search_genre_chips.dart';
import 'widgets/search_results_view.dart';
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
            if (isApiKeyEmpty) const SearchApiKeyWarningBanner(),

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
            SearchGenreChips(
              genres: _genres,
              selectedGenreId: searchState.selectedGenreId,
              onGenreSelected: searchNotifier.setGenre,
            ),
            const SizedBox(height: 12),

            // Search Results Grid
            Expanded(
              child: SearchResultsView(
                state: searchState,
                results: displayResults,
                scrollController: _scrollController,
              ),
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
}
