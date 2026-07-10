import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'app_database.dart';
import 'movie_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// TMDb movie IDs and TV show IDs come from separate counters, so a movie and
// a show can legitimately share the same numeric tmdbId. Every place that
// used to key by tmdbId alone now keys by this (tmdbId, isTv) pair instead —
// otherwise adding one silently overwrites/aliases the other (see
// tables.dart's Movies.primaryKey comment for the full story).
typedef MovieKey = ({int tmdbId, bool isTv});

// --- IN-MEMORY PROVIDERS FOR WEB COMPATIBILITY ---
// Since sql.js is not loaded on Flutter Web without hosting setup,
// we use in-memory Riverpod lists to simulate database operations on Web.
final webWatchRecordsProvider = StateProvider<List<WatchRecord>>((ref) => []);
final webMovieSettingsProvider = StateProvider<Map<MovieKey, UserMovieSetting>>((ref) => {});
final webMoviesProvider = StateProvider<Map<MovieKey, Movie>>((ref) => {});

// Stream provider to get watch records for a specific movie
final watchRecordsForMovieProvider = StreamProvider.family<List<WatchRecord>, MovieKey>((ref, key) {
  if (kIsWeb) {
    final list = ref.watch(webWatchRecordsProvider);
    final filtered = list.where((r) => r.movieId == key.tmdbId && r.isTv == key.isTv).toList();
    // Sort descending by watchDate
    filtered.sort((a, b) => b.watchDate.compareTo(a.watchDate));
    return Stream.value(filtered);
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.watchRecords)
        ..where((t) => t.movieId.equals(key.tmdbId) & t.isTv.equals(key.isTv))
        ..orderBy([(t) => OrderingTerm.desc(t.watchDate)]))
      .watch();
});

// Stream provider to get settings for a specific movie
final movieSettingsProvider = StreamProvider.family<UserMovieSetting?, MovieKey>((ref, key) {
  if (kIsWeb) {
    final map = ref.watch(webMovieSettingsProvider);
    return Stream.value(map[key]);
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.userMovieSettings)
        ..where((t) => t.tmdbId.equals(key.tmdbId) & t.isTv.equals(key.isTv)))
      .watchSingleOrNull();
});

// Model to represent a Watch Record joined with its Movie metadata and settings
class WatchRecordWithMovie {
  final WatchRecord record;
  final Movie movie;
  final UserMovieSetting? setting;
  WatchRecordWithMovie(this.record, this.movie, {this.setting});
}

// Stream provider to get all watch records with movie details
final allWatchRecordsProvider = StreamProvider<List<WatchRecordWithMovie>>((ref) {
  if (kIsWeb) {
    final records = ref.watch(webWatchRecordsProvider);
    final movies = ref.watch(webMoviesProvider);
    final settings = ref.watch(webMovieSettingsProvider);
    
    final list = records.map((r) {
      final key = (tmdbId: r.movieId, isTv: r.isTv);
      final movie = movies[key] ?? Movie(
        tmdbId: r.movieId,
        title: 'Bilinmeyen Film',
        isTv: r.isTv,
        createdAt: DateTime.now(),
      );
      final setting = settings[key];
      return WatchRecordWithMovie(r, movie, setting: setting);
    }).toList();

    // Sort descending by watchDate
    list.sort((a, b) => b.record.watchDate.compareTo(a.record.watchDate));
    return Stream.value(list);
  }

  final db = ref.watch(databaseProvider);
  final query = db.select(db.watchRecords).join([
    leftOuterJoin(
      db.movies,
      db.movies.tmdbId.equalsExp(db.watchRecords.movieId) & db.movies.isTv.equalsExp(db.watchRecords.isTv),
    ),
    leftOuterJoin(
      db.userMovieSettings,
      db.userMovieSettings.tmdbId.equalsExp(db.watchRecords.movieId) &
          db.userMovieSettings.isTv.equalsExp(db.watchRecords.isTv),
    ),
  ]);
  
  // Sort by watchDate descending
  query.orderBy([OrderingTerm.desc(db.watchRecords.watchDate)]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return WatchRecordWithMovie(
        row.readTable(db.watchRecords),
        row.readTable(db.movies),
        setting: row.readTableOrNull(db.userMovieSettings),
      );
    }).toList();
  });
});

// Stream provider to get a set of favorite movie IDs
final favoriteMovieIdsProvider = StreamProvider<Set<MovieKey>>((ref) {
  if (kIsWeb) {
    final settings = ref.watch(webMovieSettingsProvider);
    return Stream.value(settings.entries
        .where((e) => e.value.isFavorite)
        .map((e) => e.key)
        .toSet());
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.userMovieSettings)..where((t) => t.isFavorite.equals(true)))
      .watch()
      .map((list) => list.map((e) => (tmdbId: e.tmdbId, isTv: e.isTv)).toSet());
});

