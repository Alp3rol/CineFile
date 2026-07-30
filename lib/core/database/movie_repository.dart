import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_database.dart';
import 'database_provider.dart';
import '../constants/tmdb_genres.dart';
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

/// Marker key set on the "nothing could be loaded" payload
/// movie_detail_provider.dart falls back to. Its title is a localized string
/// and its runtime is invented, so it must never reach the database — see
/// [cacheMovieMetadata].
const String kOfflinePlaceholderKey = '__cinefile_offline_placeholder';

bool isOfflinePlaceholderPayload(Map<String, dynamic> movieData) =>
    movieData[kOfflinePlaceholderKey] == true;

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

  // The names above are whatever language TMDb was asked for; the ids are
  // what statistics and filters compare on. See Movies.genreIds.
  final genreIds = formatGenreIds(genreIdsFromTmdbPayload(movieData));

  // TMDb names the date field differently for movies and shows, and the
  // detail normalisation in TmdbService may have already copied one to the
  // other — accept whichever is present.
  final releaseDateStr =
      (movieData['release_date'] ?? movieData['first_air_date'] ?? '').toString();
  final releaseYear = DateTime.tryParse(releaseDateStr)?.year ??
      int.tryParse(releaseDateStr.split('-').first);

  return Movie(
    tmdbId: tmdbId,
    // Falls through to the original title rather than a localized "Unknown
    // Title" placeholder: whatever lands here is written to the database as
    // the title, and a placeholder in one language becomes wrong data the
    // moment the user switches — the same leak the director field had. An
    // empty string is honest, and display sites already substitute their own
    // placeholder for it.
    title: (movieData['title'] ??
            movieData['name'] ??
            movieData['original_title'] ??
            movieData['original_name'] ??
            '') as String,
    originalTitle:
        (movieData['original_title'] ?? movieData['original_name']) as String?,
    posterPath: movieData['poster_path'] as String?,
    backdropPath: movieData['backdrop_path'] as String?,
    releaseYear: releaseYear,
    runtime: (movieData['runtime'] as num?)?.toInt(),
    genres: genres,
    genreIds: genreIds,
    director: director,
    actors: actors,
    overview: movieData['overview'] as String?,
    isTv: isTv,
    createdAt: createdAt ?? DateTime.now(),
    totalEpisodes: (movieData['number_of_episodes'] as num?)?.toInt(),
  );
}

// --- Backup compatibility ---------------------------------------------------
//
// Drift's generated `fromJson` is strict: a field that is absent reaches a
// non-nullable constructor argument as null and throws. Backups predate
// several columns (isTv before the movie/TV id-collision fix, episodeCount
// before per-record episode counts, isPublic before the community toggle), so
// every one of them is defaulted here before the row is built.
//
// Dates need no special handling — Drift's default serializer already accepts
// both the millisecond ints it writes and the ISO strings older web backups
// contain.

