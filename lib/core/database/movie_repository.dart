import 'dart:async';
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
  Future<void> deleteWatchRecordsByIds(List<int> ids);
  // Guest/offline-only variants of deleteWatchRecord/updateWatchRecord
  // (database_provider.dart) — those already handle the signed-in path via
  // Firestore themselves (identical on web and native, since Firestore
  // access doesn't depend on platform); this is only reached when
  // `user == null`, so it's purely the local-storage fallback.
  Future<void> deleteWatchRecordLocal(WatchRecord record);
  Future<void> updateWatchRecordLocal(
    WatchRecord record, {
    DateTime? watchDate,
    int? episodeCount,
    bool? isPublic,
  });
  // Sets/clears a movie's personal favorite ranking (rank_dialog.dart).
  // Native also upserts the Movie row itself (ensuring it exists locally,
  // same createdAt-preserving Companion pattern as addMovieToCustomList);
  // web only needs the settings map entry.
  Future<void> updatePersonalRankingLocal({
    required int tmdbId,
    required bool isTv,
    required Map<String, dynamic> movieData,
    required UserMovieSetting? settings,
    required int? rank,
  });
  // Whole-database JSON backup/restore (Settings → "Yedekleme"). Kept as one
  // pair of methods rather than broken into per-table CRUD calls: native
  // restore clears and repopulates all 5 tables inside a single Drift
  // transaction, which per-method delegation would fragment.
  Future<Map<String, dynamic>> exportBackupData();
  Future<void> importBackupData(Map<String, dynamic> json);
  // Guest/offline-only fallback for writeEpisodeProgressSettings
  // (episode_logging.dart) — signed-in users go through Firestore there
  // directly (identical on web and native), so this is only reached when
  // `user == null`.
  Future<void> writeEpisodeProgressSettingsLocal({
    required int tmdbId,
    required bool isTv,
    required UserMovieSetting setting,
    required int? lastWatchedEpisode,
    required bool isActivelyWatching,
  });
  // Turns a collection's "Koleksiyon Paylaş" live sync on/off. When turned
  // on, mirrors the collection's current contents to Firestore's
  // shared_collections/{ownerId_listId} immediately; when turned off,
  // deletes that mirror doc (the local collection itself is untouched
  // either way — this only controls the Community feed's visibility).
  Future<void> setCollectionVisibility(int listId, bool isPublic);

  /// Upserts the local metadata row for a TMDb payload so the title stays
  /// openable offline (see movie_detail_provider.dart's fallback) and so
  /// collections/rankings referencing it can render a poster and name.
  ///
  /// Every caller used to inline its own `db.into(db.movies)` block — one of
  /// them (MovieDetailScreen's watchlist toggle) without a `kIsWeb` guard, so
  /// on web it threw *after* the Firestore write had already succeeded: the
  /// user saw "güncellenemedi" for an action that worked, and the release
  /// reminder scheduled further down the same `try` never ran. Routing it
  /// through the repository means the web implementation writes to the
  /// in-memory map instead of a database that doesn't exist there.
  Future<void> cacheMovieMetadata({
    required int tmdbId,
    required bool isTv,
    required Map<String, dynamic> movieData,
  });
}

