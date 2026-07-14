import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';
import '../../features/settings/presentation/settings_provider.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final baseUrl = ref.watch(settingsBaseUrlProvider);
  return DioClient(baseUrl: baseUrl);
});

final tmdbServiceProvider = Provider<TmdbService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return TmdbService(dio);
});

class TmdbService {
  final Dio _dio;

  TmdbService(this._dio);

  // In the future, we can load this from SharedPreferences or Secure Storage.
  // For now, it uses the constant or a fallback.
  String get _apiKey => ApiConstants.tmdbApiKey;

  static final List<Map<String, dynamic>> _mockMovies = [
    {
      'id': 157336,
      'title': 'Interstellar',
      'original_title': 'Interstellar',
      'poster_path': '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      'release_date': '2014-11-05',
      'vote_average': 8.4,
      'genre_ids': [878, 18, 12],
      'overview': 'Mankind was born on Earth. It was never meant to die here.',
    },
    {
      'id': 27205,
      'title': 'Inception',
      'original_title': 'Inception',
      'poster_path': '/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
      'release_date': '2010-07-15',
      'vote_average': 8.3,
      'genre_ids': [878, 18, 28, 12, 53],
      'overview': 'Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets.',
    },
    {
      'id': 693134,
      'title': 'Dune: Part Two',
      'original_title': 'Dune: Part Two',
      'poster_path': '/tihf8Trht9zP3scmUQfvGlAY9FU.jpg',
      'release_date': '2024-02-27',
      'vote_average': 8.3,
      'genre_ids': [878, 12, 28],
      'overview': 'Follow the mythic journey of Paul Atreides as he unites with Chani and the Fremen.',
    },
    {
      'id': 155,
      'title': 'The Dark Knight',
      'original_title': 'The Dark Knight',
      'poster_path': '/7IPCEr7ifdH5CtU97QG7XgAAtOp.jpg',
      'release_date': '2008-07-16',
      'vote_average': 8.5,
      'genre_ids': [28, 80, 18, 53],
      'overview': 'Batman raises the stakes in his war on crime.',
    },
    {
      'id': 872585,
      'title': 'Oppenheimer',
      'original_title': 'Oppenheimer',
      'poster_path': '/ptpr0kGAckfQkJeJIt8st5dglvd.jpg',
      'release_date': '2023-07-19',
      'vote_average': 8.1,
      'genre_ids': [18, 36],
      'overview': 'The story of J. Robert Oppenheimer and the atomic bomb project.',
    },
    {
      'id': 569094,
      'title': 'Spider-Man: Across the Spider-Verse',
      'original_title': 'Spider-Man: Across the Spider-Verse',
      'poster_path': '/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      'release_date': '2023-05-31',
      'vote_average': 8.4,
      'genre_ids': [16, 28, 12, 878],
      'overview': 'Miles Morales catapults across the Multiverse.',
    },
  ];

