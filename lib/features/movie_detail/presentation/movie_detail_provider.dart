import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/network/tmdb_service.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';

final movieDetailProvider = FutureProvider.family<Map<String, dynamic>?, ({int tmdbId, bool isTv})>((ref, arg) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  try {
    return await tmdbService.getMovieDetails(arg.tmdbId, isTv: arg.isTv);
  } catch (e) {
    // 1. Fail-safe fallback: Try loading from local database/memory first
    try {
      Movie? localMovie;
      if (kIsWeb) {
        final webMovies = ref.read(webMoviesProvider);
        localMovie = webMovies[(tmdbId: arg.tmdbId, isTv: arg.isTv)];
      } else {
        final db = ref.read(databaseProvider);
        localMovie = await (db.select(db.movies)
              ..where((tbl) => tbl.tmdbId.equals(arg.tmdbId) & tbl.isTv.equals(arg.isTv)))
            .getSingleOrNull();
      }

      if (localMovie != null) {
        return {
          'id': localMovie.tmdbId,
          'title': localMovie.title,
          'original_title': localMovie.originalTitle ?? localMovie.title,
          'poster_path': localMovie.posterPath,
          'backdrop_path': localMovie.backdropPath,
          'release_date': localMovie.releaseYear != null ? '${localMovie.releaseYear}-01-01' : '',
          'runtime': localMovie.runtime ?? 120,
          'overview': localMovie.overview ?? 'Çevrimdışı mod: Özet yüklenemedi.',
          'genres': (localMovie.genres ?? '').split(', ').where((g) => g.isNotEmpty).map((g) => {'name': g}).toList(),
          'credits': {
            'cast': (localMovie.actors ?? '').split(', ').where((a) => a.isNotEmpty).map((a) => {'name': a, 'character': ''}).toList(),
            'crew': [{'name': localMovie.director ?? 'Bilinmiyor', 'job': 'Director'}]
          }
        };
      }
    } catch (_) {}

    // 2. If not in local DB, fallback to search in mock movies list
    final List<Map<String, dynamic>> mockMovies = [
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

    try {
      final mock = mockMovies.firstWhere((m) => m['id'] == arg.tmdbId);
      return {
        ...mock,
        'runtime': 148,
        'genres': [{'name': 'Bilim Kurgu'}, {'name': 'Dram'}],
        'credits': {
          'cast': [{'name': 'Matthew McConaughey', 'character': ''}],
          'crew': [{'name': 'Christopher Nolan', 'job': 'Director'}]
        }
      };
    } catch (_) {}

    // 3. Ultimate fallback: Return a basic template instead of crashing the screen
    return {
      'id': arg.tmdbId,
      'title': 'Çevrimdışı İçerik',
      'original_title': 'Offline Content',
      'poster_path': null,
      'backdrop_path': null,
      'release_date': '',
      'runtime': 120,
      'overview': 'Bağlantı sorunu nedeniyle film detayları tam yüklenemedi. Ancak bu içeriği hala günlüğünüze veya listelerinize ekleyebilirsiniz.',
      'genres': [],
      'credits': {
        'cast': [],
        'crew': [{'name': 'Bilinmiyor', 'job': 'Director'}]
      }
    };
  }
});
