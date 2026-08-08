part of 'database_provider.dart';

// native/signed-in Firestore stream (movieSettingsProvider below) behind one
// AsyncValue â€” lets callers (e.g. add_watch_record_sheet.dart's episode-
// tracking seed) ref.watch a single provider instead of branching on kIsWeb
// themselves. A reactive read via ref.watch, so this kIsWeb branch is within
// this file's documented exception (see CLAUDE.md).
final movieSettingsSnapshotProvider =
    Provider.family<AsyncValue<UserMovieSetting?>, MovieKey>((ref, key) {
      final user = ref.watch(authStateProvider).value;
      if (kIsWeb && user == null) {
        return AsyncValue.data(ref.watch(webMovieSettingsProvider)[key]);
      }
      return ref.watch(movieSettingsProvider(key));
    });

/// Re-subscribes [movieSettingsProvider] for [key] so its next value is a
/// genuinely current snapshot.
///
/// Riverpod 3 pauses a provider while nothing is listening to it, and a
/// paused stream provider hands its next listener the value it held at pause
/// time â€” anything that landed in between is only applied a tick later, with
/// no flag (`isRefreshing`, `isLoading`...) marking that first value as
/// stale. Callers that seed state from the first build where settings have a
/// value would therefore seed from a pre-write snapshot: reopening
/// AddWatchRecordSheet after logging an episode suggested the episode just
/// logged instead of the next one.
///
/// Invalidating drops the cached value, so the settings read as "loading"
/// until Firestore answers again and seeding waits for real data. A reactive
/// read is not possible here (the point is to discard what was cached), so
/// this kIsWeb branch is within this file's documented exception (see
/// CLAUDE.md) â€” the web-guest map lives in memory and is never stale.
void refreshMovieSettings(WidgetRef ref, MovieKey key) {
  if (kIsWeb) return;
  ref.invalidate(movieSettingsProvider(key));
}

// Stream provider to get settings for a specific movie
final movieSettingsProvider =
    StreamProvider.family<UserMovieSetting?, MovieKey>((ref, key) {
      final authState = ref.watch(authStateProvider);
      final user = authState.value;
      if (user == null) {
        return Stream.value(null);
      }

      return ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${key.tmdbId}_${key.isTv}')
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            final data = doc.data()!;
            return UserMovieSetting(
              tmdbId: key.tmdbId,
              isTv: key.isTv,
              isFavorite: parseBool(data['isFavorite']),
              isReWatchList: parseBool(data['isReWatchList']),
              personalRanking: parseInt(data['personalRanking']),
              personalNotes: data['personalNotes'] as String?,
              personalTags: data['personalTags'] as String?,
              updatedAt: parseDateTime(data['updatedAt']),
              isActivelyWatching: parseBool(data['isActivelyWatching']),
              lastWatchedEpisode: parseInt(data['lastWatchedEpisode']),
            );
          });
    });

// Model to represent a Watch Record joined with its Movie metadata and settings

// (tmdbId, isTv). Standalone convenience provider for anything that only
// needs settings, not logs â€” allWatchRecordsProvider (below) does NOT
// depend on this via ref.watch, since that would tear down and recreate its
// logs subscription (and briefly flash to a loading state) on every
// settings change; it merges both Firestore streams manually instead.
final allMovieSettingsProvider =
    StreamProvider<Map<MovieKey, UserMovieSetting>>((ref) {
      final authState = ref.watch(authStateProvider);
      final user = authState.value;
      if (user == null) {
        return Stream.value(<MovieKey, UserMovieSetting>{});
      }

      return ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .snapshots()
          .map(_movieSettingsMapFromSnapshot);
    });

// Stream provider to get all watch records with movie details (current

final favoriteMovieIdsProvider = StreamProvider<Set<MovieKey>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<MovieKey>{});
  }

  return ref
      .read(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('movie_settings')
      .where('isFavorite', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final movieId = (data['movieId'] as num?)?.toInt() ?? 0;
          final isTv = data['isTv'] == true || data['isTv'] == 1;
          return (tmdbId: movieId, isTv: isTv);
        }).toSet();
      });
});

