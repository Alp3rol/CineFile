import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/network/tmdb_service.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/movie_repository.dart';
import '../../../core/l10n/l10n_lookup.dart';
import '../../settings/presentation/settings_provider.dart';

final movieDetailProvider = FutureProvider.family<Map<String, dynamic>?, ({int tmdbId, bool isTv})>((ref, arg) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  // The offline fallbacks below put text into the payload the UI renders, so
  // they need the user's language without a BuildContext.
  final l10n = lookupL10n(ref.watch(localeProvider));
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
          'overview': localMovie.overview ?? l10n.offlineOverviewUnavailable,
          'genres': (localMovie.genres ?? '').split(', ').where((g) => g.isNotEmpty).map((g) => {'name': g}).toList(),
          'credits': {
            'cast': (localMovie.actors ?? '').split(', ').where((a) => a.isNotEmpty).map((a) => {'name': a, 'character': ''}).toList(),
            // No crew entry at all when the director is unknown. This used to
            // fabricate the name "Bilinmiyor", which then got written back into
            // the Movies row the next time details were cached — a localized
            // placeholder masquerading as data, which recommendations still
            // has to guard against. The UI supplies its own placeholder.
            'crew': [
              if (localMovie.director != null)
                {'name': localMovie.director, 'job': 'Director'},
            ],
          }
        };
      }
    } catch (_) {}

    // 2. Ultimate fallback: Return a basic template instead of crashing the screen
    //
    // There used to be a step here that matched arg.tmdbId against the six
    // demo titles and returned them with a FABRICATED payload: runtime 148,
    // genres "Bilim Kurgu, Dram", and Christopher Nolan as director — for all
    // six, including Dune: Part Two and Across the Spider-Verse.
    //
    // That was not limited to the documented no-API-key demo mode; TmdbService
    // already answers those from its own mock list without throwing, so this
    // branch only ran on a REAL failure (DNS block, timeout, 429). And the
    // payload did not stay on screen: MovieDetailScreen hands it to
    // cacheMovieMetadata, and AddWatchRecordSheet copies movieDirector/
    // movieGenres out of it into the Firestore log. A single timeout could
    // therefore write "Christopher Nolan" into the user's library permanently,
    // which then fed the Nolan achievement badge, topDirectors, and the
    // director-based recommendations.
    //
    // A network failure is a network failure. The honest fallback carries no
    // credits at all.
    return {
      // Marks this payload as "we could not load anything". Every field below
      // is a placeholder, so the local metadata cache refuses it (see
      // cacheMovieMetadata) rather than persisting a localized title and an
      // invented runtime as if they were TMDb data.
      kOfflinePlaceholderKey: true,
      'id': arg.tmdbId,
      'title': l10n.offlineContentTitle,
      'original_title': 'Offline Content',
      'poster_path': null,
      'backdrop_path': null,
      'release_date': '',
      'runtime': 120,
      'overview': l10n.offlineFallbackOverview,
      'genres': [],
      // Empty rather than a fabricated director — see the local-cache branch
      // above.
      'credits': {'cast': [], 'crew': []},
    };
  }
});
