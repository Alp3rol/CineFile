import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../observability/error_reporting.dart';

/// Single owner of `app_settings.json`, the small key/value file holding the
/// user's non-synced preferences (TMDb base URL, weekly goal, journal view
/// mode, reminder + dynamic-background toggles).
///
/// Every preference used to be its own StateNotifier with its own copy of the
/// file path getter, and each one did an independent read-modify-write of the
/// whole document on save. Flipping two toggles in quick succession therefore
/// lost one of them: the second save had already read the file before the
/// first one wrote it, so it wrote back a map that still had the old value.
///
/// Here the document is read once, cached in memory, and every write goes
/// through [_writeQueue] so two saves can never interleave.
///
/// The whole thing is a no-op on web, where there is no writable application
/// documents directory — matching the previous behaviour (preferences simply
/// don't persist across reloads there).
class AppSettingsStore {
  AppSettingsStore();

  Map<String, dynamic> _cache = {};
  Future<void>? _loaded;
  Future<void> _writeQueue = Future.value();

  Future<File?> _file() async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'app_settings.json'));
  }

  /// Reads the file at most once per app run; concurrent callers await the
  /// same future rather than each triggering their own read.
  Future<void> ensureLoaded() {
    return _loaded ??= () async {
      try {
        final file = await _file();
        if (file != null && await file.exists()) {
          final decoded = jsonDecode(await file.readAsString());
          if (decoded is Map<String, dynamic>) _cache = decoded;
        }
      } catch (error, stackTrace) {
        reportError(error, stackTrace, where: 'appSettings.load');
      }
    }();
  }

  T? read<T>(String key) {
    final value = _cache[key];
    return value is T ? value : null;
  }

  /// Updates [key] in memory immediately and persists it. Writes are chained
  /// onto [_writeQueue], so a burst of saves is applied in order and the file
  /// always ends up matching [_cache].
  Future<void> write(String key, Object? value) {
    _cache = {..._cache, key: value};
    if (kIsWeb) return Future.value();

    final snapshot = _cache;
    _writeQueue = _writeQueue.then((_) async {
      try {
        final file = await _file();
        if (file != null) await file.writeAsString(jsonEncode(snapshot));
      } catch (error, stackTrace) {
        reportError(error, stackTrace, where: 'appSettings.write.$key');
      }
    });
    return _writeQueue;
  }

  /// Removes [key] entirely — used by the one-time migration that moved the
  /// TMDb API key out of this plaintext file into secure storage.
  Future<void> remove(String key) {
    final next = {..._cache}..remove(key);
    _cache = next;
    if (kIsWeb) return Future.value();

    _writeQueue = _writeQueue.then((_) async {
      try {
        final file = await _file();
        if (file != null) await file.writeAsString(jsonEncode(next));
      } catch (error, stackTrace) {
        reportError(error, stackTrace, where: 'appSettings.remove.$key');
      }
    });
    return _writeQueue;
  }
}
