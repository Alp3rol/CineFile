import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/controllers/auth_controller.dart';
import 'app_database.dart';
import 'database_provider.dart';
import 'web_local_store.dart';

/// Handles Custom Lists CRUD operations, list movie relations, ordering,
/// and live Firestore mirroring for shared collections.
abstract class CustomListRepository {
  Future<void> createCustomList(
    String name,
    String? description, {
    DateTime? targetDate,
  });
  Future<void> updateCustomList(
    int id,
    String name,
    String? description, {
    DateTime? targetDate,
    bool clearTargetDate = false,
  });
  Future<void> deleteCustomList(int id);
  Future<void> addMovieToCustomList(int listId, Movie movieData);
  Future<void> removeMovieFromCustomList(int listId, int tmdbId, bool isTv);
  Future<void> reorderCustomListMovies(int listId, Map<MovieKey, int> rankings);
  Future<void> setCollectionVisibility(int listId, bool isPublic);
}

final customListRepositoryProvider = Provider<CustomListRepository>((ref) {
  return kIsWeb
      ? WebCustomListRepository(ref)
      : NativeCustomListRepository(ref);
});

class NativeCustomListRepository implements CustomListRepository {
  NativeCustomListRepository(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

  @override
  Future<void> createCustomList(
    String name,
    String? description, {
    DateTime? targetDate,
  }) async {
    await _db
        .into(_db.customLists)
        .insert(
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
    await setCollectionVisibility(id, null);
  }

  @override
  Future<void> deleteCustomList(int id) async {
    final list = await (_db.select(
      _db.customLists,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (list != null && list.isPublic) {
      await _deleteSharedCollectionMirror(id);
    }
    await (_db.delete(_db.customLists)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> addMovieToCustomList(int listId, Movie movieData) async {
    try {
      await _db
          .into(_db.movies)
          .insertOnConflictUpdate(
            MoviesCompanion.insert(
              tmdbId: movieData.tmdbId,
              title: movieData.title,
              originalTitle: Value(movieData.originalTitle),
              posterPath: Value(movieData.posterPath),
              backdropPath: Value(movieData.backdropPath),
              releaseYear: Value(movieData.releaseYear),
              runtime: Value(movieData.runtime),
              genres: Value(movieData.genres),
              genreIds: Value(movieData.genreIds),
              director: Value(movieData.director),
              actors: Value(movieData.actors),
              overview: Value(movieData.overview),
              isTv: Value(movieData.isTv),
            ),
          );

      final existingMovies = await (_db.select(
        _db.customListMovies,
      )..where((t) => t.listId.equals(listId))).get();
      final maxOrder = existingMovies.isEmpty
          ? 0
          : existingMovies
                .map((r) => r.rankingOrder ?? 0)
                .reduce((a, b) => a > b ? a : b);

      await _db
          .into(_db.customListMovies)
          .insertOnConflictUpdate(
            CustomListMovie(
              listId: listId,
              movieId: movieData.tmdbId,
              isTv: movieData.isTv,
              rankingOrder: maxOrder + 1,
              addedAt: DateTime.now(),
            ),
          );
      await setCollectionVisibility(listId, null);
    } catch (e, st) {
      debugPrint('addMovieToCustomList failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> removeMovieFromCustomList(
    int listId,
    int tmdbId,
    bool isTv,
  ) async {
    await (_db.delete(_db.customListMovies)..where(
          (t) =>
              t.listId.equals(listId) &
              t.movieId.equals(tmdbId) &
              t.isTv.equals(isTv),
        ))
        .go();
    await setCollectionVisibility(listId, null);
  }

  @override
  Future<void> reorderCustomListMovies(
    int listId,
    Map<MovieKey, int> rankings,
  ) async {
    try {
      await _db.transaction(() async {
        for (final entry in rankings.entries) {
          await (_db.update(_db.customListMovies)..where(
                (t) =>
                    t.listId.equals(listId) &
                    t.movieId.equals(entry.key.tmdbId) &
                    t.isTv.equals(entry.key.isTv),
              ))
              .write(
                CustomListMoviesCompanion(rankingOrder: Value(entry.value)),
              );
        }
      });
      await setCollectionVisibility(listId, null);
    } catch (e, st) {
      debugPrint('reorderCustomListMovies failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> setCollectionVisibility(
    int listId,
    bool? explicitIsPublic,
  ) async {
    final user = _ref.currentUser;
    if (user == null) return;

    final list = await (_db.select(
      _db.customLists,
    )..where((t) => t.id.equals(listId))).getSingleOrNull();
    if (list == null) return;

    final nextIsPublic = explicitIsPublic ?? list.isPublic;
    if (explicitIsPublic != null && list.isPublic != explicitIsPublic) {
      await (_db.update(_db.customLists)..where((t) => t.id.equals(listId)))
          .write(CustomListsCompanion(isPublic: Value(explicitIsPublic)));
    }

    if (!nextIsPublic) {
      await _deleteSharedCollectionMirror(listId);
      return;
    }

    final query = _db.select(_db.customListMovies).join([
      innerJoin(
        _db.movies,
        _db.movies.tmdbId.equalsExp(_db.customListMovies.movieId) &
            _db.movies.isTv.equalsExp(_db.customListMovies.isTv),
      ),
    ])..where(_db.customListMovies.listId.equals(listId));
    query.orderBy([OrderingTerm.asc(_db.customListMovies.rankingOrder)]);

    final rows = await query.get();
    final movieMaps = rows.map((row) {
      final movie = row.readTable(_db.movies);
      return {
        'tmdbId': movie.tmdbId,
        'isTv': movie.isTv,
        'title': movie.title,
        'posterPath': movie.posterPath,
        'releaseYear': movie.releaseYear,
      };
    }).toList();

    final identity = resolveUserIdentity(_ref.read(userModelProvider), user);
    await _ref
        .read(firestoreProvider)
        .collection('shared_collections')
        .doc('${user.uid}_$listId')
        .set({
          'ownerId': user.uid,
          'ownerUsername': identity.username,
          'ownerAvatarUrl': identity.avatarUrl,
          'listId': listId,
          'name': list.name,
          'description': list.description ?? '',
          'movies': movieMaps,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _deleteSharedCollectionMirror(int listId) async {
    final user = _ref.currentUser;
    if (user == null) return;
    try {
      await _ref
          .read(firestoreProvider)
          .collection('shared_collections')
          .doc('${user.uid}_$listId')
          .delete();
    } catch (e) {
      debugPrint('failed to delete shared collection mirror $listId: $e');
    }
  }
}

class WebCustomListRepository implements CustomListRepository {
  WebCustomListRepository(this._ref);
  final Ref _ref;

  Future<void> _persist() => WebLocalStore.save(
    movies: _ref.read(webMoviesProvider),
    customLists: _ref.read(webCustomListsProvider),
    customListMovies: _ref.read(webCustomListMoviesProvider),
  );

  @override
  Future<void> createCustomList(
    String name,
    String? description, {
    DateTime? targetDate,
  }) async {
    final notifier = _ref.read(webCustomListsProvider.notifier);
    final map = _ref.read(webCustomListsProvider);
    final newMap = Map<int, CustomList>.from(map);
    final nextId = newMap.isEmpty
        ? 1
        : newMap.keys.reduce((a, b) => a > b ? a : b) + 1;
    newMap[nextId] = CustomList(
      id: nextId,
      name: name,
      description: description,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      isPublic: false,
    );
    notifier.state = newMap;
    await _persist();
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
        targetDate: clearTargetDate
            ? null
            : (targetDate ?? existing.targetDate),
        createdAt: existing.createdAt,
        isPublic: existing.isPublic,
      );
      notifier.state = newMap;
      await setCollectionVisibility(id, null);
    }
  }

  @override
  Future<void> deleteCustomList(int id) async {
    final listNotifier = _ref.read(webCustomListsProvider.notifier);
    final map = _ref.read(webCustomListsProvider);
    final list = map[id];
    if (list != null && list.isPublic) {
      await _deleteSharedCollectionMirror(id);
    }
    final newMap = Map<int, CustomList>.from(map)..remove(id);
    listNotifier.state = newMap;

    final moviesNotifier = _ref.read(webCustomListMoviesProvider.notifier);
    final movies = _ref.read(webCustomListMoviesProvider);
    moviesNotifier.state = movies.where((r) => r.listId != id).toList();
    await _persist();
  }

  @override
  Future<void> addMovieToCustomList(int listId, Movie movieData) async {
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
    if (!currentList.any(
      (r) =>
          r.listId == listId &&
          r.movieId == movieData.tmdbId &&
          r.isTv == movieData.isTv,
    )) {
      final listMovies = currentList.where((r) => r.listId == listId);
      final maxOrder = listMovies.isEmpty
          ? 0
          : listMovies
                .map((r) => r.rankingOrder ?? 0)
                .reduce((a, b) => a > b ? a : b);

      notifier.state = [
        ...currentList,
        CustomListMovie(
          listId: listId,
          movieId: movieData.tmdbId,
          isTv: movieData.isTv,
          rankingOrder: maxOrder + 1,
          addedAt: DateTime.now(),
        ),
      ];
    }
    await setCollectionVisibility(listId, null);
  }

  @override
  Future<void> removeMovieFromCustomList(
    int listId,
    int tmdbId,
    bool isTv,
  ) async {
    final notifier = _ref.read(webCustomListMoviesProvider.notifier);
    final currentList = _ref.read(webCustomListMoviesProvider);
    notifier.state = currentList
        .where(
          (r) => !(r.listId == listId && r.movieId == tmdbId && r.isTv == isTv),
        )
        .toList();
    await setCollectionVisibility(listId, null);
  }

  @override
  Future<void> reorderCustomListMovies(
    int listId,
    Map<MovieKey, int> rankings,
  ) async {
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
    await setCollectionVisibility(listId, null);
  }

  @override
  Future<void> setCollectionVisibility(
    int listId,
    bool? explicitIsPublic,
  ) async {
    final lists = _ref.read(webCustomListsProvider);
    final list = lists[listId];
    if (list == null) return;

    final nextIsPublic = explicitIsPublic ?? list.isPublic;
    if (explicitIsPublic != null && list.isPublic != explicitIsPublic) {
      final updated = Map<int, CustomList>.from(lists);
      updated[listId] = CustomList(
        id: list.id,
        name: list.name,
        description: list.description,
        targetDate: list.targetDate,
        createdAt: list.createdAt,
        isPublic: explicitIsPublic,
      );
      _ref.read(webCustomListsProvider.notifier).state = updated;
    }
    await _persist();

    final user = _ref.currentUser;
    if (user == null) return;
    if (!nextIsPublic) {
      await _deleteSharedCollectionMirror(listId);
      return;
    }

    final relations =
        _ref
            .read(webCustomListMoviesProvider)
            .where((relation) => relation.listId == listId)
            .toList()
          ..sort(
            (a, b) => (a.rankingOrder ?? 0).compareTo(b.rankingOrder ?? 0),
          );
    final movies = _ref.read(webMoviesProvider);
    final movieMaps = relations.map((relation) {
      final movie = movies[(tmdbId: relation.movieId, isTv: relation.isTv)];
      return {
        'tmdbId': relation.movieId,
        'isTv': relation.isTv,
        'title': movie?.title ?? '',
        'posterPath': movie?.posterPath,
        'releaseYear': movie?.releaseYear,
      };
    }).toList();

    final currentList = _ref.read(webCustomListsProvider)[listId]!;
    final identity = resolveUserIdentity(_ref.read(userModelProvider), user);
    await _ref
        .read(firestoreProvider)
        .collection('shared_collections')
        .doc('${user.uid}_$listId')
        .set({
          'ownerId': user.uid,
          'ownerUsername': identity.username,
          'ownerAvatarUrl': identity.avatarUrl,
          'listId': listId,
          'name': currentList.name,
          'description': currentList.description ?? '',
          'movies': movieMaps,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _deleteSharedCollectionMirror(int listId) async {
    final user = _ref.currentUser;
    if (user == null) return;
    try {
      await _ref
          .read(firestoreProvider)
          .collection('shared_collections')
          .doc('${user.uid}_$listId')
          .delete();
    } catch (error) {
      debugPrint(
        'failed to delete web shared collection mirror $listId: $error',
      );
      rethrow;
    }
  }
}
