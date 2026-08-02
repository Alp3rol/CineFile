import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/tmdb_genres.dart';
import 'app_database.dart';
import 'database_provider.dart';

/// Handles exporting and importing database backups.
abstract class BackupRepository {
  Future<Map<String, dynamic>> exportBackupData();
  Future<void> importBackupData(Map<String, dynamic> json);
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
    final moviesList = json['movies'] as List<dynamic>? ?? [];
    final recordsList = json['watch_records'] as List<dynamic>? ?? [];
    final settingsList = json['user_movie_settings'] as List<dynamic>? ?? [];
    final customListsList = json['custom_lists'] as List<dynamic>? ?? [];
    final customListMoviesList = json['custom_list_movies'] as List<dynamic>? ?? [];

    await _db.transaction(() async {
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
    final moviesList = json['movies'] as List<dynamic>? ?? [];
    final recordsList = json['watch_records'] as List<dynamic>? ?? [];
    final settingsList = json['user_movie_settings'] as List<dynamic>? ?? [];
    final customListsList = json['custom_lists'] as List<dynamic>? ?? [];
    final customListMoviesList = json['custom_list_movies'] as List<dynamic>? ?? [];

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
}
