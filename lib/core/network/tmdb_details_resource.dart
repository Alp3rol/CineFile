part of 'tmdb_service.dart';

mixin _TmdbDetailsResource on _TmdbCore {
  Future<Map<String, dynamic>?> getMovieDetails(
    int tmdbId, {
    bool? isTv,
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      try {
        final basicMovie = _TmdbCore._mockMovies.firstWhere(
          (m) => m['id'] == tmdbId,
        );
        final genreIds = basicMovie['genre_ids'] as List<int>;

        final genreMap = {
          878: 'Bilim Kurgu',
          18: 'Dram',
          12: 'Macera',
          28: 'Aksiyon',
          53: 'Gerilim',
          80: 'Suç',
          36: 'Tarih',
          16: 'Animasyon',
        };

        final genresList = genreIds
            .map((id) => {'id': id, 'name': genreMap[id] ?? 'Genel'})
            .toList();

        return {
          ...basicMovie,
          'runtime': 148,
          'genres': genresList,
          'tagline': 'Gerçeküstü bir yolculuk.',
          'credits': {
            'cast': [
              {
                'name': 'Leonardo DiCaprio',
                'character': 'Cobb',
                'profile_path': null,
              },
              {
                'name': 'Matthew McConaughey',
                'character': 'Cooper',
                'profile_path': null,
              },
              {
                'name': 'Timothée Chalamet',
                'character': 'Paul Atreides',
                'profile_path': null,
              },
              {
                'name': 'Christian Bale',
                'character': 'Bruce Wayne / Batman',
                'profile_path': null,
              },
              {
                'name': 'Cillian Murphy',
                'character': 'J. Robert Oppenheimer',
                'profile_path': null,
              },
            ],
            'crew': [
              {'name': 'Christopher Nolan', 'job': 'Director'},
              {'name': 'Denis Villeneuve', 'job': 'Director'},
            ],
          },
        };
      } catch (_) {
        return null;
      }
    }

    if (isTv == true) {
      try {
        return await _getTvDetails(tmdbId, language: language);
      } catch (e) {
        throw TmdbException.from(e, operation: 'tv details');
      }
    } else if (isTv == false) {
      try {
        return await _getMovieDetailsOnly(tmdbId, language: language);
      } catch (e) {
        throw TmdbException.from(e, operation: 'movie details');
      }
    } else {
      // Fallback if isTv is not provided
      try {
        return await _getMovieDetailsOnly(tmdbId, language: language);
      } catch (_) {
        try {
          return await _getTvDetails(tmdbId, language: language);
        } catch (e) {
          throw TmdbException.from(e, operation: 'details');
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _getMovieDetailsOnly(
    int tmdbId, {
    String? language,
  }) async {
    final response = await _dio.get(
      '/movie/$tmdbId',
      queryParameters: {
        'api_key': _apiKey,
        'language': language ?? this.language,
        'append_to_response': 'credits,release_dates',
      },
    );
    final data = response.data as Map<String, dynamic>;
    data['media_type'] = 'movie';
    return data;
  }

  Future<Map<String, dynamic>?> _getTvDetails(
    int tmdbId, {
    String? language,
  }) async {
    final response = await _dio.get(
      '/tv/$tmdbId',
      queryParameters: {
        'api_key': _apiKey,
        'language': language ?? this.language,
        'append_to_response': 'credits,aggregate_credits,content_ratings',
      },
    );
    final data = response.data as Map<String, dynamic>;
    data['media_type'] = 'tv';

    // Normalize TV data to match Movie schema for movie detail screen
    data['title'] = data['name'] ?? data['original_name'] ?? 'Bilinmeyen Dizi';
    data['original_title'] = data['original_name'];
    data['release_date'] = data['first_air_date'] ?? '';

    // Normalize crew/directors: TV uses 'created_by' list for creators, or crew in credits
    final createdBy = data['created_by'] as List<dynamic>?;
    final creatorName = createdBy != null && createdBy.isNotEmpty
        ? createdBy.map((c) => c['name']).join(', ')
        : null;

    if (data['credits'] == null) {
      data['credits'] = {
        'cast': [],
        'crew': creatorName != null
            ? [
                {'name': creatorName, 'job': 'Director'},
              ]
            : [],
      };
    } else {
      final crewList = (data['credits']['crew'] as List<dynamic>?) ?? [];
      final hasDirector = crewList.any((e) => e['job'] == 'Director');
      if (creatorName != null && !hasDirector) {
        data['credits']['crew'] = [
          ...crewList,
          {'name': creatorName, 'job': 'Director'},
        ];
      }
    }

    // Runtime for TV shows
    final episodeRunTime = data['episode_run_time'] as List<dynamic>?;
    if (episodeRunTime != null && episodeRunTime.isNotEmpty) {
      data['runtime'] = episodeRunTime.first as int;
    } else {
      data['runtime'] = 45; // default tv episode duration fallback
    }

    return data;
  }

  /// Get popular movies (useful for search home or suggestions)
  Future<Map<String, dynamic>> getWatchProviders(
    int tmdbId, {
    required bool isTv,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return const {};
    }
    try {
      final response = await _dio.get(
        isTv ? '/tv/$tmdbId/watch/providers' : '/movie/$tmdbId/watch/providers',
        queryParameters: {'api_key': _apiKey},
      );
      return (response.data['results'] as Map<String, dynamic>?) ?? const {};
    } on DioException catch (e) {
      // Thrown, not swallowed into an empty result the way getTvSeasonDetails
      // does: the section widget renders nothing either way, but a test — and
      // a future caller that wants to show a retry — must be able to tell
      // "request failed" from "not available here".
      throw TmdbException.from(e, operation: 'watch providers');
    }
  }

  /// Get detailed episodes for a specific season of a TV show
}
