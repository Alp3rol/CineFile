import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/tmdb_exception.dart';
import '../../../core/network/tmdb_service.dart';

const Object _sentinel = Object();

class SearchState {
  final String query;
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  /// Why the last search failed, or null if it didn't. A reason rather than
  /// a message so the UI can render it in the user's language.
  final TmdbFailure? failure;
  final int? selectedGenreId;
  final int? selectedYear;
  final double? minRating;
  final String mediaTypeFilter; // 'all', 'movie', 'tv'
  final String? decadeFilter; // '2020s', '2010s', '2000s', 'classics'

  SearchState({
    required this.query,
    required this.results,
    required this.isLoading,
    this.failure,
    this.selectedGenreId,
    this.selectedYear,
    this.minRating,
    this.mediaTypeFilter = 'all',
    this.decadeFilter,
  });

  SearchState.initial()
      : query = '',
        results = const [],
        isLoading = false,
        failure = null,
        selectedGenreId = null,
        selectedYear = null,
        minRating = null,
        mediaTypeFilter = 'all',
        decadeFilter = null;

  SearchState copyWith({
    String? query,
    List<Map<String, dynamic>>? results,
    bool? isLoading,
    Object? failure = _sentinel,
    Object? selectedGenreId = _sentinel,
    Object? selectedYear = _sentinel,
    Object? minRating = _sentinel,
    String? mediaTypeFilter,
    Object? decadeFilter = _sentinel,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      failure: failure == _sentinel ? this.failure : (failure as TmdbFailure?),
      selectedGenreId: selectedGenreId == _sentinel ? this.selectedGenreId : (selectedGenreId as int?),
      selectedYear: selectedYear == _sentinel ? this.selectedYear : (selectedYear as int?),
      minRating: minRating == _sentinel ? this.minRating : (minRating as double?),
      mediaTypeFilter: mediaTypeFilter ?? this.mediaTypeFilter,
      decadeFilter: decadeFilter == _sentinel ? this.decadeFilter : (decadeFilter as String?),
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final TmdbService _tmdbService;
  Timer? _debounceTimer;

  SearchNotifier(Ref ref, this._tmdbService) : super(SearchState.initial());

  Future<void> search(String query) async {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(query: query, results: const [], isLoading: false, failure: null);
      return;
    }

    // Update query instantly, but don't show loading spinner yet to prevent flashing
    state = state.copyWith(query: query, failure: null);

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final searchTargetQuery = query;
      state = state.copyWith(isLoading: true);

      try {
        final results = await _tmdbService.searchMovies(searchTargetQuery);
        
        // Race condition guard: ignore if user has changed the query since request started
        if (state.query != searchTargetQuery) return;
        
        state = state.copyWith(results: results, isLoading: false, failure: null);
      } catch (e) {
        // Race condition guard: ignore if user has changed the query since request started
        if (state.query != searchTargetQuery) return;

        // The failure used to be discarded here — results were cleared and the
        // error left null, so a DNS block, a timeout or a bad API key rendered
        // identically to "your search matched nothing". That is the failure
        // this app is most likely to hit, given the DoH workaround it ships to
        // get around TMDb being intercepted.
        final failure = e is TmdbException ? e.failure : TmdbFailure.unknown;
        debugPrint('Search failed: $e');
        state = state.copyWith(
          isLoading: false,
          results: const [],
          failure: failure,
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

  void setMinRating(double? minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void setMediaTypeFilter(String filter) {
    state = state.copyWith(mediaTypeFilter: filter);
  }

  void setDecadeFilter(String? decade) {
    state = state.copyWith(decadeFilter: decade);
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
