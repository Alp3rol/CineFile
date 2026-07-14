import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/movie_repository.dart';

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

final releaseRemindersEnabledProvider = StateNotifierProvider<ReleaseRemindersNotifier, bool>((ref) {
  return ReleaseRemindersNotifier();
});

class ReleaseRemindersNotifier extends StateNotifier<bool> {
  ReleaseRemindersNotifier() : super(false) {
    loadPreference();
  }

  Future<File?> get _settingsFile async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'app_settings.json'));
  }

  Future<void> loadPreference() async {
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final enabled = json['release_reminders_enabled'] as bool?;
        if (enabled != null) {
          state = enabled;
        }
      }
    } catch (e) {
      debugPrint('loadPreference failed: $e');
    }
  }

  Future<void> savePreference(bool enabled) async {
    state = enabled;
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null) {
        Map<String, dynamic> json = {};
        if (await file.exists()) {
          final content = await file.readAsString();
          json = jsonDecode(content) as Map<String, dynamic>;
        }
        json['release_reminders_enabled'] = enabled;
        await file.writeAsString(jsonEncode(json));
      }
    } catch (e) {
      debugPrint('savePreference failed: $e');
    }
  }
}

// Backup & Restore Services — delegates the actual web-vs-native storage
// work to MovieRepository (see movie_repository.dart's exportBackupData/
// importBackupData) rather than branching on kIsWeb here.
// `ref` stays `dynamic` (not WidgetRef) because tests call this with a bare
// ProviderContainer, which also exposes a compatible `.read()`.
class BackupService {
  static Future<Map<String, dynamic>> exportData(dynamic ref) {
    return ref.read(movieRepositoryProvider).exportBackupData();
  }

  static Future<void> importData(dynamic ref, Map<String, dynamic> json) {
    return ref.read(movieRepositoryProvider).importBackupData(json);
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

final dynamicBackgroundEnabledProvider = StateNotifierProvider<DynamicBackgroundEnabledNotifier, bool>((ref) {
  return DynamicBackgroundEnabledNotifier();
});

class DynamicBackgroundEnabledNotifier extends StateNotifier<bool> {
  DynamicBackgroundEnabledNotifier() : super(true) {
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
        state = json['dynamic_background_enabled'] as bool? ?? true;
      }
    } catch (e) {
      debugPrint('dynamic background load failed: $e');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    if (kIsWeb) return;
    try {
      final file = await _settingsFile;
      if (file != null) {
        Map<String, dynamic> json = {};
        if (await file.exists()) {
          final content = await file.readAsString();
          json = jsonDecode(content) as Map<String, dynamic>;
        }
        json['dynamic_background_enabled'] = enabled;
        await file.writeAsString(jsonEncode(json));
      }
    } catch (e) {
      debugPrint('dynamic background save failed: $e');
    }
  }
}