bool _backupBool(Object? value, {bool orElse = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return orElse;
}

Map<String, dynamic> _movieBackupJson(Map<String, dynamic> json) => {
      ...json,
      'isTv': _backupBool(json['isTv']),
    };

Map<String, dynamic> _watchRecordBackupJson(Map<String, dynamic> json) => {
      ...json,
      'isTv': _backupBool(json['isTv']),
      'isPublic': _backupBool(json['isPublic']),
      'episodeCount': (json['episodeCount'] as num?)?.toInt() ?? 1,
    };

Map<String, dynamic> _userMovieSettingBackupJson(Map<String, dynamic> json) => {
      ...json,
      'isTv': _backupBool(json['isTv']),
      'isFavorite': _backupBool(json['isFavorite']),
      'isReWatchList': _backupBool(json['isReWatchList']),
      'isActivelyWatching': _backupBool(json['isActivelyWatching']),
    };

Map<String, dynamic> _customListBackupJson(Map<String, dynamic> json) => {
      ...json,
      'isPublic': _backupBool(json['isPublic']),
      'createdAt': json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    };

Map<String, dynamic> _customListMovieBackupJson(Map<String, dynamic> json) => {
      ...json,
      'isTv': _backupBool(json['isTv']),
      'addedAt': json['addedAt'] ?? DateTime.now().millisecondsSinceEpoch,
    };

/// [Movie.fromJson] plus recovery of [Movie.genreIds] for backups written
/// before schema 13, which only carry localized genre names. Without this a
/// restored library would be invisible to every genre statistic until each
/// title happened to be opened again.
Movie _movieFromBackupJson(Map<String, dynamic> json) {
  final movie = Movie.fromJson(_movieBackupJson(json));
  if (movie.genreIds != null) return movie;

  final recovered = formatGenreIds(genreIdsFromLegacyNames(movie.genres));
  return recovered == null ? movie : movie.copyWith(genreIds: Value(recovered));
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
    // Tear the Firestore mirror down BEFORE the local row disappears.
    // `isPublic` lives on that row, so once it is gone nothing is left to tell
    // us the collection had a mirror — and shared_collections/{uid}_{id} would
    // stay readable by every signed-in user forever, exposing the titles, name
    // and description of a collection its owner believes they deleted. The
    // 'collection' community post pointing at it would keep rendering too.
    //
    // Reading the row first keeps the (default, common) private case free of
    // any network call.
    final list = await (_db.select(_db.customLists)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (list != null && list.isPublic) {
      await _deleteSharedCollectionMirror(id);
    }
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
              genreIds: Value(movieData.genreIds),
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

    // Awaited, not fire-and-forget: setCollectionVisibility(true) returns to
    // ShareComposeSheet, which immediately publishes a post carrying this
    // document's id. If the mirror write were still in flight (or had failed)
    // the post would point at a document that does not exist, and the card
    // would render the "no longer shared" state on a collection just shared.
    await _ref.read(firestoreProvider).collection('shared_collections').doc('${user.uid}_$listId').set({
      'ownerId': user.uid,
      'ownerUsername': identity.username,
      'ownerAvatarUrl': identity.avatarUrl,
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
      // Delete the mirror FIRST and await it. Fire-and-forget here meant
      // "stop sharing" reported success while the document was still public
      // — and if the write failed (offline, rules), nothing ever retried it,
      // because the local isPublic flag had already been cleared.
      await _deleteSharedCollectionMirror(listId);
      await (_db.update(_db.customLists)..where((t) => t.id.equals(listId)))
          .write(const CustomListsCompanion(isPublic: Value(false)));
    }
  }

  /// Removes `shared_collections/{uid}_{listId}` if the signed-in user has one.
  ///
  /// Safe to call for a collection that was never shared: deleting a document
  /// that does not exist is a no-op in Firestore.
  Future<void> _deleteSharedCollectionMirror(int listId) async {
    final user = _ref.currentUser;
    if (user == null) return;
    await _ref
        .read(firestoreProvider)
        .collection('shared_collections')
        .doc('${user.uid}_$listId')
        .delete();
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
    // Caching the offline placeholder would write a localized title ("Çevrimdışı
    // İçerik") and an invented 120-minute runtime over whatever real row exists,
    // and those feed the graph, statistics and recommendations. Nothing is a
    // better cache entry than something fabricated.
    if (isOfflinePlaceholderPayload(movieData)) return;

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
            genreIds: Value(movie.genreIds),
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
        await _db.into(_db.movies).insertOnConflictUpdate(_movieFromBackupJson(x as Map<String, dynamic>));
      }
      for (final x in settingsList) {
        await _db.into(_db.userMovieSettings).insertOnConflictUpdate(
            UserMovieSetting.fromJson(_userMovieSettingBackupJson(x as Map<String, dynamic>)));
      }
      for (final x in recordsList) {
        await _db.into(_db.watchRecords).insertOnConflictUpdate(
            WatchRecord.fromJson(_watchRecordBackupJson(x as Map<String, dynamic>)));
      }
      for (final x in customListsList) {
        await _db.into(_db.customLists).insertOnConflictUpdate(
            CustomList.fromJson(_customListBackupJson(x as Map<String, dynamic>)));
      }
      for (final x in customListMoviesList) {
        await _db.into(_db.customListMovies).insertOnConflictUpdate(
            CustomListMovie.fromJson(_customListMovieBackupJson(x as Map<String, dynamic>)));
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
    // Same guard as the native path — see NativeMovieRepository.cacheMovieMetadata.
    if (isOfflinePlaceholderPayload(movieData)) return;

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

    // Serialised with the same Drift-generated `toJson()` the native path uses,
    // rather than a hand-written map per table. The hand-written version had
    // silently drifted from the schema and was dropping four fields on every
    // web backup — WatchRecords.tags and .remoteId, and UserMovieSettings
    // .personalRanking and .lastEpisodeProgressAt — so a user who backed up and
    // restored on web lost every tag they had ever written and their whole
    // personal ranking, with no error shown. Sharing the serialiser is what
    // stops that from happening again.
    return {
      'version': 1,
      'movies': movies.values.map((m) => m.toJson()).toList(),
      'watch_records': records.map((r) => r.toJson()).toList(),
      'user_movie_settings': settings.values.map((s) => s.toJson()).toList(),
      'custom_lists': customLists.values.map((l) => l.toJson()).toList(),
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

    // Deserialised with the same Drift `fromJson` the native path uses. The
    // hand-written version this replaces had to be kept in step with the schema
    // by hand and wasn't: it silently dropped WatchRecords.tags/.remoteId and
    // UserMovieSettings.personalRanking/.lastEpisodeProgressAt. The
    // *BackupJson helpers above supply the defaults for columns older files
    // predate, which is the one thing fromJson can't do on its own.
    final watchRecords = recordsList
        .whereType<Map<String, dynamic>>()
        .map((x) => WatchRecord.fromJson(_watchRecordBackupJson(x)))
        .toList();

    final movieSettings = <MovieKey, UserMovieSetting>{};
    for (final x in settingsList.whereType<Map<String, dynamic>>()) {
      final setting = UserMovieSetting.fromJson(_userMovieSettingBackupJson(x));
      movieSettings[(tmdbId: setting.tmdbId, isTv: setting.isTv)] = setting;
    }

    final movies = <MovieKey, Movie>{};
    for (final x in moviesList.whereType<Map<String, dynamic>>()) {
      // _movieFromBackupJson also recovers genreIds for pre-schema-13 files,
      // so a restored library isn't invisible to every genre statistic.
      final movie = _movieFromBackupJson(x);
      movies[(tmdbId: movie.tmdbId, isTv: movie.isTv)] = movie;
    }

    final customLists = <int, CustomList>{};
    for (final x in customListsList.whereType<Map<String, dynamic>>()) {
      final list = CustomList.fromJson(_customListBackupJson(x));
      customLists[list.id] = list;
    }

    final customListMovies = customListMoviesList
        .whereType<Map<String, dynamic>>()
        .map((x) => CustomListMovie.fromJson(_customListMovieBackupJson(x)))
        .toList();

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
