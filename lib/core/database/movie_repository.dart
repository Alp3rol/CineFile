import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_database.dart';
import 'database_provider.dart';
import 'web_local_store.dart';
import 'custom_list_repository.dart';
import 'backup_repository.dart';
import '../constants/tmdb_genres.dart';
import '../../features/auth/controllers/auth_controller.dart';

/// Centralizes the native (Drift/SQLite) vs. web (in-memory) write paths
/// behind one interface, so call sites don't need to branch on kIsWeb
/// themselves and each platform's logic lives in exactly one place.
abstract class MovieRepository {
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
  final director =
      crew
              ?.where((e) => e is Map && e['job'] == 'Director')
              .firstOrNull?['name']
          as String?;

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
      (movieData['release_date'] ?? movieData['first_air_date'] ?? '')
          .toString();
  final releaseYear =
      DateTime.tryParse(releaseDateStr)?.year ??
      int.tryParse(releaseDateStr.split('-').first);

  return Movie(
    tmdbId: tmdbId,
    // Falls through to the original title rather than a localized "Unknown
    // Title" placeholder: whatever lands here is written to the database as
    // the title, and a placeholder in one language becomes wrong data the
    // moment the user switches — the same leak the director field had. An
    // empty string is honest, and display sites already substitute their own
    // placeholder for it.
    title:
        (movieData['title'] ??
                movieData['name'] ??
                movieData['original_title'] ??
                movieData['original_name'] ??
                '')
            as String,
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

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return kIsWeb ? WebMovieRepository(ref) : NativeMovieRepository(ref);
});

