import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/tmdb_genres.dart';
import 'app_database.dart';
import 'database_provider.dart';
import 'web_local_store.dart';

/// Handles exporting and importing database backups.
abstract class BackupRepository {
  Future<Map<String, dynamic>> exportBackupData();
  Future<void> importBackupData(Map<String, dynamic> json);
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null ? message : '$message: $cause';
}

List<Map<String, dynamic>>? _backupSection(
  Map<String, dynamic> json,
  String key,
) {
  if (!json.containsKey(key)) return null;
  final value = json[key];
  if (value is! List<dynamic>) {
    throw BackupFormatException('Backup section "$key" must be a list.');
  }
  // A stray scalar entry cannot be restored and is safe to ignore. Field
  // errors inside a map remain errors and are reported before any mutation.
  return value.whereType<Map<String, dynamic>>().toList();
}

List<T>? _parseBackupSection<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) parse,
) {
  final section = _backupSection(json, key);
  if (section == null) return null;
  try {
    return section.map(parse).toList();
  } catch (error) {
    throw BackupFormatException('Backup section "$key" is invalid.', error);
  }
}

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return kIsWeb ? WebBackupRepository(ref) : NativeBackupRepository(ref);
});

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

Movie _movieFromBackupJson(Map<String, dynamic> json) {
  final movie = Movie.fromJson(_movieBackupJson(json));
  if (movie.genreIds != null) return movie;

  final recovered = formatGenreIds(genreIdsFromLegacyNames(movie.genres));
  return recovered == null ? movie : movie.copyWith(genreIds: Value(recovered));
}

class NativeBackupRepository implements BackupRepository {
  NativeBackupRepository(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

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
    // Parse everything before entering the destructive transaction. A bad
    // field can therefore never run after table deletion has started.
    final movies = _parseBackupSection(json, 'movies', _movieFromBackupJson);
    final records = _parseBackupSection(
      json,
      'watch_records',
      (x) => WatchRecord.fromJson(_watchRecordBackupJson(x)),
    );
    final settings = _parseBackupSection(
      json,
      'user_movie_settings',
      (x) => UserMovieSetting.fromJson(_userMovieSettingBackupJson(x)),
    );
    final customLists = _parseBackupSection(
      json,
      'custom_lists',
      (x) => CustomList.fromJson(_customListBackupJson(x)),
    );
    final customListMovies = _parseBackupSection(
      json,
      'custom_list_movies',
      (x) => CustomListMovie.fromJson(_customListMovieBackupJson(x)),
    );
    final isFullBackup =
        movies != null &&
        records != null &&
        settings != null &&
        customLists != null &&
        customListMovies != null;

    await _db.transaction(() async {
      if (isFullBackup) {
        await _db.delete(_db.customListMovies).go();
        await _db.delete(_db.customLists).go();
        await _db.delete(_db.watchRecords).go();
        await _db.delete(_db.userMovieSettings).go();
        await _db.delete(_db.movies).go();
      }

      if (movies != null) {
        for (final movie in movies) {
          await _db.into(_db.movies).insertOnConflictUpdate(movie);
        }
      }
      if (settings != null) {
        for (final setting in settings) {
          await _db.into(_db.userMovieSettings).insertOnConflictUpdate(setting);
        }
      }
      if (records != null) {
        for (final record in records) {
          await _db.into(_db.watchRecords).insertOnConflictUpdate(record);
        }
      }
      if (customLists != null) {
        for (final list in customLists) {
          await _db.into(_db.customLists).insertOnConflictUpdate(list);
        }
      }
      if (customListMovies != null) {
        for (final relation in customListMovies) {
          await _db.into(_db.customListMovies).insertOnConflictUpdate(relation);
        }
      }
    });
  }
}

class WebBackupRepository implements BackupRepository {
  WebBackupRepository(this._ref);
  final Ref _ref;

  @override
  Future<Map<String, dynamic>> exportBackupData() async {
    final records = _ref.read(webWatchRecordsProvider);
    final settings = _ref.read(webMovieSettingsProvider);
    final movies = _ref.read(webMoviesProvider);
    final customLists = _ref.read(webCustomListsProvider);
    final customListMovies = _ref.read(webCustomListMoviesProvider);

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
    var watchRecords = _parseBackupSection(
      json,
      'watch_records',
      (x) => WatchRecord.fromJson(_watchRecordBackupJson(x)),
    );

    Map<MovieKey, UserMovieSetting>? movieSettings;
    final parsedSettings = _parseBackupSection(
      json,
      'user_movie_settings',
      (x) => UserMovieSetting.fromJson(_userMovieSettingBackupJson(x)),
    );
    if (parsedSettings != null) {
      movieSettings = {
        for (final setting in parsedSettings)
          (tmdbId: setting.tmdbId, isTv: setting.isTv): setting,
      };
    }

    Map<MovieKey, Movie>? movies;
    final parsedMovies = _parseBackupSection(
      json,
      'movies',
      _movieFromBackupJson,
    );
    if (parsedMovies != null) {
      movies = {
        for (final movie in parsedMovies)
          (tmdbId: movie.tmdbId, isTv: movie.isTv): movie,
      };
    }

    Map<int, CustomList>? customLists;
    final parsedLists = _parseBackupSection(
      json,
      'custom_lists',
      (x) => CustomList.fromJson(_customListBackupJson(x)),
    );
    if (parsedLists != null) {
      customLists = {for (final list in parsedLists) list.id: list};
    }

    var customListMovies = _parseBackupSection(
      json,
      'custom_list_movies',
      (x) => CustomListMovie.fromJson(_customListMovieBackupJson(x)),
    );
    final isFullBackup =
        movies != null &&
        watchRecords != null &&
        movieSettings != null &&
        customLists != null &&
        customListMovies != null;

    if (!isFullBackup) {
      if (movies != null) {
        movies = {..._ref.read(webMoviesProvider), ...movies};
      }
      if (movieSettings != null) {
        movieSettings = {
          ..._ref.read(webMovieSettingsProvider),
          ...movieSettings,
        };
      }
      if (customLists != null) {
        customLists = {..._ref.read(webCustomListsProvider), ...customLists};
      }
      if (watchRecords != null) {
        watchRecords = [..._ref.read(webWatchRecordsProvider), ...watchRecords];
      }
      if (customListMovies != null) {
        final merged =
            <({int listId, int tmdbId, bool isTv}), CustomListMovie>{};
        for (final relation in [
          ..._ref.read(webCustomListMoviesProvider),
          ...customListMovies,
        ]) {
          merged[(
                listId: relation.listId,
                tmdbId: relation.movieId,
                isTv: relation.isTv,
              )] =
              relation;
        }
        customListMovies = merged.values.toList();
      }
    }

    if (watchRecords != null) {
      _ref.read(webWatchRecordsProvider.notifier).state = watchRecords;
    }
    if (movieSettings != null) {
      _ref.read(webMovieSettingsProvider.notifier).state = movieSettings;
    }
    if (movies != null) {
      _ref.read(webMoviesProvider.notifier).state = movies;
    }
    if (customLists != null) {
      _ref.read(webCustomListsProvider.notifier).state = customLists;
    }
    if (customListMovies != null) {
      _ref.read(webCustomListMoviesProvider.notifier).state = customListMovies;
    }
    await WebLocalStore.save(
      movies: movies ?? _ref.read(webMoviesProvider),
      customLists: customLists ?? _ref.read(webCustomListsProvider),
      customListMovies:
          customListMovies ?? _ref.read(webCustomListMoviesProvider),
    );
  }
}
