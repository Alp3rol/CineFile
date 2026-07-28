import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/app_settings_store.dart';

// Re-exported so existing call sites (settings_backup_dialogs.dart) keep
// importing BackupService from here, while the implementation lives next to
// the data it backs up.
export '../../../../core/database/backup_service.dart' show BackupService;

const _secureStorage = FlutterSecureStorage();
const _secureApiKeyStorageKey = 'tmdb_api_key';

/// Shared owner of `app_settings.json` — see [AppSettingsStore] for why every
/// preference goes through one instance instead of reading and rewriting the
/// file independently.
final appSettingsStoreProvider = Provider<AppSettingsStore>((ref) => AppSettingsStore());

/// Base class for the file-backed preferences below. Each subclass only has to
/// name its key and its default; loading, caching and serialised writing are
/// handled once here rather than copy-pasted per preference.
abstract class _StoredPreferenceNotifier<T> extends StateNotifier<T> {
  _StoredPreferenceNotifier(this._store, this._key, T initial) : super(initial) {
    unawaited(_load());
  }

  final AppSettingsStore _store;
  final String _key;

  Future<void> _load() async {
    await _store.ensureLoaded();
    final stored = _store.read<T>(_key);
    if (stored != null) state = stored;
  }

  Future<void> _save(T value) async {
    state = value;
    await _store.write(_key, value);
  }
}

final settingsKeyProvider = StateNotifierProvider<SettingsKeyNotifier, String>((ref) {
  return SettingsKeyNotifier(ref.watch(appSettingsStoreProvider));
});

/// The TMDb API key. Unlike the other preferences this is a secret, so it
/// lives in the platform keystore rather than in the plaintext settings file —
/// the store is only consulted to migrate keys written by older versions.
class SettingsKeyNotifier extends StateNotifier<String> {
  SettingsKeyNotifier(this._store) : super(ApiConstants.tmdbApiKey) {
    unawaited(loadKey());
  }

  final AppSettingsStore _store;

  Future<void> loadKey() async {
    if (kIsWeb) return;
    try {
      var key = await _secureStorage.read(key: _secureApiKeyStorageKey);

      // One-time migration: earlier versions stored the key in plaintext
      // inside app_settings.json. Move it into secure storage and scrub it
      // from the plaintext file.
      if (key == null || key.isEmpty) {
        await _store.ensureLoaded();
        final legacyKey = _store.read<String>(_secureApiKeyStorageKey);
        if (legacyKey != null && legacyKey.isNotEmpty) {
          key = legacyKey;
          await _secureStorage.write(key: _secureApiKeyStorageKey, value: legacyKey);
          await _store.remove(_secureApiKeyStorageKey);
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
  return SettingsBaseUrlNotifier(ref.watch(appSettingsStoreProvider));
});

class SettingsBaseUrlNotifier extends _StoredPreferenceNotifier<String> {
  SettingsBaseUrlNotifier(AppSettingsStore store)
      : super(store, 'tmdb_base_url', ApiConstants.defaultBaseUrl);

  @override
  Future<void> _load() async {
    await super._load();
    ApiConstants.baseUrl = state;
  }

  Future<void> saveBaseUrl(String url) async {
    ApiConstants.baseUrl = url;
    await _save(url);
  }
}

final releaseRemindersEnabledProvider =
    StateNotifierProvider<ReleaseRemindersNotifier, bool>((ref) {
  return ReleaseRemindersNotifier(ref.watch(appSettingsStoreProvider));
});

class ReleaseRemindersNotifier extends _StoredPreferenceNotifier<bool> {
  ReleaseRemindersNotifier(AppSettingsStore store)
      : super(store, 'release_reminders_enabled', false);

  Future<void> savePreference(bool enabled) => _save(enabled);
}

final weeklyGoalProvider = StateNotifierProvider<WeeklyGoalNotifier, int>((ref) {
  return WeeklyGoalNotifier(ref.watch(appSettingsStoreProvider));
});

class WeeklyGoalNotifier extends _StoredPreferenceNotifier<int> {
  WeeklyGoalNotifier(AppSettingsStore store) : super(store, 'weekly_watch_goal', 3);

  Future<void> saveGoal(int goal) => _save(goal);
}

/// Whether the Journal screen shows the sortable/drag-reorder table view
/// (true) or the month-grouped card view (false, default).
final journalViewModeProvider = StateNotifierProvider<JournalViewModeNotifier, bool>((ref) {
  return JournalViewModeNotifier(ref.watch(appSettingsStoreProvider));
});

class JournalViewModeNotifier extends _StoredPreferenceNotifier<bool> {
  JournalViewModeNotifier(AppSettingsStore store)
      : super(store, 'journal_table_view', false);

  Future<void> setTableView(bool isTableView) => _save(isTableView);
}

final dynamicBackgroundEnabledProvider =
    StateNotifierProvider<DynamicBackgroundEnabledNotifier, bool>((ref) {
  return DynamicBackgroundEnabledNotifier(ref.watch(appSettingsStoreProvider));
});

class DynamicBackgroundEnabledNotifier extends _StoredPreferenceNotifier<bool> {
  DynamicBackgroundEnabledNotifier(AppSettingsStore store)
      : super(store, 'dynamic_background_enabled', true);

  Future<void> setEnabled(bool enabled) => _save(enabled);
}
