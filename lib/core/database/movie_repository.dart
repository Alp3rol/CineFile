import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_database.dart';
import 'database_provider.dart';
import '../../features/auth/controllers/auth_controller.dart';

/// Centralizes the native (Drift/SQLite) vs. web (in-memory) write paths
/// behind one interface, so call sites don't need to branch on kIsWeb
/// themselves and each platform's logic lives in exactly one place.
abstract class MovieRepository {
  Future<void> createCustomList(String name, String? description, {DateTime? targetDate});
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
  // Turns a collection's "Koleksiyon Paylaş" live sync on/off. When turned
  // on, mirrors the collection's current contents to Firestore's
  // shared_collections/{ownerId_listId} immediately; when turned off,
  // deletes that mirror doc (the local collection itself is untouched
  // either way — this only controls the Community feed's visibility).
  Future<void> setCollectionVisibility(int listId, bool isPublic);
}

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return kIsWeb ? WebMovieRepository(ref) : NativeMovieRepository(ref);
});

class NativeMovieRepository implements MovieRepository {
  NativeMovieRepository(this._ref);
  final Ref _ref;
  AppDatabase get _db => _ref.read(databaseProvider);

  @override
  Future<void> createCustomList(String name, String? description, {DateTime? targetDate}) async {
    await _db.into(_db.customLists).insert(
          CustomListsCompanion.insert(
            name: name,
            description: Value(description),
            targetDate: Value(targetDate),
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
    await _mirrorSharedCollectionIfPublic(id);
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
      await _mirrorSharedCollectionIfPublic(listId);
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
    await _mirrorSharedCollectionIfPublic(listId);
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
      await _mirrorSharedCollectionIfPublic(listId);
    } catch (e, st) {
      debugPrint('reorderCustomListMovies failed: $e\n$st');
      rethrow;
    }
  }

  // Re-mirrors `listId`'s current contents to Firestore ONLY if that
  // collection is currently shared — a no-op for the (default, common)
  // case of a private collection, so ordinary local edits stay cheap.
  Future<void> _mirrorSharedCollectionIfPublic(int listId) async {
    final list = await (_db.select(_db.customLists)..where((t) => t.id.equals(listId))).getSingleOrNull();
    if (list != null && list.isPublic) {
      await _mirrorSharedCollection(listId);
    }
  }

  Future<void> _mirrorSharedCollection(int listId) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    final list = await (_db.select(_db.customLists)..where((t) => t.id.equals(listId))).getSingleOrNull();
    if (list == null) return;

    final movieRows = await (_db.select(_db.customListMovies)..where((t) => t.listId.equals(listId))).get();
    final movies = <Map<String, dynamic>>[];
    for (final row in movieRows) {
      final movie = await (_db.select(_db.movies)
            ..where((t) => t.tmdbId.equals(row.movieId) & t.isTv.equals(row.isTv)))
          .getSingleOrNull();
      if (movie == null) continue;
      movies.add({
        'tmdbId': movie.tmdbId,
        'isTv': movie.isTv,
        'title': movie.title,
        'posterPath': movie.posterPath,
        'rankingOrder': row.rankingOrder ?? 0,
      });
    }
    movies.sort((a, b) => (a['rankingOrder'] as int).compareTo(b['rankingOrder'] as int));

    final userModel = _ref.read(userModelProvider);
    final username = userModel?.username ?? user.email!.split('@')[0];
    final avatarUrl = userModel?.avatarUrl ?? 'https://api.dicebear.com/7.x/bottts/png?seed=$username';

    await _ref.read(firestoreProvider).collection('shared_collections').doc('${user.uid}_$listId').set({
      'ownerId': user.uid,
      'ownerUsername': username,
      'ownerAvatarUrl': avatarUrl,
      'name': list.name,
      'description': list.description,
      'movies': movies,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setCollectionVisibility(int listId, bool isPublic) async {
    if (isPublic) {
      await _mirrorSharedCollection(listId);
      await (_db.update(_db.customLists)..where((t) => t.id.equals(listId)))
          .write(const CustomListsCompanion(isPublic: Value(true)));
    } else {
      await (_db.update(_db.customLists)..where((t) => t.id.equals(listId)))
          .write(const CustomListsCompanion(isPublic: Value(false)));
      final user = _ref.read(authStateProvider).value;
      if (user != null) {
        await _ref.read(firestoreProvider).collection('shared_collections').doc('${user.uid}_$listId').delete();
      }
    }
  }

  @override
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) async {
    try {
      final authState = _ref.read(authStateProvider);
      final user = authState.value;
      if (user == null) return;

      for (final entry in rankings.entries) {
        final key = entry.key;
        final rank = entry.value;

        final settingsRef = _ref.read(firestoreProvider)
            .collection('users')
            .doc(user.uid)
            .collection('movie_settings')
            .doc('${key.tmdbId}_${key.isTv}');

        await settingsRef.set({
          'movieId': key.tmdbId,
          'isTv': key.isTv,
          'personalRanking': rank,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e, st) {
      debugPrint('updateWatchRecordRankings failed: $e\n$st');
      rethrow;
    }
  }
}

class WebMovieRepository implements MovieRepository {
  WebMovieRepository(this._ref);
  final Ref _ref;

  @override
  Future<void> createCustomList(String name, String? description, {DateTime? targetDate}) async {
    final notifier = _ref.read(webCustomListsProvider.notifier);
    final map = _ref.read(webCustomListsProvider);
    final newMap = Map<int, CustomList>.from(map);
    final nextId = newMap.isEmpty ? 1 : newMap.keys.reduce((a, b) => a > b ? a : b) + 1;
    newMap[nextId] = CustomList(
      id: nextId,
      name: name,
      description: description,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      isPublic: false,
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
        isPublic: existing.isPublic,
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
    try {
      final authState = _ref.read(authStateProvider);
      final user = authState.value;
      if (user == null) return;

      for (final entry in rankings.entries) {
        final key = entry.key;
        final rank = entry.value;

        final settingsRef = _ref.read(firestoreProvider)
            .collection('users')
            .doc(user.uid)
            .collection('movie_settings')
            .doc('${key.tmdbId}_${key.isTv}');

        await settingsRef.set({
          'movieId': key.tmdbId,
          'isTv': key.isTv,
          'personalRanking': rank,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e, st) {
      debugPrint('updateWatchRecordRankings failed: $e\n$st');
      rethrow;
    }
  }

  // Web collections stay in-memory only (see webCustomListsProvider) —
  // there's no local persistence to mirror from, and the "Koleksiyon
  // Paylaş" entry point is disabled on web builds, so this is never
  // expected to be called. A no-op rather than a crash if it ever is.
  @override
  Future<void> setCollectionVisibility(int listId, bool isPublic) async {}
}