// Stream provider for the most recently added movies (by Movie.createdAt),
// used by the Home screen's "Son Eklediklerim" section.
final recentlyAddedMoviesProvider = StreamProvider<List<Movie>>((ref) {
  final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
  return watchRecordsAsync.when(
    loading: () => Stream.value(<Movie>[]),
    error: (err, stack) => Stream.value(<Movie>[]),
    data: (records) {
      final seenKeys = <MovieKey>{};
      final movies = <Movie>[];
      for (final r in records) {
        final key = (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv);
        if (seenKeys.add(key)) {
          movies.add(r.movie);
        }
      }
      return Stream.value(movies.take(10).toList());
    },
  );
});

// Stream provider for movies that have been added to the library but have
// no WatchRecords entry yet, used by the Home screen's "Bu Hafta Ne
// Ä°zlesem?" suggestion card.
final unwatchedMoviesProvider = StreamProvider<List<Movie>>((ref) {
  final watchRecordsAsync = ref.watch(allWatchRecordsProvider);
  return watchRecordsAsync.when(
    loading: () => Stream.value(<Movie>[]),
    error: (err, stack) => Stream.value(<Movie>[]),
    data: (records) {
      final watchedKeys = records
          .map((r) => (tmdbId: r.movie.tmdbId, isTv: r.movie.isTv))
          .toSet();

      if (kIsWeb) {
        final movies = ref.watch(webMoviesProvider);
        return Stream.value(
          movies.values
              .where(
                (m) => !watchedKeys.contains((tmdbId: m.tmdbId, isTv: m.isTv)),
              )
              .toList(),
        );
      }

      final db = ref.watch(databaseProvider);
      final query = db.select(db.movies).join([
        leftOuterJoin(
          db.watchRecords,
          db.watchRecords.movieId.equalsExp(db.movies.tmdbId) &
              db.watchRecords.isTv.equalsExp(db.movies.isTv),
        ),
      ])..where(db.watchRecords.id.isNull());

      return query.watch().map((rows) {
        final list = rows.map((row) => row.readTable(db.movies)).toList();
        return list
            .where(
              (m) => !watchedKeys.contains((tmdbId: m.tmdbId, isTv: m.isTv)),
            )
            .toList();
      });
    },
  );
});

// A TV show the user is currently tracking episode-by-episode (see
// UserMovieSettings.isActivelyWatching), used by the Home/Journal "Aktif
// Ä°zlediklerin" quick-add sections.
class ActivelyWatchingShow {
  final Movie movie;
  final UserMovieSetting setting;
  ActivelyWatchingShow(this.movie, this.setting);
}

// Derived entirely from the two streams the app already keeps open
// (allWatchRecordsProvider for movie metadata, allMovieSettingsProvider for
// the isActivelyWatching flag), so it costs no additional Firestore reads.
//
// It used to run its own `movie_settings` listener and then, for every
// actively-watched show in each snapshot, fire a separate `logs` query just
// to recover that show's title and poster â€” N round trips per emission, on a
// widget that sits on the Home screen.
final activelyWatchingProvider = StreamProvider<List<ActivelyWatchingShow>>((
  ref,
) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(<ActivelyWatchingShow>[]);
  }

  final records = ref.watch(allWatchRecordsProvider).value;
  final settings = ref.watch(allMovieSettingsProvider).value;
  if (records == null || settings == null) {
    return Stream.value(<ActivelyWatchingShow>[]);
  }

  // First record per key wins; the list is already sorted newest-first, so
  // this is the most recently logged metadata for the show.
  final movieByKey = <MovieKey, Movie>{};
  for (final r in records) {
    movieByKey.putIfAbsent((
      tmdbId: r.movie.tmdbId,
      isTv: r.movie.isTv,
    ), () => r.movie);
  }

  final list = <ActivelyWatchingShow>[];
  for (final entry in settings.entries) {
    if (!entry.value.isActivelyWatching) continue;
    final movie = movieByKey[entry.key];
    // A show with no diary log behind it has no title/poster to render, same
    // condition the old per-show `logs` query enforced by returning nothing.
    if (movie == null) continue;
    list.add(ActivelyWatchingShow(movie, entry.value));
  }

  // Most recently active show first.
  list.sort((a, b) => b.setting.updatedAt.compareTo(a.setting.updatedAt));
  return Stream.value(list);
});

// --- CUSTOM LISTS PROVIDERS AND ACTIONS ---