  /// Search for movies and series by title
  Future<List<Map<String, dynamic>>> searchMovies(String query, {int page = 1, String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      // Return filtered mock results when API key is empty (offline demo mode)
      final lowerQuery = query.toLowerCase();
      return _mockMovies
          .where((m) =>
              (m['title'] as String).toLowerCase().contains(lowerQuery) ||
              (m['original_title'] as String).toLowerCase().contains(lowerQuery))
          .toList();
    }

    try {
      final response = await _dio.get(
        '/search/multi',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'page': page,
          'language': language,
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
      throw Exception('TMDb Arama Hatası: ${e.message}');
    }
  }

  Future<Map<String, dynamic>?> getMovieDetails(int tmdbId, {bool? isTv, String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      try {
        final basicMovie = _mockMovies.firstWhere((m) => m['id'] == tmdbId);
        final genreIds = basicMovie['genre_ids'] as List<int>;
        
        final genreMap = {
          878: 'Bilim Kurgu',
          18: 'Dram',
          12: 'Macera',
          28: 'Aksiyon',
          53: 'Gerilim',
          80: 'Suç',
          36: 'Tarih',
          16: 'Animasyon'
        };
        
        final genresList = genreIds.map((id) => {
          'id': id,
          'name': genreMap[id] ?? 'Genel'
        }).toList();

        return {
          ...basicMovie,
          'runtime': 148,
          'genres': genresList,
          'tagline': 'Gerçeküstü bir yolculuk.',
          'credits': {
            'cast': [
              {'name': 'Leonardo DiCaprio', 'character': 'Cobb', 'profile_path': null},
              {'name': 'Matthew McConaughey', 'character': 'Cooper', 'profile_path': null},
              {'name': 'Timothée Chalamet', 'character': 'Paul Atreides', 'profile_path': null},
              {'name': 'Christian Bale', 'character': 'Bruce Wayne / Batman', 'profile_path': null},
              {'name': 'Cillian Murphy', 'character': 'J. Robert Oppenheimer', 'profile_path': null},
            ],
            'crew': [
              {'name': 'Christopher Nolan', 'job': 'Director'},
              {'name': 'Denis Villeneuve', 'job': 'Director'},
            ]
          }
        };
      } catch (_) {
        return null;
      }
    }

    if (isTv == true) {
      try {
        return await _getTvDetails(tmdbId, language: language);
      } catch (e) {
        throw Exception('TMDb Dizi Detay Getirme Hatası: ${e.toString()}');
      }
    } else if (isTv == false) {
      try {
        return await _getMovieDetailsOnly(tmdbId, language: language);
      } catch (e) {
        throw Exception('TMDb Film Detay Getirme Hatası: ${e.toString()}');
      }
    } else {
      // Fallback if isTv is not provided
      try {
        return await _getMovieDetailsOnly(tmdbId, language: language);
      } catch (_) {
        try {
          return await _getTvDetails(tmdbId, language: language);
        } catch (e) {
          throw Exception('TMDb Detay Getirme Hatası: ${e.toString()}');
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _getMovieDetailsOnly(int tmdbId, {String language = 'tr-TR'}) async {
    final response = await _dio.get(
      '/movie/$tmdbId',
      queryParameters: {
        'api_key': _apiKey,
        'language': language,
        'append_to_response': 'credits,release_dates',
      },
    );
    final data = response.data as Map<String, dynamic>;
    data['media_type'] = 'movie';
    return data;
  }

  Future<Map<String, dynamic>?> _getTvDetails(int tmdbId, {String language = 'tr-TR'}) async {
    final response = await _dio.get(
      '/tv/$tmdbId',
      queryParameters: {
        'api_key': _apiKey,
        'language': language,
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
        'crew': creatorName != null ? [{'name': creatorName, 'job': 'Director'}] : []
      };
    } else {
      final crewList = (data['credits']['crew'] as List<dynamic>?) ?? [];
      final hasDirector = crewList.any((e) => e['job'] == 'Director');
      if (creatorName != null && !hasDirector) {
        data['credits']['crew'] = [
          ...crewList,
          {'name': creatorName, 'job': 'Director'}
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
  Future<List<Map<String, dynamic>>> getPopularMovies({int page = 1, String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw Exception('TMDb Popüler Filmler Hatası: ${e.message}');
    }
  }

  /// Get popular TV shows
  Future<List<Map<String, dynamic>>> getPopularTvShows({int page = 1, String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/tv/popular',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language,
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
      throw Exception('TMDb Popüler Dizi Hatası: ${e.message}');
    }
  }

  /// Get this week's trending movies (TMDb /trending/movie/week)
  Future<List<Map<String, dynamic>>> getTrendingMoviesThisWeek({String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/movie/week',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {...data, 'media_type': 'movie'};
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb Haftalık Trend Film Hatası: ${e.message}');
      throw Exception('TMDb Haftalık Trend Film Hatası: ${e.message}');
    }
  }

  /// Get this week's trending TV shows (TMDb /trending/tv/week)
  Future<List<Map<String, dynamic>>> getTrendingTvShowsThisWeek({String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/tv/week',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
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
      throw Exception('TMDb Haftalık Trend Dizi Hatası: ${e.message}');
    }
  }

  /// Get today's trending movies (TMDb /trending/movie/day)
  Future<List<Map<String, dynamic>>> getTrendingMoviesToday({String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/movie/day',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {...data, 'media_type': 'movie'};
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb Günlük Trend Film Hatası: ${e.message}');
      throw Exception('TMDb Günlük Trend Film Hatası: ${e.message}');
    }
  }

  /// Get today's trending TV shows (TMDb /trending/tv/day)
  Future<List<Map<String, dynamic>>> getTrendingTvShowsToday({String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/trending/tv/day',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
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
      throw Exception('TMDb Günlük Trend Dizi Hatası: ${e.message}');
    }
  }

  /// Get top rated movies (TMDb /movie/top_rated)
  Future<List<Map<String, dynamic>>> getTopRatedMovies({int page = 1, String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {...data, 'media_type': 'movie'};
      }).toList();
    } on DioException catch (e) {
      debugPrint('TMDb En Çok Oy Alan Film Hatası: ${e.message}');
      throw Exception('TMDb En Çok Oy Alan Film Hatası: ${e.message}');
    }
  }

  /// Get top rated TV shows (TMDb /tv/top_rated)
  Future<List<Map<String, dynamic>>> getTopRatedTvShows({int page = 1, String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/tv/top_rated',
        queryParameters: {
          'api_key': _apiKey,
          'page': page,
          'language': language,
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
      throw Exception('TMDb En Çok Oy Alan Dizi Hatası: ${e.message}');
    }
  }

  /// Search for a person to get their TMDb ID
  Future<int?> searchPersonId(String name) async {
    if (_apiKey.isEmpty) {
      return null;
    }
    try {
      final response = await _dio.get(
        '/search/person',
        queryParameters: {
          'api_key': _apiKey,
          'query': name,
          'page': 1,
        },
      );
      final results = response.data['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        return results.first['id'] as int?;
      }
      return null;
    } on DioException catch (e) {
      throw Exception('TMDb Person Search Hatası: ${e.message}');
    }
  }

  /// Discover movies by genres, crew, or cast
  Future<List<Map<String, dynamic>>> discoverMovies({
    String? withGenres,
    String? withCrew,
    String? withCast,
    String language = 'tr-TR',
  }) async {
    if (_apiKey.isEmpty) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
          'sort_by': 'popularity.desc',
          'with_genres': ?withGenres,
          'with_crew': ?withCrew,
          'with_cast': ?withCast,
        },
      );
      final results = response.data['results'] as List<dynamic>;
      return results.map((item) {
        final data = item as Map<String, dynamic>;
        return {
          ...data,
          'media_type': 'movie',
        };
      }).toList();
    } on DioException catch (e) {
      throw Exception('TMDb Discover Movie Hatası: ${e.message}');
    }
  }

  /// Discover TV shows by genres or people
  Future<List<Map<String, dynamic>>> discoverTvShows({
    String? withGenres,
    String? withPeople,
    String language = 'tr-TR',
  }) async {
    if (_apiKey.isEmpty) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/discover/tv',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
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
      throw Exception('TMDb Discover TV Hatası: ${e.message}');
    }
  }

  /// Get person details (TMDb /person/{id})
  Future<Map<String, dynamic>?> getPersonDetails(int personId, {String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return null;
    }
    try {
      final response = await _dio.get(
        '/person/$personId',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
        },
      );
      final data = response.data as Map<String, dynamic>;

      // Fallback to English if Turkish biography is empty or null
      final biography = data['biography'] as String?;
      if (language == 'tr-TR' && (biography == null || biography.trim().isEmpty)) {
        try {
          final enResponse = await _dio.get(
            '/person/$personId',
            queryParameters: {
              'api_key': _apiKey,
              'language': 'en-US',
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
      throw Exception('TMDb Person Details Hatası: ${e.message}');
    }
  }

  /// Get person combined credits (TMDb /person/$personId/combined_credits)
  Future<List<Map<String, dynamic>>> getPersonCombinedCredits(int personId, {String language = 'tr-TR'}) async {
    if (_apiKey.isEmpty) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/person/$personId/combined_credits',
        queryParameters: {
          'api_key': _apiKey,
          'language': language,
        },
      );
      final cast = response.data['cast'] as List<dynamic>? ?? [];
      return cast.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw Exception('TMDb Combined Credits Hatası: ${e.message}');
    }
  }
}
