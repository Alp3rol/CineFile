import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/tmdb_service.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';

class SearchState {
  final String query;
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String? errorMessage;
  final int? selectedGenreId;
  final int? selectedYear;

  SearchState({
    required this.query,
    required this.results,
    required this.isLoading,
    this.errorMessage,
    this.selectedGenreId,
    this.selectedYear,
  });

  SearchState.initial()
      : query = '',
        results = const [],
        isLoading = false,
        errorMessage = null,
        selectedGenreId = null,
        selectedYear = null;

  SearchState copyWith({
    String? query,
    List<Map<String, dynamic>>? results,
    bool? isLoading,
    String? errorMessage,
    int? selectedGenreId,
    int? selectedYear,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedGenreId: selectedGenreId ?? this.selectedGenreId,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  final TmdbService _tmdbService;
  Timer? _debounceTimer;

  SearchNotifier(this._ref, this._tmdbService) : super(SearchState.initial());

  Future<void> search(String query) async {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(query: query, results: const [], isLoading: false, errorMessage: null);
      return;
    }

    // Update query instantly, but don't show loading spinner yet to prevent flashing
    state = state.copyWith(query: query, errorMessage: null);

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final searchTargetQuery = query;
      state = state.copyWith(isLoading: true);

      try {
        final results = await _tmdbService.searchMovies(searchTargetQuery);
        
        // Race condition guard: ignore if user has changed the query since request started
        if (state.query != searchTargetQuery) return;
        
        state = state.copyWith(results: results, isLoading: false);
      } catch (e) {
        // Race condition guard: ignore if user has changed the query since request started
        if (state.query != searchTargetQuery) return;
        
        // Offline fallback: Search local DB and mock movies list
        try {
          final lowerQuery = searchTargetQuery.toLowerCase();
          
          final List<Map<String, dynamic>> mockList = [
            {'id': 157336, 'title': 'Interstellar', 'original_title': 'Interstellar', 'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg', 'release_date': '2014-11-05', 'media_type': 'movie'},
            {'id': 27205, 'title': 'Inception', 'original_title': 'Inception', 'poster_path': '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg', 'release_date': '2010-07-15', 'media_type': 'movie'},
            {'id': 693134, 'title': 'Dune: Part Two', 'original_title': 'Dune: Part Two', 'poster_path': '/tihf8Trht9zP3scmUQfvGlAY9FU.jpg', 'release_date': '2024-02-27', 'media_type': 'movie'},
            {'id': 155, 'title': 'The Dark Knight', 'original_title': 'The Dark Knight', 'poster_path': '/7IPCEr7ifdH5CtU97QG7XgAAtOp.jpg', 'release_date': '2008-07-16', 'media_type': 'movie'},
            {'id': 872585, 'title': 'Oppenheimer', 'original_title': 'Oppenheimer', 'poster_path': '/ptpr0kGAckfQkJeJIt8st5dglvd.jpg', 'release_date': '2023-07-19', 'media_type': 'movie'},
            {'id': 569094, 'title': 'Spider-Man: Across the Spider-Verse', 'original_title': 'Spider-Man: Across the Spider-Verse', 'poster_path': '/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg', 'release_date': '2023-05-31', 'media_type': 'movie'},
          ];
          
          final filteredMock = mockList.where((m) =>
              (m['title'] as String).toLowerCase().contains(lowerQuery) ||
              (m['original_title'] as String).toLowerCase().contains(lowerQuery)).toList();
              
          final List<Map<String, dynamic>> dbResults = [];
          if (kIsWeb) {
            final webMovies = _ref.read(webMoviesProvider);
            final matched = webMovies.values.where((m) =>
                m.title.toLowerCase().contains(lowerQuery) ||
                (m.originalTitle ?? '').toLowerCase().contains(lowerQuery));
            for (final m in matched) {
              dbResults.add({
                'id': m.tmdbId,
                'title': m.title,
                'original_title': m.originalTitle,
                'poster_path': m.posterPath,
                'release_date': m.releaseYear != null ? '${m.releaseYear}-01-01' : '',
                'media_type': m.isTv ? 'tv' : 'movie',
              });
            }
          } else {
            final db = _ref.read(databaseProvider);
            final allMovies = await db.select(db.movies).get();
            final matched = allMovies.where((m) =>
                m.title.toLowerCase().contains(lowerQuery) ||
                (m.originalTitle ?? '').toLowerCase().contains(lowerQuery));
            for (final m in matched) {
              dbResults.add({
                'id': m.tmdbId,
                'title': m.title,
                'original_title': m.originalTitle,
                'poster_path': m.posterPath,
                'release_date': m.releaseYear != null ? '${m.releaseYear}-01-01' : '',
                'media_type': m.isTv ? 'tv' : 'movie',
              });
            }
          }

          final Map<(int, bool), Map<String, dynamic>> mergedMap = {};
          for (final m in filteredMock) {
            mergedMap[(m['id'] as int, m['media_type'] == 'tv')] = m;
          }
          for (final m in dbResults) {
            mergedMap[(m['id'] as int, m['media_type'] == 'tv')] = m;
          }

          if (mergedMap.isNotEmpty) {
            state = state.copyWith(results: mergedMap.values.toList(), isLoading: false, errorMessage: null);
            return;
          }
        } catch (_) {}

        state = state.copyWith(
          isLoading: false, 
          results: const [],
          errorMessage: null,
        );
      }
    });
  }

  void setGenre(int? genreId) {
    state = state.copyWith(selectedGenreId: genreId);
  }

  void setYear(int? year) {
    state = state.copyWith(selectedYear: year);
  }

  void reset() {
    _debounceTimer?.cancel();
    state = SearchState.initial();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return SearchNotifier(ref, tmdbService);
});
