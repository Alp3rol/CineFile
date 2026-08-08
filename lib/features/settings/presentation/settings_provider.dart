import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/watch_regions.dart';
import '../../../../core/l10n/l10n_lookup.dart';
import '../../../../core/observability/error_reporting.dart';
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
final appSettingsStoreProvider = Provider<AppSettingsStore>(
  (ref) => AppSettingsStore(),
);

/// Base class for the file-backed preferences below. Each subclass only has to
/// name its key and its default; loading, caching and serialised writing are
/// handled once here rather than copy-pasted per preference.
abstract class _StoredPreferenceNotifier<T> extends StateNotifier<T> {
  _StoredPreferenceNotifier(this._store, this._key, T initial)
    : super(initial) {
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

final settingsKeyProvider = StateNotifierProvider<SettingsKeyNotifier, String>((
  ref,
) {
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
          await _secureStorage.write(
            key: _secureApiKeyStorageKey,
            value: legacyKey,
          );
          await _store.remove(_secureApiKeyStorageKey);
        }
      }

      if (key != null && key.isNotEmpty) {
        state = key;
        ApiConstants.tmdbApiKey = key;
      }
    } catch (error, stackTrace) {
      reportError(error, stackTrace, where: 'settings.apiKey.load');
    }
  }

  Future<void> saveKey(String key) async {
    state = key;
    ApiConstants.tmdbApiKey = key;
    if (kIsWeb) return;
    try {
      await _secureStorage.write(key: _secureApiKeyStorageKey, value: key);
    } catch (error, stackTrace) {
      reportError(error, stackTrace, where: 'settings.apiKey.save');
    }
  }
}

final settingsBaseUrlProvider =
    StateNotifierProvider<SettingsBaseUrlNotifier, String>((ref) {
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

final weeklyGoalProvider = StateNotifierProvider<WeeklyGoalNotifier, int>((
  ref,
) {
  return WeeklyGoalNotifier(ref.watch(appSettingsStoreProvider));
});

class WeeklyGoalNotifier extends _StoredPreferenceNotifier<int> {
  WeeklyGoalNotifier(AppSettingsStore store)
    : super(store, 'weekly_watch_goal', 3);

  Future<void> saveGoal(int goal) => _save(goal);
}

/// Whether the Journal screen shows the sortable/drag-reorder table view
/// (true) or the month-grouped card view (false, default).
final journalViewModeProvider =
    StateNotifierProvider<JournalViewModeNotifier, bool>((ref) {
      return JournalViewModeNotifier(ref.watch(appSettingsStoreProvider));
    });

class JournalViewModeNotifier extends _StoredPreferenceNotifier<bool> {
  JournalViewModeNotifier(AppSettingsStore store)
    : super(store, 'journal_table_view', false);

  Future<void> setTableView(bool isTableView) => _save(isTableView);
}

/// The language the UI is rendered in, as a bare language code (`'tr'`, `'en'`)
/// or `null` to follow the device's own setting.
///
/// `null` is both the default and a value the user can explicitly choose, so
/// "System" survives a restart the same way an explicit language does: writing
/// `null` stores a null under the key rather than removing it.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.watch(appSettingsStoreProvider));
});

/// Every language the app ships translations for. Order is the order the
/// picker lists them in; [supportedLocales] is derived from this so adding a
/// language means adding one entry here plus one `.arb` file.
const supportedLanguageCodes = <String>['tr', 'en'];

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._store) : super(null) {
    unawaited(_load());
  }

  final AppSettingsStore _store;

  static const _key = 'app_language';

  /// Not a [_StoredPreferenceNotifier] subclass: that base class treats a
  /// stored `null` as "nothing saved, keep the default", which is exactly the
  /// value this preference needs to be able to persist.
  Future<void> _load() async {
    await _store.ensureLoaded();
    final code = _store.read<String>(_key);
    if (code != null && supportedLanguageCodes.contains(code)) {
      state = Locale(code);
    }
  }

  /// [locale] of `null` means "follow the system language".
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await _store.write(_key, locale?.languageCode);
  }
}