// Stream provider for the most recently added movies (by Movie.createdAt),
// used by the Home screen's "Son Eklediklerim" section.
final recentlyAddedMoviesProvider = StreamProvider<List<Movie>>((ref) {
  if (kIsWeb) {
    final map = ref.watch(webMoviesProvider);
    final sorted = map.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Stream.value(sorted.take(10).toList());
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.movies)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(10))
      .watch();
});

// Stream provider for movies that have been added to the library but have
// no WatchRecords entry yet, used by the Home screen's "Bu Hafta Ne
// İzlesem?" suggestion card. There is no dedicated "watchlist" flag in the
// schema (UserMovieSettings.isReWatchList exists but is never toggled by
// any UI), so "unwatched" is derived from the absence of a WatchRecords row.
final unwatchedMoviesProvider = StreamProvider<List<Movie>>((ref) {
  if (kIsWeb) {
    final movies = ref.watch(webMoviesProvider);
    final records = ref.watch(webWatchRecordsProvider);
    final watchedKeys = records.map((r) => (tmdbId: r.movieId, isTv: r.isTv)).toSet();
    return Stream.value(movies.values.where((m) => !watchedKeys.contains((tmdbId: m.tmdbId, isTv: m.isTv))).toList());
  }

  final db = ref.watch(databaseProvider);
  final query = db.select(db.movies).join([
    leftOuterJoin(
      db.watchRecords,
      db.watchRecords.movieId.equalsExp(db.movies.tmdbId) & db.watchRecords.isTv.equalsExp(db.movies.isTv),
    ),
  ])
    ..where(db.watchRecords.id.isNull());

  return query.watch().map((rows) => rows.map((row) => row.readTable(db.movies)).toList());
});

// A TV show the user is currently tracking episode-by-episode (see
// UserMovieSettings.isActivelyWatching), used by the Home/Journal "Aktif
// İzlediklerin" quick-add sections.
class ActivelyWatchingShow {
  final Movie movie;
  final UserMovieSetting setting;
  ActivelyWatchingShow(this.movie, this.setting);
}

final activelyWatchingProvider = StreamProvider<List<ActivelyWatchingShow>>((ref) {
  if (kIsWeb) {
    final movies = ref.watch(webMoviesProvider);
    final settings = ref.watch(webMovieSettingsProvider);
    final list = settings.entries
        .where((e) => e.value.isActivelyWatching)
        .map((e) {
          final movie = movies[e.key];
          return movie == null ? null : ActivelyWatchingShow(movie, e.value);
        })
        .whereType<ActivelyWatchingShow>()
        .toList();
    return Stream.value(list);
  }

  final db = ref.watch(databaseProvider);
  final query = db.select(db.userMovieSettings).join([
    innerJoin(
      db.movies,
      db.movies.tmdbId.equalsExp(db.userMovieSettings.tmdbId) &
          db.movies.isTv.equalsExp(db.userMovieSettings.isTv),
    ),
  ])
    ..where(db.userMovieSettings.isActivelyWatching.equals(true));

  return query.watch().map((rows) {
    return rows
        .map((row) => ActivelyWatchingShow(row.readTable(db.movies), row.readTable(db.userMovieSettings)))
        .toList();
  });
});

// --- CUSTOM LISTS PROVIDERS AND ACTIONS ---

// Web in-memory lists state
final webCustomListsProvider = StateProvider<Map<int, CustomList>>((ref) => {});
final webCustomListMoviesProvider = StateProvider<List<CustomListMovie>>((ref) => []);

// Stream provider to get all custom lists
final customListsProvider = StreamProvider<List<CustomList>>((ref) {
  if (kIsWeb) {
    final map = ref.watch(webCustomListsProvider);
    final sorted = map.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Stream.value(sorted);
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.customLists)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
});

class CustomListMovieWithMovie {
  final CustomListMovie relation;
  final Movie movie;
  CustomListMovieWithMovie(this.relation, this.movie);
}

// Stream provider to get movies in a specific list, ordered by rankingOrder or addedAt
final moviesInCustomListProvider = StreamProvider.family<List<CustomListMovieWithMovie>, int>((ref, listId) {
  if (kIsWeb) {
    final list = ref.watch(webCustomListMoviesProvider);
    final movies = ref.watch(webMoviesProvider);
    
    final filtered = list.where((r) => r.listId == listId).map((r) {
      final movie = movies[(tmdbId: r.movieId, isTv: r.isTv)] ?? Movie(
        tmdbId: r.movieId,
        title: 'Bilinmeyen Film',
        isTv: r.isTv,
        createdAt: DateTime.now(),
      );
      return CustomListMovieWithMovie(r, movie);
    }).toList();
    
    // Sort: if rankingOrder is not null, sort by it, otherwise sort by addedAt descending
    filtered.sort((a, b) {
      final rA = a.relation.rankingOrder;
      final rB = b.relation.rankingOrder;
      if (rA != null && rB != null) {
        return rA.compareTo(rB);
      } else if (rA != null) {
        return -1;
      } else if (rB != null) {
        return 1;
      } else {
        return b.relation.addedAt.compareTo(a.relation.addedAt);
      }
    });
    return Stream.value(filtered);
  }

  final db = ref.watch(databaseProvider);
  final query = db.select(db.customListMovies).join([
    leftOuterJoin(
      db.movies,
      db.movies.tmdbId.equalsExp(db.customListMovies.movieId) &
          db.movies.isTv.equalsExp(db.customListMovies.isTv),
    ),
  ])..where(db.customListMovies.listId.equals(listId));

  // Order: first by rankingOrder (ascending), then addedAt (descending)
  query.orderBy([
    OrderingTerm.asc(db.customListMovies.rankingOrder),
    OrderingTerm.desc(db.customListMovies.addedAt),
  ]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return CustomListMovieWithMovie(
        row.readTable(db.customListMovies),
        row.readTable(db.movies),
      );
    }).toList();
  });
});

