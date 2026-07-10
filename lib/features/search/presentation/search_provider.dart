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
