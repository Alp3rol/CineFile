part of 'tmdb_service.dart';

mixin _TmdbSearchResource on _TmdbCore {
  Future<List<Map<String, dynamic>>> searchMovies(
    String query, {
    int page = 1,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      // Return filtered mock results when API key is empty (offline demo mode)
      final lowerQuery = query.toLowerCase();
      return _TmdbCore._mockMovies
          .where(
            (m) =>
                (m['title'] as String).toLowerCase().contains(lowerQuery) ||
                (m['original_title'] as String).toLowerCase().contains(
                  lowerQuery,
                ),
          )
          .toList();
    }

    try {
      final response = await _dio.get(
        '/search/multi',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'page': page,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;

      // Filter out people (only keep movie and tv)
      final filtered = results
          .where((e) => e['media_type'] == 'movie' || e['media_type'] == 'tv')
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // Normalize TV shows to fit Movie format in UI
      final normalized = filtered.map((item) {
        final mediaType = item['media_type'] as String?;
        if (mediaType == 'tv') {
          return {
            ...item,
            'title': item['name'] ?? item['original_name'] ?? 'Bilinmeyen Dizi',
            'release_date': item['first_air_date'] ?? '',
          };
        }
        return item;
      }).toList();

      return normalized;
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'search');
    }
  }

  Future<List<Map<String, dynamic>>> getPopularMovies({
    int page = 1,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'popular movies');
    }
  }

  /// Get popular TV shows
  Future<List<Map<String, dynamic>>> getPopularTvShows({
    int page = 1,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/tv/popular',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {
          ...data,
          'title': data['name'] ?? data['original_name'] ?? 'Bilinmeyen Dizi',
          'release_date': data['first_air_date'] ?? '',
          'media_type': 'tv',
        };
      }).toList();
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'popular tv');
    }
  }

  /// Get this week's trending movies (TMDb /trending/movie/week)
  Future<List<Map<String, dynamic>>> getTrendingMoviesThisWeek({
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/movie/week',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {...data, 'media_type': 'movie'};
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb Haftalık Trend Film Hatası: ${e.message}');
      throw TmdbException.from(e, operation: 'trending movies this week');
    }
  }

  /// Get this week's trending TV shows (TMDb /trending/tv/week)
  Future<List<Map<String, dynamic>>> getTrendingTvShowsThisWeek({
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/tv/week',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {
          ...data,
          'title': data['name'] ?? data['original_name'] ?? 'Bilinmeyen Dizi',
          'release_date': data['first_air_date'] ?? '',
          'media_type': 'tv',
        };
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb Haftalık Trend Dizi Hatası: ${e.message}');
      throw TmdbException.from(e, operation: 'trending tv this week');
    }
  }

  /// Get today's trending movies (TMDb /trending/movie/day)
  Future<List<Map<String, dynamic>>> getTrendingMoviesToday({
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/movie/day',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {...data, 'media_type': 'movie'};
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb Günlük Trend Film Hatası: ${e.message}');
      throw TmdbException.from(e, operation: 'trending movies today');
    }
  }

  /// Get today's trending TV shows (TMDb /trending/tv/day)
  Future<List<Map<String, dynamic>>> getTrendingTvShowsToday({
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/tv/day',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {
          ...data,
          'title': data['name'] ?? data['original_name'] ?? 'Bilinmeyen Dizi',
          'release_date': data['first_air_date'] ?? '',
          'media_type': 'tv',
        };
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb Günlük Trend Dizi Hatası: ${e.message}');
      throw TmdbException.from(e, operation: 'trending tv today');
    }
  }

  /// Get top rated movies (TMDb /movie/top_rated)
  Future<List<Map<String, dynamic>>> getTopRatedMovies({
    int page = 1,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {...data, 'media_type': 'movie'};
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb En Çok Oy Alan Film Hatası: ${e.message}');
      throw TmdbException.from(e, operation: 'top rated movies');
    }
  }

  /// Get top rated TV shows (TMDb /tv/top_rated)
  Future<List<Map<String, dynamic>>> getTopRatedTvShows({
    int page = 1,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/tv/top_rated',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language ?? this.language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {
          ...data,
          'title': data['name'] ?? data['original_name'] ?? 'Bilinmeyen Dizi',
          'release_date': data['first_air_date'] ?? '',
          'media_type': 'tv',
        };
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb En Çok Oy Alan Dizi Hatası: ${e.message}');
      throw TmdbException.from(e, operation: 'top rated tv');
    }
  }

  /// Search for a person to get their TMDb ID
  Future<List<Map<String, dynamic>>> discoverMovies({
    String? withGenres,
    String? withCrew,
    String? withCast,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
          'sort_by': 'popularity.desc',
          'with_genres': ?withGenres,
          'with_crew': ?withCrew,
          'with_cast': ?withCast,
        },
      );
      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {...data, 'media_type': 'movie'};
      }).toList();
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'discover movies');
    }
  }

  /// Discover TV shows by genres or people
  Future<List<Map<String, dynamic>>> discoverTvShows({
    String? withGenres,
    String? withPeople,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/discover/tv',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
          'sort_by': 'popularity.desc',
          'with_genres': ?withGenres,
          'with_people': ?withPeople,
        },
      );
      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {
          ...data,
          'title': data['name'] ?? data['original_name'] ?? 'Bilinmeyen Dizi',
          'release_date': data['first_air_date'] ?? '',
          'media_type': 'tv',
        };
      }).toList();
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'discover tv');
    }
  }

  /// Get person details (TMDb /person/{id})
}