/// Builds a [Movie] row from a raw TMDb detail payload.
///
/// Shared by every `cacheMovieMetadata` implementation and by
/// `updatePersonalRankingLocal`, which previously each re-derived
/// director/actors/genres/year from the same JSON shape with slightly
/// different null handling.
Movie movieFromTmdbPayload({
  required int tmdbId,
  required bool isTv,
  required Map<String, dynamic> movieData,
  DateTime? createdAt,
}) {
  final crew = movieData['credits']?['crew'] as List<dynamic>?;
  final director = crew
      ?.where((e) => e is Map && e['job'] == 'Director')
      .firstOrNull?['name'] as String?;

  final cast = movieData['credits']?['cast'] as List<dynamic>?;
  final actors = cast
      ?.take(5)
      .map((e) => e is Map ? (e['name'] ?? '') : '')
      .where((s) => s.toString().isNotEmpty)
      .join(', ');

  final genres = (movieData['genres'] as List<dynamic>?)
      ?.map((e) => e is Map ? (e['name'] ?? '') : '')
      .where((s) => s.toString().isNotEmpty)
      .join(', ');

  // TMDb names the date field differently for movies and shows, and the
  // detail normalisation in TmdbService may have already copied one to the
  // other — accept whichever is present.
  final releaseDateStr =
      (movieData['release_date'] ?? movieData['first_air_date'] ?? '').toString();
  final releaseYear = DateTime.tryParse(releaseDateStr)?.year ??
      int.tryParse(releaseDateStr.split('-').first);

  return Movie(
    tmdbId: tmdbId,
    title: (movieData['title'] ?? movieData['name'] ?? 'Bilinmeyen Yapım') as String,
    originalTitle:
        (movieData['original_title'] ?? movieData['original_name']) as String?,
    posterPath: movieData['poster_path'] as String?,
    backdropPath: movieData['backdrop_path'] as String?,
    releaseYear: releaseYear,
    runtime: (movieData['runtime'] as num?)?.toInt(),
    genres: genres,
    director: director,
    actors: actors,
    overview: movieData['overview'] as String?,
    isTv: isTv,
    createdAt: createdAt ?? DateTime.now(),
    totalEpisodes: (movieData['number_of_episodes'] as num?)?.toInt(),
  );
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
    final user = _ref.currentUser;
    if (user == null) return;

    final list = await (_db.select(_db.customLists)..where((t) => t.id.equals(listId))).getSingleOrNull();
    if (list == null) return;

    final movieRows = await (_db.select(_db.customListMovies)..where((t) => t.listId.equals(listId))).get();

    // Fetch all referenced movies in one query instead of one per row.
    // tmdbId.isIn(...) alone can return both a movie and a TV show sharing
    // the same numeric tmdbId, so the (tmdbId, isTv) match still happens in
    // Dart to keep the two correctly separated (see v8 migration).
    final movieIds = movieRows.map((r) => r.movieId).toSet();
    final movieRowsById = movieIds.isEmpty
        ? const <MovieKey, Movie>{}
        : {
            for (final m in await (_db.select(_db.movies)..where((t) => t.tmdbId.isIn(movieIds))).get())
              (tmdbId: m.tmdbId, isTv: m.isTv): m,
          };

    final movies = <Map<String, dynamic>>[];
    for (final row in movieRows) {
      final movie = movieRowsById[(tmdbId: row.movieId, isTv: row.isTv)];
      if (movie == null) continue;
      movies.add({
        'tmdbId': movie.tmdbId,
        'isTv': movie.isTv,
        'title': movie.title,
        'posterPath': movie.posterPath,
        'rankingOrder': row.rankingOrder ?? 0,
      });
    }
    movies.sort((a, b) => ((a['rankingOrder'] as num?)?.toInt() ?? 0).compareTo((b['rankingOrder'] as num?)?.toInt() ?? 0));

    final identity = resolveUserIdentity(_ref.read(userModelProvider), user);

    unawaited(_ref.read(firestoreProvider).collection('shared_collections').doc('${user.uid}_$listId').set({
      'ownerId': user.uid,
      'ownerUsername': identity.username,
      'ownerAvatarUrl': identity.avatarUrl,
      'name': list.name,
      'description': list.description,
      'movies': movies,
      'updatedAt': FieldValue.serverTimestamp(),
    }));
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
      final user = _ref.currentUser;
      if (user != null) {
        unawaited(_ref.read(firestoreProvider).collection('shared_collections').doc('${user.uid}_$listId').delete());
      }
    }
  }

  @override
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) async {
    try {
      final user = _ref.currentUser;
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

  @override
  Future<void> deleteWatchRecordsByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    await (_db.delete(_db.watchRecords)..where((t) => t.id.isIn(ids))).go();
  }

  @override
  Future<void> deleteWatchRecordLocal(WatchRecord record) async {
    await (_db.delete(_db.watchRecords)..where((t) => t.id.equals(record.id))).go();

    // Recalculate Drift settings progress
    final remainingRecords = await (_db.select(_db.watchRecords)
          ..where((t) => t.movieId.equals(record.movieId) & t.isTv.equals(record.isTv))
          ..orderBy([(t) => OrderingTerm.desc(t.watchDate)]))
        .get();

    final settingsQuery = _db.select(_db.userMovieSettings)
      ..where((t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv));
    final existingSetting = await settingsQuery.getSingleOrNull();

    if (existingSetting == null) return;

    if (remainingRecords.isEmpty) {
      await _db.into(_db.userMovieSettings).insertOnConflictUpdate(
            existingSetting.copyWith(
              isActivelyWatching: false,
              lastWatchedEpisode: const Value(null),
            ),
          );
    } else {
      final latestRecord = remainingRecords.first;
      final latestWatchNumber = latestRecord.watchNumber;

      final currentEpisodeProgress = remainingRecords
          .where((r) => r.watchNumber == latestWatchNumber)
          .fold<int>(0, (acc, r) => acc + r.episodeCount);

      final movieQuery = _db.select(_db.movies)
        ..where((t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv));
      final movie = await movieQuery.getSingleOrNull();
      final totalEpisodes = movie?.totalEpisodes;

      final newIsActivelyWatching = totalEpisodes == null || currentEpisodeProgress < totalEpisodes;

      await _db.into(_db.userMovieSettings).insertOnConflictUpdate(
            existingSetting.copyWith(
              isActivelyWatching: newIsActivelyWatching,
              lastWatchedEpisode: Value(currentEpisodeProgress),
            ),
          );
    }
  }

  @override
  Future<void> updateWatchRecordLocal(
    WatchRecord record, {
    DateTime? watchDate,
    int? episodeCount,
    bool? isPublic,
  }) async {
    await (_db.update(_db.watchRecords)..where((t) => t.id.equals(record.id))).write(
      WatchRecordsCompanion(
        watchDate: watchDate != null ? Value(watchDate) : const Value.absent(),
        episodeCount: episodeCount != null ? Value(episodeCount) : const Value.absent(),
        isPublic: isPublic != null ? Value(isPublic) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> cacheMovieMetadata({
    required int tmdbId,
    required bool isTv,
    required Map<String, dynamic> movieData,
  }) async {
    final movie = movieFromTmdbPayload(tmdbId: tmdbId, isTv: isTv, movieData: movieData);
    // createdAt is intentionally left absent so re-caching an already-known
    // title doesn't bump its original "added at" timestamp to now (which the
    // Home screen's "Son Eklediklerim" ordering depends on).
    await _db.into(_db.movies).insertOnConflictUpdate(
          MoviesCompanion.insert(
            tmdbId: movie.tmdbId,
            title: movie.title,
            originalTitle: Value(movie.originalTitle),
            posterPath: Value(movie.posterPath),
            backdropPath: Value(movie.backdropPath),
            releaseYear: Value(movie.releaseYear),
            runtime: Value(movie.runtime),
            genres: Value(movie.genres),
            director: Value(movie.director),
            actors: Value(movie.actors),
            overview: Value(movie.overview),
            isTv: Value(movie.isTv),
            totalEpisodes: Value(movie.totalEpisodes),
          ),
        );
  }

  @override
  Future<void> updatePersonalRankingLocal({
    required int tmdbId,
    required bool isTv,
    required Map<String, dynamic> movieData,
    required UserMovieSetting? settings,
    required int? rank,
  }) async {
    try {
      await cacheMovieMetadata(tmdbId: tmdbId, isTv: isTv, movieData: movieData);

      await _db.into(_db.userMovieSettings).insertOnConflictUpdate(
            UserMovieSetting(
              tmdbId: tmdbId,
              isTv: isTv,
              isFavorite: settings?.isFavorite ?? false,
              isReWatchList: settings?.isReWatchList ?? false,
              personalNotes: settings?.personalNotes,
              personalTags: settings?.personalTags,
              personalRanking: rank,
              updatedAt: DateTime.now(),
              isActivelyWatching: settings?.isActivelyWatching ?? false,
              lastWatchedEpisode: settings?.lastWatchedEpisode,
            ),
          );
    } catch (e, st) {
      debugPrint('updatePersonalRankingLocal failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> exportBackupData() async {
    final movies = await _db.select(_db.movies).get();
    final records = await _db.select(_db.watchRecords).get();
    final settings = await _db.select(_db.userMovieSettings).get();
    final customLists = await _db.select(_db.customLists).get();
    final customListMovies = await _db.select(_db.customListMovies).get();

    return {
      'version': 1,
      'movies': movies.map((m) => m.toJson()).toList(),
      'watch_records': records.map((r) => r.toJson()).toList(),
      'user_movie_settings': settings.map((s) => s.toJson()).toList(),
      'custom_lists': customLists.map((l) => l.toJson()).toList(),
      'custom_list_movies': customListMovies.map((m) => m.toJson()).toList(),
    };
  }

  @override
  Future<void> importBackupData(Map<String, dynamic> json) async {
    final moviesList = json['movies'] as List<dynamic>? ?? [];
    final recordsList = json['watch_records'] as List<dynamic>? ?? [];
    final settingsList = json['user_movie_settings'] as List<dynamic>? ?? [];
    final customListsList = json['custom_lists'] as List<dynamic>? ?? [];
    final customListMoviesList = json['custom_list_movies'] as List<dynamic>? ?? [];

    await _db.transaction(() async {
      // Clear tables first (respect foreign keys: relation tables first)
      await _db.delete(_db.customListMovies).go();
      await _db.delete(_db.customLists).go();
      await _db.delete(_db.watchRecords).go();
      await _db.delete(_db.userMovieSettings).go();
      await _db.delete(_db.movies).go();

      for (final x in moviesList) {
        await _db.into(_db.movies).insertOnConflictUpdate(Movie.fromJson(x as Map<String, dynamic>));
      }
      for (final x in settingsList) {
        await _db.into(_db.userMovieSettings).insertOnConflictUpdate(UserMovieSetting.fromJson(x as Map<String, dynamic>));
      }
      for (final x in recordsList) {
        await _db.into(_db.watchRecords).insertOnConflictUpdate(WatchRecord.fromJson(x as Map<String, dynamic>));
      }
      for (final x in customListsList) {
        await _db.into(_db.customLists).insertOnConflictUpdate(CustomList.fromJson(x as Map<String, dynamic>));
      }
      for (final x in customListMoviesList) {
        await _db.into(_db.customListMovies).insertOnConflictUpdate(CustomListMovie.fromJson(x as Map<String, dynamic>));
      }
    });
  }

  @override
  Future<void> writeEpisodeProgressSettingsLocal({
    required int tmdbId,
    required bool isTv,
    required UserMovieSetting setting,
    required int? lastWatchedEpisode,
    required bool isActivelyWatching,
  }) async {
    await _db.into(_db.userMovieSettings).insertOnConflictUpdate(
          UserMovieSetting(
            tmdbId: tmdbId,
            isTv: isTv,
            isFavorite: setting.isFavorite,
            isReWatchList: setting.isReWatchList,
            personalRanking: setting.personalRanking,
            personalNotes: setting.personalNotes,
            personalTags: setting.personalTags,
            updatedAt: DateTime.now(),
            isActivelyWatching: isActivelyWatching,
            lastWatchedEpisode: lastWatchedEpisode,
            lastEpisodeProgressAt: DateTime.now(),
          ),
        );
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
      final user = _ref.currentUser;
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

  @override
  Future<void> deleteWatchRecordsByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    final idsToDelete = ids.toSet();
    final notifier = _ref.read(webWatchRecordsProvider.notifier);
    final currentList = _ref.read(webWatchRecordsProvider);
    notifier.state = currentList.where((r) => !idsToDelete.contains(r.id)).toList();
  }

  @override
  Future<void> deleteWatchRecordLocal(WatchRecord record) async {
    final notifier = _ref.read(webWatchRecordsProvider.notifier);
    final currentList = _ref.read(webWatchRecordsProvider);
    notifier.state = currentList.where((r) => r.id != record.id).toList();
  }

  @override
  Future<void> updateWatchRecordLocal(
    WatchRecord record, {
    DateTime? watchDate,
    int? episodeCount,
    bool? isPublic,
  }) async {
    final notifier = _ref.read(webWatchRecordsProvider.notifier);
    final currentList = _ref.read(webWatchRecordsProvider);
    notifier.state = currentList.map((r) {
      if (r.id != record.id) return r;
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
        isPublic: isPublic ?? r.isPublic,
      );
    }).toList();
  }

  // Web has no SQLite database, so "caching metadata" means seeding the
  // in-memory movies map that webMoviesProvider serves — which is what the
  // offline detail-screen fallback and the collections UI read from.
  @override
  Future<void> cacheMovieMetadata({
    required int tmdbId,
    required bool isTv,
    required Map<String, dynamic> movieData,
  }) async {
    final key = (tmdbId: tmdbId, isTv: isTv);
    final current = _ref.read(webMoviesProvider);
    final updated = Map<MovieKey, Movie>.from(current);
    updated[key] = movieFromTmdbPayload(
      tmdbId: tmdbId,
      isTv: isTv,
      movieData: movieData,
      // Preserve the original "added at" for the same reason the native path
      // omits createdAt on conflict.
      createdAt: current[key]?.createdAt,
    );
    _ref.read(webMoviesProvider.notifier).state = updated;
  }

  @override
  Future<void> updatePersonalRankingLocal({
    required int tmdbId,
    required bool isTv,
    required Map<String, dynamic> movieData,
    required UserMovieSetting? settings,
    required int? rank,
  }) async {
    await cacheMovieMetadata(tmdbId: tmdbId, isTv: isTv, movieData: movieData);
    final notifier = _ref.read(webMovieSettingsProvider.notifier);
    final currentMap = _ref.read(webMovieSettingsProvider);
    final updatedMap = Map<MovieKey, UserMovieSetting>.from(currentMap);
    updatedMap[(tmdbId: tmdbId, isTv: isTv)] = UserMovieSetting(
      tmdbId: tmdbId,
      isTv: isTv,
      isFavorite: settings?.isFavorite ?? false,
      isReWatchList: settings?.isReWatchList ?? false,
      personalNotes: settings?.personalNotes,
      personalTags: settings?.personalTags,
      personalRanking: rank,
      updatedAt: DateTime.now(),
      isActivelyWatching: settings?.isActivelyWatching ?? false,
      lastWatchedEpisode: settings?.lastWatchedEpisode,
    );
    notifier.state = updatedMap;
  }

  @override
  Future<Map<String, dynamic>> exportBackupData() async {
    final records = _ref.read(webWatchRecordsProvider);
    final settings = _ref.read(webMovieSettingsProvider);
    final movies = _ref.read(webMoviesProvider);
    final customLists = _ref.read(webCustomListsProvider);
    final customListMovies = _ref.read(webCustomListMoviesProvider);

    return {
      'version': 1,
      'movies': movies.values.map((m) => {
        'tmdbId': m.tmdbId,
        'isTv': m.isTv,
        'title': m.title,
        'originalTitle': m.originalTitle,
        'posterPath': m.posterPath,
        'backdropPath': m.backdropPath,
        'releaseYear': m.releaseYear,
        'runtime': m.runtime,
        'genres': m.genres,
        'director': m.director,
        'actors': m.actors,
        'overview': m.overview,
        'createdAt': m.createdAt.toIso8601String(),
        'totalEpisodes': m.totalEpisodes,
      }).toList(),
      'watch_records': records.map((r) => {
        'id': r.id,
        'movieId': r.movieId,
        'isTv': r.isTv,
        'watchDate': r.watchDate.toIso8601String(),
        'watchPlace': r.watchPlace,
        'watchCompanion': r.watchCompanion,
        'rating': r.rating,
        'mood': r.mood,
        'notes': r.notes,
        'watchNumber': r.watchNumber,
        'createdAt': r.createdAt.toIso8601String(),
        'episodeCount': r.episodeCount,
        'isPublic': r.isPublic,
      }).toList(),
      'user_movie_settings': settings.values.map((s) => {
        'tmdbId': s.tmdbId,
        'isTv': s.isTv,
        'isFavorite': s.isFavorite,
        'isReWatchList': s.isReWatchList,
        'personalNotes': s.personalNotes,
        'personalTags': s.personalTags,
        'updatedAt': s.updatedAt.toIso8601String(),
        'isActivelyWatching': s.isActivelyWatching,
        'lastWatchedEpisode': s.lastWatchedEpisode,
      }).toList(),
      'custom_lists': customLists.values.map((l) => {
        'id': l.id,
        'name': l.name,
        'description': l.description,
        'targetDate': l.targetDate?.toIso8601String(),
        'createdAt': l.createdAt.toIso8601String(),
        'isPublic': l.isPublic,
      }).toList(),
      'custom_list_movies': customListMovies.map((m) => {
        'listId': m.listId,
        'movieId': m.movieId,
        'isTv': m.isTv,
        'rankingOrder': m.rankingOrder,
        'addedAt': m.addedAt.toIso8601String(),
      }).toList(),
    };
  }

  @override
  Future<void> importBackupData(Map<String, dynamic> json) async {
    final moviesList = json['movies'] as List<dynamic>? ?? [];
    final recordsList = json['watch_records'] as List<dynamic>? ?? [];
    final settingsList = json['user_movie_settings'] as List<dynamic>? ?? [];
    final customListsList = json['custom_lists'] as List<dynamic>? ?? [];
    final customListMoviesList = json['custom_list_movies'] as List<dynamic>? ?? [];

    final watchRecords = recordsList.map((x) {
      final map = x as Map<String, dynamic>;
      return WatchRecord(
        id: (map['id'] as num).toInt(),
        movieId: (map['movieId'] as num).toInt(),
        // Absent in backups made before the movie/TV id-collision fix.
        isTv: map['isTv'] == true || map['isTv'] == 1,
        watchDate: DateTime.parse(map['watchDate'] as String),
        watchPlace: map['watchPlace'] as String?,
        watchCompanion: map['watchCompanion'] as String?,
        rating: (map['rating'] as num).toDouble(),
        mood: map['mood'] as String?,
        notes: map['notes'] as String?,
        watchNumber: (map['watchNumber'] as num).toInt(),
        createdAt: DateTime.parse(map['createdAt'] as String),
        // Absent in backups made before episode-count tracking existed.
        episodeCount: (map['episodeCount'] as num?)?.toInt() ?? 1,
        // Absent in backups made before the community privacy toggle
        // existed — treat as private, consistent with the opt-in default.
        isPublic: map['isPublic'] == true || map['isPublic'] == 1,
      );
    }).toList();

    final movieSettings = <MovieKey, UserMovieSetting>{};
    for (final x in settingsList) {
      final map = x as Map<String, dynamic>;
      final id = (map['tmdbId'] as num).toInt();
      final settingIsTv = map['isTv'] == true || map['isTv'] == 1;
      movieSettings[(tmdbId: id, isTv: settingIsTv)] = UserMovieSetting(
        tmdbId: id,
        isTv: settingIsTv,
        isFavorite: map['isFavorite'] == true || map['isFavorite'] == 1,
        isReWatchList: map['isReWatchList'] == true || map['isReWatchList'] == 1,
        personalNotes: map['personalNotes'] as String?,
        personalTags: map['personalTags'] as String?,
        updatedAt: DateTime.parse(map['updatedAt'] as String),
        // Absent in backups made before "Aktif İzliyorum" tracking existed.
        isActivelyWatching: map['isActivelyWatching'] == true || map['isActivelyWatching'] == 1,
        lastWatchedEpisode: (map['lastWatchedEpisode'] as num?)?.toInt(),
      );
    }

    final movies = <MovieKey, Movie>{};
    for (final x in moviesList) {
      final map = x as Map<String, dynamic>;
      final id = (map['tmdbId'] as num).toInt();
      final movieIsTv = map['isTv'] == true || map['isTv'] == 1;
      movies[(tmdbId: id, isTv: movieIsTv)] = Movie(
        tmdbId: id,
        title: map['title'] as String,
        originalTitle: map['originalTitle'] as String?,
        posterPath: map['posterPath'] as String?,
        backdropPath: map['backdropPath'] as String?,
        releaseYear: (map['releaseYear'] as num?)?.toInt(),
        runtime: (map['runtime'] as num?)?.toInt(),
        genres: map['genres'] as String?,
        director: map['director'] as String?,
        actors: map['actors'] as String?,
        overview: map['overview'] as String?,
        isTv: movieIsTv,
        createdAt: DateTime.parse(map['createdAt'] as String),
        totalEpisodes: (map['totalEpisodes'] as num?)?.toInt(),
      );
    }

    final customLists = <int, CustomList>{};
    for (final x in customListsList) {
      final map = x as Map<String, dynamic>;
      final id = (map['id'] as num).toInt();
      customLists[id] = CustomList(
        id: id,
        name: map['name'] as String,
        description: map['description'] as String?,
        targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate'] as String) : null,
        createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
        isPublic: map['isPublic'] == true || map['isPublic'] == 1,
      );
    }

    final customListMovies = customListMoviesList.map((x) {
      final map = x as Map<String, dynamic>;
      return CustomListMovie(
        listId: (map['listId'] as num).toInt(),
        movieId: (map['movieId'] as num).toInt(),
        isTv: map['isTv'] == true || map['isTv'] == 1,
        rankingOrder: (map['rankingOrder'] as num?)?.toInt(),
        addedAt: map['addedAt'] != null ? DateTime.parse(map['addedAt'] as String) : DateTime.now(),
      );
    }).toList();

    _ref.read(webWatchRecordsProvider.notifier).state = watchRecords;
    _ref.read(webMovieSettingsProvider.notifier).state = movieSettings;
    _ref.read(webMoviesProvider.notifier).state = movies;
    _ref.read(webCustomListsProvider.notifier).state = customLists;
    _ref.read(webCustomListMoviesProvider.notifier).state = customListMovies;
  }

  @override
  Future<void> writeEpisodeProgressSettingsLocal({
    required int tmdbId,
    required bool isTv,
    required UserMovieSetting setting,
    required int? lastWatchedEpisode,
    required bool isActivelyWatching,
  }) async {
    final key = (tmdbId: tmdbId, isTv: isTv);
    final currentSettings = _ref.read(webMovieSettingsProvider);
    final updatedSettings = Map<MovieKey, UserMovieSetting>.from(currentSettings);
    updatedSettings[key] = UserMovieSetting(
      tmdbId: tmdbId,
      isTv: isTv,
      isFavorite: setting.isFavorite,
      isReWatchList: setting.isReWatchList,
      personalRanking: setting.personalRanking,
      personalNotes: setting.personalNotes,
      personalTags: setting.personalTags,
      updatedAt: DateTime.now(),
      isActivelyWatching: isActivelyWatching,
      lastWatchedEpisode: lastWatchedEpisode,
      lastEpisodeProgressAt: DateTime.now(),
    );
    _ref.read(webMovieSettingsProvider.notifier).state = updatedSettings;
  }
}