/// Writes personal rankings to `users/{uid}/movie_settings`.
///
/// Lives outside the two repository classes because it is not
/// platform-dependent at all: rankings are Firestore-only, so both
/// implementations carried a character-for-character identical copy of this.
/// The interface method on each is now a one-line delegation to here — kept on
/// the interface so the Journal's call site doesn't have to know that.
///
/// One batch rather than a `set()` per entry: reordering a fifty-title list
/// used to be fifty sequential round trips, each awaited before the next
/// started.
Future<void> writeWatchRecordRankings(
  Ref ref,
  Map<MovieKey, int?> rankings,
) async {
  if (rankings.isEmpty) return;
  final user = ref.currentUser;
  if (user == null) return;

  try {
    final firestore = ref.read(firestoreProvider);
    final settings = firestore
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings');

    final batch = firestore.batch();
    for (final entry in rankings.entries) {
      batch.set(
        settings.doc('${entry.key.tmdbId}_${entry.key.isTv}'),
        {
          'movieId': entry.key.tmdbId,
          'isTv': entry.key.isTv,
          'personalRanking': entry.value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  } catch (e, st) {
    debugPrint('writeWatchRecordRankings failed: $e\n$st');
    rethrow;
  }
}

class NativeMovieRepository implements MovieRepository {
  NativeMovieRepository(this._ref);
  final Ref _ref;
  AppDatabase get _db => _ref.read(databaseProvider);
  CustomListRepository get _customListRepo =>
      _ref.read(customListRepositoryProvider);
  BackupRepository get _backupRepo => _ref.read(backupRepositoryProvider);

  @override
  Future<void> createCustomList(
    String name,
    String? description, {
    DateTime? targetDate,
  }) => _customListRepo.createCustomList(
    name,
    description,
    targetDate: targetDate,
  );

  @override
  Future<void> updateCustomList(
    int id,
    String name,
    String? description, {
    DateTime? targetDate,
    bool clearTargetDate = false,
  }) => _customListRepo.updateCustomList(
    id,
    name,
    description,
    targetDate: targetDate,
    clearTargetDate: clearTargetDate,
  );

  @override
  Future<void> deleteCustomList(int id) => _customListRepo.deleteCustomList(id);

  @override
  Future<void> addMovieToCustomList(int listId, Movie movieData) =>
      _customListRepo.addMovieToCustomList(listId, movieData);

  @override
  Future<void> removeMovieFromCustomList(int listId, int tmdbId, bool isTv) =>
      _customListRepo.removeMovieFromCustomList(listId, tmdbId, isTv);

  @override
  Future<void> reorderCustomListMovies(
    int listId,
    Map<MovieKey, int> rankings,
  ) => _customListRepo.reorderCustomListMovies(listId, rankings);

  @override
  Future<void> setCollectionVisibility(int listId, bool isPublic) =>
      _customListRepo.setCollectionVisibility(listId, isPublic);

  @override
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) =>
      writeWatchRecordRankings(_ref, rankings);

  @override
  Future<void> deleteWatchRecordsByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    await (_db.delete(_db.watchRecords)..where((t) => t.id.isIn(ids))).go();
  }

  @override
  Future<void> deleteWatchRecordLocal(WatchRecord record) async {
    await (_db.delete(
      _db.watchRecords,
    )..where((t) => t.id.equals(record.id))).go();

    // Recalculate Drift settings progress
    final remainingRecords =
        await (_db.select(_db.watchRecords)
              ..where(
                (t) =>
                    t.movieId.equals(record.movieId) &
                    t.isTv.equals(record.isTv),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.watchDate)]))
            .get();

    final settingsQuery = _db.select(_db.userMovieSettings)
      ..where(
        (t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv),
      );
    final existingSetting = await settingsQuery.getSingleOrNull();

    if (existingSetting == null) return;

    if (remainingRecords.isEmpty) {
      await (_db.update(_db.userMovieSettings)..where(
            (t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv),
          ))
          .write(
            const UserMovieSettingsCompanion(
              isActivelyWatching: Value(false),
              lastWatchedEpisode: Value(null),
            ),
          );
    } else {
      final latestRecord = remainingRecords.first;
      final latestWatchNumber = latestRecord.watchNumber;

      final currentEpisodeProgress = remainingRecords
          .where((r) => r.watchNumber == latestWatchNumber)
          .fold<int>(0, (acc, r) => acc + r.episodeCount);

      final movieQuery = _db.select(_db.movies)
        ..where(
          (t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv),
        );
      final movie = await movieQuery.getSingleOrNull();
      final totalEpisodes = movie?.totalEpisodes;

      final newIsActivelyWatching =
          totalEpisodes == null || currentEpisodeProgress < totalEpisodes;

      await (_db.update(_db.userMovieSettings)..where(
            (t) => t.tmdbId.equals(record.movieId) & t.isTv.equals(record.isTv),
          ))
          .write(
            UserMovieSettingsCompanion(
              isActivelyWatching: Value(newIsActivelyWatching),
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
    await (_db.update(
      _db.watchRecords,
    )..where((t) => t.id.equals(record.id))).write(
      WatchRecordsCompanion(
        watchDate: watchDate != null ? Value(watchDate) : const Value.absent(),
        episodeCount: episodeCount != null
            ? Value(episodeCount)
            : const Value.absent(),
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

    final movie = movieFromTmdbPayload(
      tmdbId: tmdbId,
      isTv: isTv,
      movieData: movieData,
    );
    // createdAt is intentionally left absent so re-caching an already-known
    // title doesn't bump its original "added at" timestamp to now (which the
    // Home screen's "Son Eklediklerim" ordering depends on).
    await _db
        .into(_db.movies)
        .insertOnConflictUpdate(
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
      await cacheMovieMetadata(
        tmdbId: tmdbId,
        isTv: isTv,
        movieData: movieData,
      );

      await _db
          .into(_db.userMovieSettings)
          .insertOnConflictUpdate(
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
  Future<Map<String, dynamic>> exportBackupData() =>
      _backupRepo.exportBackupData();

  @override
  Future<void> importBackupData(Map<String, dynamic> json) =>
      _backupRepo.importBackupData(json);

  @override
  Future<void> writeEpisodeProgressSettingsLocal({
    required int tmdbId,
    required bool isTv,
    required UserMovieSetting setting,
    required int? lastWatchedEpisode,
    required bool isActivelyWatching,
  }) async {
    await _db
        .into(_db.userMovieSettings)
        .insertOnConflictUpdate(
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
  CustomListRepository get _customListRepo => WebCustomListRepository(_ref);
  BackupRepository get _backupRepo => WebBackupRepository(_ref);

  @override
  Future<void> createCustomList(
    String name,
    String? description, {
    DateTime? targetDate,
  }) => _customListRepo.createCustomList(
    name,
    description,
    targetDate: targetDate,
  );

  @override
  Future<void> updateCustomList(
    int id,
    String name,
    String? description, {
    DateTime? targetDate,
    bool clearTargetDate = false,
  }) => _customListRepo.updateCustomList(
    id,
    name,
    description,
    targetDate: targetDate,
    clearTargetDate: clearTargetDate,
  );

  @override
  Future<void> deleteCustomList(int id) => _customListRepo.deleteCustomList(id);

  @override
  Future<void> addMovieToCustomList(int listId, Movie movieData) =>
      _customListRepo.addMovieToCustomList(listId, movieData);

  @override
  Future<void> removeMovieFromCustomList(int listId, int tmdbId, bool isTv) =>
      _customListRepo.removeMovieFromCustomList(listId, tmdbId, isTv);

  @override
  Future<void> reorderCustomListMovies(
    int listId,
    Map<MovieKey, int> rankings,
  ) => _customListRepo.reorderCustomListMovies(listId, rankings);

  @override
  Future<void> setCollectionVisibility(int listId, bool isPublic) =>
      _customListRepo.setCollectionVisibility(listId, isPublic);

  @override
  Future<Map<String, dynamic>> exportBackupData() =>
      _backupRepo.exportBackupData();

  @override
  Future<void> importBackupData(Map<String, dynamic> json) =>
      _backupRepo.importBackupData(json);

  @override
  Future<void> deleteWatchRecordsByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    final idsToDelete = ids.toSet();
    final notifier = _ref.read(webWatchRecordsProvider.notifier);
    final currentList = _ref.read(webWatchRecordsProvider);
    notifier.state = currentList
        .where((r) => !idsToDelete.contains(r.id))
        .toList();
  }

  @override
  Future<void> deleteWatchRecordLocal(WatchRecord record) async {
    final notifier = _ref.read(webWatchRecordsProvider.notifier);
    final currentList = _ref.read(webWatchRecordsProvider);
    final remainingRecords = currentList
        .where((r) => r.id != record.id)
        .toList();
    notifier.state = remainingRecords;

    final key = (tmdbId: record.movieId, isTv: record.isTv);
    final currentSettings = _ref.read(webMovieSettingsProvider);
    final existingSetting = currentSettings[key];
    if (existingSetting == null) return;

    final movieRecords =
        remainingRecords
            .where((r) => r.movieId == record.movieId && r.isTv == record.isTv)
            .toList()
          ..sort((a, b) => b.watchDate.compareTo(a.watchDate));

    int? lastWatchedEpisode;
    var isActivelyWatching = false;
    if (movieRecords.isNotEmpty) {
      final latestWatchNumber = movieRecords.first.watchNumber;
      lastWatchedEpisode = movieRecords
          .where((r) => r.watchNumber == latestWatchNumber)
          .fold<int>(0, (total, r) => total + r.episodeCount);
      final totalEpisodes = _ref.read(webMoviesProvider)[key]?.totalEpisodes;
      isActivelyWatching =
          totalEpisodes == null || lastWatchedEpisode < totalEpisodes;
    }

    final updatedSettings = Map<MovieKey, UserMovieSetting>.from(
      currentSettings,
    );
    updatedSettings[key] = existingSetting.copyWith(
      isActivelyWatching: isActivelyWatching,
      lastWatchedEpisode: Value(lastWatchedEpisode),
    );
    _ref.read(webMovieSettingsProvider.notifier).state = updatedSettings;
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
    await WebLocalStore.save(
      movies: updated,
      customLists: _ref.read(webCustomListsProvider),
      customListMovies: _ref.read(webCustomListMoviesProvider),
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
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) =>
      writeWatchRecordRankings(_ref, rankings);

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
    final updatedSettings = Map<MovieKey, UserMovieSetting>.from(
      currentSettings,
    );
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
