import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';

const _secureStorage = FlutterSecureStorage();
const _secureApiKeyStorageKey = 'tmdb_api_key';

final settingsKeyProvider = StateNotifierProvider<SettingsKeyNotifier, String>((ref) {
  return SettingsKeyNotifier();
});

class SettingsKeyNotifier extends StateNotifier<String> {
  SettingsKeyNotifier() : super(ApiConstants.tmdbApiKey) {
    loadKey();
  }

  Future<File?> get _settingsFile async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'app_settings.json'));
  }

  Future<void> loadKey() async {
    if (kIsWeb) return;
    try {
      var key = await _secureStorage.read(key: _secureApiKeyStorageKey);

      // One-time migration: earlier versions stored the key in plaintext
      // inside app_settings.json. Move it into secure storage and scrub it
      // from the plaintext file.
      if (key == null || key.isEmpty) {
        final file = await _settingsFile;
        if (file != null && await file.exists()) {
          final content = await file.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          final legacyKey = json['tmdb_api_key'] as String?;
          if (legacyKey != null && legacyKey.isNotEmpty) {
            key = legacyKey;
            await _secureStorage.write(key: _secureApiKeyStorageKey, value: legacyKey);
            json.remove('tmdb_api_key');
            await file.writeAsString(jsonEncode(json));
          }
        }
      }

      if (key != null && key.isNotEmpty) {
        state = key;
        ApiConstants.tmdbApiKey = key;
      }
    } catch (e) {
      debugPrint('loadKey failed: $e');
    }
  }

  Future<void> saveKey(String key) async {
    state = key;
    ApiConstants.tmdbApiKey = key;
    if (kIsWeb) return;
    try {
      await _secureStorage.write(key: _secureApiKeyStorageKey, value: key);
    } catch (e) {
      debugPrint('saveKey failed: $e');
    }
  }
}

final settingsBaseUrlProvider = StateNotifierProvider<SettingsBaseUrlNotifier, String>((ref) {
  return SettingsBaseUrlNotifier();
});

class SettingsBaseUrlNotifier extends StateNotifier<String> {
  SettingsBaseUrlNotifier() : super('https://api.themoviedb.org/3') {
    loadBaseUrl();
  }

  Future<File?> get _settingsFile async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'app_settings.json'));
  }

  Future<void> loadBaseUrl() async {
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final url = json['tmdb_base_url'] as String?;
        if (url != null && url.isNotEmpty) {
          state = url;
          ApiConstants.baseUrl = url;
        }
      }
    } catch (e) {
      debugPrint('loadBaseUrl failed: $e');
    }
  }

  Future<void> saveBaseUrl(String url) async {
    state = url;
    ApiConstants.baseUrl = url;
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null) {
        Map<String, dynamic> json = {};
        if (await file.exists()) {
          final content = await file.readAsString();
          json = jsonDecode(content) as Map<String, dynamic>;
        }
        json['tmdb_base_url'] = url;
        await file.writeAsString(jsonEncode(json));
      }
    } catch (e) {
      debugPrint('saveBaseUrl failed: $e');
    }
  }
}

// Backup & Restore Services
class BackupService {
  static Future<Map<String, dynamic>> exportData(WidgetRef ref) async {
    if (kIsWeb) {
      final records = ref.read(webWatchRecordsProvider);
      final settings = ref.read(webMovieSettingsProvider);
      final movies = ref.read(webMoviesProvider);
      
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
      };
    }
    
    final db = ref.read(databaseProvider);
    final movies = await db.select(db.movies).get();
    final records = await db.select(db.watchRecords).get();
    final settings = await db.select(db.userMovieSettings).get();
    