// Stream provider to find which lists a movie belongs to
final listsForMovieProvider = StreamProvider.family<Set<int>, MovieKey>((ref, key) {
  if (kIsWeb) {
    final list = ref.watch(webCustomListMoviesProvider);
    return Stream.value(
        list.where((r) => r.movieId == key.tmdbId && r.isTv == key.isTv).map((r) => r.listId).toSet());
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.customListMovies)
        ..where((t) => t.movieId.equals(key.tmdbId) & t.isTv.equals(key.isTv)))
      .watch()
      .map((list) => list.map((e) => e.listId).toSet());
});

// --- CUSTOM LIST ACTIONS ---
//
// These delegate to movieRepositoryProvider (see movie_repository.dart),
// which picks the native (Drift/SQLite) or web (in-memory) implementation.
// Kept as free functions so existing call sites don't need to change.

Future<void> createCustomList(WidgetRef ref, String name, String? description) =>
    ref.read(movieRepositoryProvider).createCustomList(name, description);

Future<void> updateCustomList(
  WidgetRef ref,
  int id,
  String name,
  String? description, {
  DateTime? targetDate,
  bool clearTargetDate = false,
}) =>
    ref.read(movieRepositoryProvider).updateCustomList(
          id,
          name,
          description,
          targetDate: targetDate,
          clearTargetDate: clearTargetDate,
        );

Future<void> deleteCustomList(WidgetRef ref, int id) =>
    ref.read(movieRepositoryProvider).deleteCustomList(id);

Future<void> addMovieToCustomList(WidgetRef ref, int listId, Movie movieData) =>
    ref.read(movieRepositoryProvider).addMovieToCustomList(listId, movieData);

Future<void> removeMovieFromCustomList(WidgetRef ref, int listId, int tmdbId, bool isTv) =>
    ref.read(movieRepositoryProvider).removeMovieFromCustomList(listId, tmdbId, isTv);

Future<void> reorderCustomListMovies(WidgetRef ref, int listId, Map<MovieKey, int> rankings) =>
    ref.read(movieRepositoryProvider).reorderCustomListMovies(listId, rankings);

// --- WATCH RECORD ACTIONS ---

Future<void> deleteWatchRecord(WidgetRef ref, int recordId) async {
  if (kIsWeb) {
    final notifier = ref.read(webWatchRecordsProvider.notifier);
    final currentList = ref.read(webWatchRecordsProvider);
    notifier.state = currentList.where((r) => r.id != recordId).toList();
    return;
  }
  
  final db = ref.read(databaseProvider);
  await (db.delete(db.watchRecords)..where((t) => t.id.equals(recordId))).go();
}

Future<void> updateWatchRecord(
  WidgetRef ref,
  int recordId, {
  DateTime? watchDate,
  int? episodeCount,
}) async {
  if (kIsWeb) {
    final notifier = ref.read(webWatchRecordsProvider.notifier);
    final currentList = ref.read(webWatchRecordsProvider);
    notifier.state = currentList.map((r) {
      if (r.id == recordId) {
        return WatchRecord(
          id: r.id,
          movieId: r.movieId,
          isTv: r.isTv,
          watchDate: watchDate ?? r.watchDate,
          watchPlace: r.watchPlace,
          watchCompanion: r.watchCompanion,
          rating: r.rating,
          mood: r.mood,
          notes: r.notes,
          watchNumber: r.watchNumber,
          tags: r.tags,
          createdAt: r.createdAt,
          episodeCount: episodeCount ?? r.episodeCount,
        );
      }
      return r;
    }).toList();
    return;
  }

  final db = ref.read(databaseProvider);
  await (db.update(db.watchRecords)..where((t) => t.id.equals(recordId))).write(
    WatchRecordsCompanion(
      watchDate: watchDate != null ? Value(watchDate) : const Value.absent(),
      episodeCount: episodeCount != null ? Value(episodeCount) : const Value.absent(),
    ),
  );
}
