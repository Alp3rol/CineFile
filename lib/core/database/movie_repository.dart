import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';
import 'database_provider.dart';

/// Centralizes the native (Drift/SQLite) vs. web (in-memory) write paths
/// behind one interface, so call sites don't need to branch on kIsWeb
/// themselves and each platform's logic lives in exactly one place.
abstract class MovieRepository {
  Future<void> createCustomList(String name, String? description);
  Future<void> updateCustomList(
    int id,
    String name,
    String? description, {
    DateTime? targetDate,
    bool clearTargetDate,
  });
  Future<void> deleteCustomList(int id);
  Future<void> addMovieToCustomList(int listId, Movie movieData);
  Future<void> removeMovieFromCustomList(int listId, int tmdbId, bool isTv);
  Future<void> reorderCustomListMovies(int listId, Map<MovieKey, int> rankings);
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings);
}

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return kIsWeb ? WebMovieRepository(ref) : NativeMovieRepository(ref);
});

class NativeMovieRepository implements MovieRepository {
  NativeMovieRepository(this._ref);
  final Ref _ref;
  AppDatabase get _db => _ref.read(databaseProvider);

  @override
  Future<void> createCustomList(String name, String? description) async {
    await _db.into(_db.customLists).insert(
          CustomListsCompanion.insert(
            name: name,
            description: Value(description),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> updateCustomList(
    int id,
    String name,
    String? description, {
    DateTime? targetDate,
    bool clearTargetDate = false,
  }) async {
    await (_db.update(_db.customLists)..where((t) => t.id.equals(id))).write(
          CustomListsCompanion(
            name: Value(name),
            description: Value(description),
            targetDate: Value(clearTargetDate ? null : targetDate),
          ),
        );
  }

  @override
  Future<void> deleteCustomList(int id) async {
    await (_db.delete(_db.customLists)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> addMovieToCustomList(int listId, Movie movieData) async {
    try {
      // 1. Ensure movie metadata exists. createdAt is intentionally left
      // absent so an existing movie's original "added at" timestamp isn't
      // bumped to "now" just because it was added to another list.
      await _db.into(_db.movies).insertOnConflictUpdate(
            MoviesCompanion.insert(
              tmdbId: movieData.tmdbId,
              title: movieData.title,
              originalTitle: Value(movieData.originalTitle),
              posterPath: Value(movieData.posterPath),
              backdropPath: Value(movieData.backdropPath),
              releaseYear: Value(movieData.releaseYear),
              runtime: Value(movieData.runtime),
              genres: Value(movieData.genres),
              director: Value(movieData.director),
              actors: Value(movieData.actors),
              overview: Value(movieData.overview),
              isTv: Value(movieData.isTv),
            ),
          );

      // Find the next rankingOrder
      final existingMovies = await (_db.select(_db.customListMovies)..where((t) => t.listId.equals(listId))).get();
      final maxOrder = existingMovies.isEmpty ? 0 : existingMovies.map((r) => r.rankingOrder ?? 0).reduce((a, b) => a > b ? a : b);

      // 2. Insert relation
      await _db.into(_db.customListMovies).insertOnConflictUpdate(
            CustomListMovie(
              listId: listId,
              movieId: movieData.tmdbId,
              isTv: movieData.isTv,
              rankingOrder: maxOrder + 1,
              addedAt: DateTime.now(),
            ),
          );
    } catch (e, st) {
      debugPrint('addMovieToCustomList failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> removeMovieFromCustomList(int listId, int tmdbId, bool isTv) async {
    await (_db.delete(_db.customListMovies)
          ..where((t) => t.listId.equals(listId) & t.movieId.equals(tmdbId) & t.isTv.equals(isTv)))
        .go();
  }

  @override
  Future<void> reorderCustomListMovies(int listId, Map<MovieKey, int> rankings) async {
    try {
      await _db.transaction(() async {
        for (final entry in rankings.entries) {
          await (_db.update(_db.customListMovies)
                ..where((t) =>
                    t.listId.equals(listId) & t.movieId.equals(entry.key.tmdbId) & t.isTv.equals(entry.key.isTv)))
              .write(CustomListMoviesCompanion(rankingOrder: Value(entry.value)));
        }
      });
    } catch (e, st) {
      debugPrint('reorderCustomListMovies failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) async {
    try {
      await _db.transaction(() async {
        for (final entry in rankings.entries) {
          final key = entry.key;
          final rank = entry.value;

          final existing = await (_db.select(_db.userMovieSettings)
                ..where((t) => t.tmdbId.equals(key.tmdbId) & t.isTv.equals(key.isTv)))
              .getSingleOrNull();
          if (existing != null) {
            await (_db.update(_db.userMovieSettings)
                  ..where((t) => t.tmdbId.equals(key.tmdbId) & t.isTv.equals(key.isTv)))
                .write(UserMovieSettingsCompanion(personalRanking: Value(rank)));
          } else {
            await _db.into(_db.userMovieSettings).insert(
              UserMovieSettingsCompanion(tmdbId: Value(key.tmdbId), isTv: Value(key.isTv), personalRanking: Value(rank)),
            );
          }
        }
      });
    } catch (e) {
      debugPrint('updateWatchRecordRankings failed: $e');
    }
  }
}

class WebMovieRepository implements MovieRepository {
  WebMovieRepository(this._ref);
  final Ref _ref;

  @override
  Future<void> createCustomList(String name, String? description) async {
    final notifier = _ref.read(webCustomListsProvider.notifier);
    final map = _ref.read(webCustomListsProvider);
    final newMap = Map<int, CustomList>.from(map);
    final nextId = newMap.isEmpty ? 1 : newMap.keys.reduce((a, b) => a > b ? a : b) + 1;
    newMap[nextId] = CustomList(
      id: nextId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    notifier.state = newMap;
  }

  @override
  Future<void> updateCustomList(
    int id,
    String name,
    String? description, {
    DateTime? targetDate,
    bool clearTargetDate = false,
  }) async {
    final notifier = _ref.read(webCustomListsProvider.notifier);
    final map = _ref.read(webCustomListsProvider);
    final newMap = Map<int, CustomList>.from(map);
    final existing = newMap[id];
    if (existing != null) {
      newMap[id] = CustomList(
        id: id,
        name: name,
        description: description,
        targetDate: clearTargetDate ? null : (targetDate ?? existing.targetDate),
        createdAt: existing.createdAt,
      );
      notifier.state = newMap;
    }
  }

  @override
  Future<void> deleteCustomList(int id) async {
    final listNotifier = _ref.read(webCustomListsProvider.notifier);
    final map = _ref.read(webCustomListsProvider);
    final newMap = Map<int, CustomList>.from(map)..remove(id);
    listNotifier.state = newMap;

    final moviesNotifier = _ref.read(webCustomListMoviesProvider.notifier);
    final movies = _ref.read(webCustomListMoviesProvider);
    moviesNotifier.state = movies.where((r) => r.listId != id).toList();
  }

  @override
  Future<void> addMovieToCustomList(int listId, Movie movieData) async {
    // Ensure movie metadata exists
    final moviesNotifier = _ref.read(webMoviesProvider.notifier);
    final moviesMap = _ref.read(webMoviesProvider);
    final key = (tmdbId: movieData.tmdbId, isTv: movieData.isTv);
    if (!moviesMap.containsKey(key)) {
      final newMovies = Map<MovieKey, Movie>.from(moviesMap);
      newMovies[key] = movieData;
      moviesNotifier.state = newMovies;
    }

    final notifier = _ref.read(webCustomListMoviesProvider.notifier);
    final currentList = _ref.read(webCustomListMoviesProvider);
    if (!currentList.any((r) => r.listId == listId && r.movieId == movieData.tmdbId && r.isTv == movieData.isTv)) {
      final listMovies = currentList.where((r) => r.listId == listId);
      final maxOrder = listMovies.isEmpty ? 0 : listMovies.map((r) => r.rankingOrder ?? 0).reduce((a, b) => a > b ? a : b);

      notifier.state = [
        ...currentList,
        CustomListMovie(
          listId: listId,
          movieId: movieData.tmdbId,
          isTv: movieData.isTv,
          rankingOrder: maxOrder + 1,
          addedAt: DateTime.now(),
        )
      ];
    }
  }

  @override
  Future<void> removeMovieFromCustomList(int listId, int tmdbId, bool isTv) async {
    final notifier = _ref.read(webCustomListMoviesProvider.notifier);
    final currentList = _ref.read(webCustomListMoviesProvider);
    notifier.state =
        currentList.where((r) => !(r.listId == listId && r.movieId == tmdbId && r.isTv == isTv)).toList();
  }

  @override
  Future<void> reorderCustomListMovies(int listId, Map<MovieKey, int> rankings) async {
    final notifier = _ref.read(webCustomListMoviesProvider.notifier);
    final currentList = _ref.read(webCustomListMoviesProvider);
    final updatedList = currentList.map((r) {
      final key = (tmdbId: r.movieId, isTv: r.isTv);
      if (r.listId == listId && rankings.containsKey(key)) {
        return CustomListMovie(
          listId: listId,
          movieId: r.movieId,
          isTv: r.isTv,
          rankingOrder: rankings[key],
          addedAt: r.addedAt,
        );
      }
      return r;
    }).toList();
    notifier.state = updatedList;
  }

  @override
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) async {
    final map = _ref.read(webMovieSettingsProvider);
    final newMap = Map<MovieKey, UserMovieSetting>.from(map);
    for (final entry in rankings.entries) {
      final key = entry.key;
      final rank = entry.value;
      final existing = newMap[key];
      newMap[key] = UserMovieSetting(
        tmdbId: key.tmdbId,
        isTv: key.isTv,
        isFavorite: existing?.isFavorite ?? false,
        isReWatchList: existing?.isReWatchList ?? false,
        personalNotes: existing?.personalNotes,
        personalTags: existing?.personalTags,
        personalRanking: rank,
        updatedAt: DateTime.now(),
        isActivelyWatching: existing?.isActivelyWatching ?? false,
        lastWatchedEpisode: existing?.lastWatchedEpisode,
      );
    }
    _ref.read(webMovieSettingsProvider.notifier).state = newMap;
  }
}