    return {
      'version': 1,
      'movies': movies.map((m) => m.toJson()).toList(),
      'watch_records': records.map((r) => r.toJson()).toList(),
      'user_movie_settings': settings.map((s) => s.toJson()).toList(),
    };
  }

  static Future<void> importData(WidgetRef ref, Map<String, dynamic> json) async {
    final moviesList = json['movies'] as List<dynamic>? ?? [];
    final recordsList = json['watch_records'] as List<dynamic>? ?? [];
    final settingsList = json['user_movie_settings'] as List<dynamic>? ?? [];
    
    if (kIsWeb) {
      // Restore Web In-memory states
      final watchRecords = recordsList.map((x) {
        final map = x as Map<String, dynamic>;
        return WatchRecord(
          id: map['id'] as int,
          movieId: map['movieId'] as int,
          // Absent in backups made before the movie/TV id-collision fix.
          isTv: map['isTv'] as bool? ?? false,
          watchDate: DateTime.parse(map['watchDate'] as String),
          watchPlace: map['watchPlace'] as String?,
          watchCompanion: map['watchCompanion'] as String?,
          rating: (map['rating'] as num).toDouble(),
          mood: map['mood'] as String?,
          notes: map['notes'] as String?,
          watchNumber: map['watchNumber'] as int,
          createdAt: DateTime.parse(map['createdAt'] as String),
          // Absent in backups made before episode-count tracking existed.
          episodeCount: map['episodeCount'] as int? ?? 1,
        );
      }).toList();
      
      final movieSettings = <MovieKey, UserMovieSetting>{};
      for (final x in settingsList) {
        final map = x as Map<String, dynamic>;
        final id = map['tmdbId'] as int;
        final settingIsTv = map['isTv'] as bool? ?? false;
        movieSettings[(tmdbId: id, isTv: settingIsTv)] = UserMovieSetting(
          tmdbId: id,
          isTv: settingIsTv,
          isFavorite: map['isFavorite'] as bool? ?? false,
          isReWatchList: map['isReWatchList'] as bool? ?? false,
          personalNotes: map['personalNotes'] as String?,
          personalTags: map['personalTags'] as String?,
          updatedAt: DateTime.parse(map['updatedAt'] as String),
          // Absent in backups made before "Aktif İzliyorum" tracking existed.
          isActivelyWatching: map['isActivelyWatching'] as bool? ?? false,
          lastWatchedEpisode: map['lastWatchedEpisode'] as int?,
        );
      }
      
      final movies = <MovieKey, Movie>{};
      for (final x in moviesList) {
        final map = x as Map<String, dynamic>;
        final id = map['tmdbId'] as int;
        final movieIsTv = map['isTv'] as bool? ?? false;
        movies[(tmdbId: id, isTv: movieIsTv)] = Movie(
          tmdbId: id,
          title: map['title'] as String,
          originalTitle: map['originalTitle'] as String?,
          posterPath: map['posterPath'] as String?,
          backdropPath: map['backdropPath'] as String?,
          releaseYear: map['releaseYear'] as int?,
          runtime: map['runtime'] as int?,
          genres: map['genres'] as String?,
          director: map['director'] as String?,
          actors: map['actors'] as String?,
          overview: map['overview'] as String?,
          isTv: movieIsTv,
          createdAt: DateTime.parse(map['createdAt'] as String),
          totalEpisodes: map['totalEpisodes'] as int?,
        );
      }
      
      ref.read(webWatchRecordsProvider.notifier).state = watchRecords;
      ref.read(webMovieSettingsProvider.notifier).state = movieSettings;
      ref.read(webMoviesProvider.notifier).state = movies;
      return;
    }
    
    // Restore Native Database
    final db = ref.read(databaseProvider);
    
    await db.transaction(() async {
      // Clear tables first
      await db.delete(db.watchRecords).go();
      await db.delete(db.userMovieSettings).go();
      await db.delete(db.movies).go();
      
      for (final x in moviesList) {
        await db.into(db.movies).insertOnConflictUpdate(Movie.fromJson(x as Map<String, dynamic>));
      }
      for (final x in settingsList) {
        await db.into(db.userMovieSettings).insertOnConflictUpdate(UserMovieSetting.fromJson(x as Map<String, dynamic>));
      }
      for (final x in recordsList) {
        await db.into(db.watchRecords).insertOnConflictUpdate(WatchRecord.fromJson(x as Map<String, dynamic>));
      }
    });
  }
}

final weeklyGoalProvider = StateNotifierProvider<WeeklyGoalNotifier, int>((ref) {
  return WeeklyGoalNotifier();
});

class WeeklyGoalNotifier extends StateNotifier<int> {
  WeeklyGoalNotifier() : super(3) {
    loadGoal();
  }

  Future<File?> get _settingsFile async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'app_settings.json'));
  }

  Future<void> loadGoal() async {
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final goal = json['weekly_watch_goal'] as int? ?? 3;
        state = goal;
      }
    } catch (e) {
      debugPrint('loadGoal failed: $e');
    }
  }

  Future<void> saveGoal(int goal) async {
    state = goal;
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null) {
        Map<String, dynamic> json = {};
        if (await file.exists()) {
          final content = await file.readAsString();
          json = jsonDecode(content) as Map<String, dynamic>;
        }
        json['weekly_watch_goal'] = goal;
        await file.writeAsString(jsonEncode(json));
      }
    } catch (e) {
      debugPrint('saveGoal failed: $e');
    }
  }
}

// Whether the Journal screen shows the sortable/drag-reorder table view
// (true) or the month-grouped card view (false, default).
final journalViewModeProvider = StateNotifierProvider<JournalViewModeNotifier, bool>((ref) {
  return JournalViewModeNotifier();
});

class JournalViewModeNotifier extends StateNotifier<bool> {
  JournalViewModeNotifier() : super(false) {
    _load();
  }

  Future<File?> get _settingsFile async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'app_settings.json'));
  }

  Future<void> _load() async {
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        state = json['journal_table_view'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('journal view mode load failed: $e');
    }
  }

  Future<void> setTableView(bool isTableView) async {
    state = isTableView;
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null) {
        Map<String, dynamic> json = {};
        if (await file.exists()) {
          final content = await file.readAsString();
          json = jsonDecode(content) as Map<String, dynamic>;
        }
        json['journal_table_view'] = isTableView;
        await file.writeAsString(jsonEncode(json));
      }
    } catch (e) {
      debugPrint('journal view mode save failed: $e');
    }
  }
}