/// The country streaming availability is looked up for, as an ISO-3166-1 code,
/// or `null` to follow the device.
///
/// Kept separate from [localeProvider] because the two answer different
/// questions: language decides what the UI reads like, country decides what
/// Netflix carries. A Turkish speaker living in Germany wants the German
/// catalogue.
final watchRegionProvider = StateNotifierProvider<WatchRegionNotifier, String?>(
  (ref) {
    return WatchRegionNotifier(ref.watch(appSettingsStoreProvider));
  },
);

class WatchRegionNotifier extends StateNotifier<String?> {
  WatchRegionNotifier(this._store) : super(null) {
    unawaited(_load());
  }

  final AppSettingsStore _store;

  static const _key = 'watch_region';

  /// Not a [_StoredPreferenceNotifier] subclass, for exactly the reason
  /// [LocaleNotifier] isn't: that base class reads a stored `null` as "nothing
  /// saved, keep the default", and here `null` is a value the user can pick
  /// ("Automatic") which has to survive a restart.
  Future<void> _load() async {
    await _store.ensureLoaded();
    final stored = _store.read<String>(_key);
    // Validated by shape, not against kWatchRegions: a user whose country was
    // never in that curated list must not lose their choice if the list is
    // later edited.
    if (stored != null && RegExp(r'^[A-Z]{2}$').hasMatch(stored)) {
      state = stored;
    }
  }

  /// [region] of `null` means "follow the device".
  Future<void> setRegion(String? region) async {
    state = region;
    await _store.write(_key, region);
  }
}

/// The region actually used for lookups.
///
/// Explicit choice wins; then the device's country; then a guess derived from
/// the *effective app language*. That last step deliberately does not mirror
/// [resolveAppLocale]'s "fall back to Turkish because it is the template
/// language" rule — doing so would show Turkish catalogues to an
/// English-speaking user whose device reports no country at all.
final effectiveWatchRegionProvider = Provider<String>((ref) {
  final override = ref.watch(watchRegionProvider);
  if (override != null) return override;

  final fromDevice = deviceCountryCode();
  if (fromDevice != null) return fromDevice;

  return resolveAppLocale(ref.watch(localeProvider)).languageCode == 'tr'
      ? 'TR'
      : 'US';
});

/// Codes the picker offers: the curated list plus whatever the device reports,
/// so a user outside the curated set can still see and keep their own country.
List<String> watchRegionOptions() {
  final codes = {...kWatchRegions.keys};
  final fromDevice = deviceCountryCode();
  if (fromDevice != null) codes.add(fromDevice);
  final sorted = codes.toList()
    ..sort(
      (a, b) => watchRegionLabel(
        a,
      ).toLowerCase().compareTo(watchRegionLabel(b).toLowerCase()),
    );
  return sorted;
}

final dynamicBackgroundEnabledProvider =
    StateNotifierProvider<DynamicBackgroundEnabledNotifier, bool>((ref) {
      return DynamicBackgroundEnabledNotifier(
        ref.watch(appSettingsStoreProvider),
      );
    });

class DynamicBackgroundEnabledNotifier extends _StoredPreferenceNotifier<bool> {
  DynamicBackgroundEnabledNotifier(AppSettingsStore store)
    : super(store, 'dynamic_background_enabled', true);

  Future<void> setEnabled(bool enabled) => _save(enabled);
}

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletedNotifier, bool>((ref) {
      return OnboardingCompletedNotifier(ref.watch(appSettingsStoreProvider));
    });

class OnboardingCompletedNotifier extends _StoredPreferenceNotifier<bool> {
  OnboardingCompletedNotifier(AppSettingsStore store)
    : super(store, 'onboarding_completed', false);

  Future<void> setCompleted(bool completed) => _save(completed);
}
