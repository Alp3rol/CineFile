part of 'tmdb_service.dart';

mixin _TmdbPeopleResource on _TmdbCore {
  Future<int?> searchPersonId(String name) async {
    if (!ApiConstants.hasTmdbAccess) {
      return null;
    }
    try {
      final response = await _dio.get(
        '/search/person',
        queryParameters: {'api_key': _apiKey, 'query': name, 'page': 1},
      );
      final results = response.data['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        return results.first['id'] as int?;
      }
      return null;
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'person search');
    }
  }

  /// Search people by name, returning the full result list (id, name,
  /// profile_path, known_for_department) — used by the İlişki Ağı "add person"
  /// picker, where [searchPersonId]'s first-result-only shape isn't enough.
  Future<List<Map<String, dynamic>>> searchPeople(
    String query, {
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess || query.trim().isEmpty) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/search/person',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'language': language ?? this.language,
          'page': 1,
        },
      );
      final results = (response.data['results'] as List<dynamic>? ?? const []);
      return results
          .whereType<Map<String, dynamic>>()
          .map(
            (r) => {
              'id': r['id'],
              'name': r['name'],
              'profile_path': r['profile_path'],
              'known_for_department': r['known_for_department'],
            },
          )
          .toList();
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'person search');
    }
  }

  /// Discover movies by genres, crew, or cast
  Future<Map<String, dynamic>?> getPersonDetails(
    int personId, {
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return null;
    }
    try {
      final response = await _dio.get(
        '/person/$personId',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
        },
      );
      final data = response.data as Map<String, dynamic>;

      // TMDb has a biography for most people in English and far fewer in other
      // languages, so an empty one falls back to English rather than leaving
      // the actor page blank. Previously this only triggered for Turkish.
      final requested = language ?? this.language;
      final biography = data['biography'] as String?;
      if (requested != _englishLanguageTag &&
          (biography == null || biography.trim().isEmpty)) {
        try {
          final enResponse = await _dio.get(
            '/person/$personId',
            queryParameters: {
              'api_key': _apiKey,
              'language': _englishLanguageTag,
            },
          );
          final enData = enResponse.data as Map<String, dynamic>;
          final enBio = enData['biography'] as String?;
          if (enBio != null && enBio.trim().isNotEmpty) {
            data['biography'] = enBio;
          }
        } catch (e) {
          debugPrint('English biography fallback error: $e');
        }
      }
      return data;
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'person details');
    }
  }

  /// Get person combined credits (TMDb /person/$personId/combined_credits)
  Future<List<Map<String, dynamic>>> getPersonCombinedCredits(
    int personId, {
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/person/$personId/combined_credits',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
        },
      );
      final cast = response.data['cast'] as List<dynamic>? ?? [];
      return cast.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw TmdbException.from(e, operation: 'combined credits');
    }
  }

  /// Where [tmdbId] can be watched, for **every** country at once
  /// (TMDb `/movie|tv/{id}/watch/providers`).
  ///
  /// Returns the raw `results` map, keyed by ISO-3166-1 country code; slicing
  /// it to one region is [parseWatchProviders]' job. Returning the whole thing
  /// is what makes changing the region in Settings free: the response is
  /// identical whatever region the user picks, so the refetch is served from
  /// Dio's cache rather than the network.
  ///
  /// Unlike every other method here this sends **no `language`** — the payload
  /// holds no translatable text (provider names are brands, `link` is keyed by
  /// region), and omitting it keeps one cache entry per title instead of one
  /// per UI language.
  ///
  /// `isTv` is required rather than nullable on purpose: [getMovieDetails]
  /// probes both endpoints when it doesn't know, and doing that here would
  /// double the cost of a request that exists to be cheap. Every caller has
  /// the answer already.
}
