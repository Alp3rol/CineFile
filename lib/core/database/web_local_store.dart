import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_database.dart';
import '../observability/error_reporting.dart';

/// Persistent browser storage for the data that has no Firestore home.
///
/// Watch history and per-title settings are synced through Firestore for a
/// signed-in user. Custom collections and their cached movie metadata are
/// device-local, so keeping them only in Riverpod state made a browser refresh
/// destructive. This store serializes those three related tables as one JSON
/// snapshot, using the same generated model JSON as backup/restore.
class WebLocalSnapshot {
  const WebLocalSnapshot({
    required this.movies,
    required this.customLists,
    required this.customListMovies,
  });

  const WebLocalSnapshot.empty()
    : movies = const {},
      customLists = const {},
      customListMovies = const [];

  final Map<({int tmdbId, bool isTv}), Movie> movies;
  final Map<int, CustomList> customLists;
  final List<CustomListMovie> customListMovies;
}

class UnsupportedWebLocalSnapshotVersion implements Exception {
  const UnsupportedWebLocalSnapshotVersion(this.version);

  final Object? version;

  @override
  String toString() => 'Unsupported web collection snapshot version: $version';
}

class WebLocalStoreWriteException implements Exception {
  const WebLocalStoreWriteException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null ? message : '$message: $cause';
}

class WebLocalSnapshotCodec {
  const WebLocalSnapshotCodec();

  static const currentVersion = 1;

  String encode(WebLocalSnapshot snapshot) => jsonEncode({
    'version': currentVersion,
    'movies': snapshot.movies.values.map((movie) => movie.toJson()).toList(),
    'custom_lists': snapshot.customLists.values
        .map((list) => list.toJson())
        .toList(),
    'custom_list_movies': snapshot.customListMovies
        .map((relation) => relation.toJson())
        .toList(),
  });

  WebLocalSnapshot decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Web collection snapshot must be an object.');
    }
    final version = decoded['version'];
    if (version != currentVersion) {
      throw UnsupportedWebLocalSnapshotVersion(version);
    }

    final movies = <({int tmdbId, bool isTv}), Movie>{};
    for (final value in (decoded['movies'] as List<dynamic>? ?? const [])) {
      if (value is! Map<String, dynamic>) continue;
      final movie = Movie.fromJson(value);
      movies[(tmdbId: movie.tmdbId, isTv: movie.isTv)] = movie;
    }

    final lists = <int, CustomList>{};
    for (final value
        in (decoded['custom_lists'] as List<dynamic>? ?? const [])) {
      if (value is! Map<String, dynamic>) continue;
      final list = CustomList.fromJson(value);
      lists[list.id] = list;
    }

    final relations = <CustomListMovie>[];
    for (final value
        in (decoded['custom_list_movies'] as List<dynamic>? ?? const [])) {
      if (value is Map<String, dynamic>) {
        relations.add(CustomListMovie.fromJson(value));
      }
    }

    return WebLocalSnapshot(
      movies: movies,
      customLists: lists,
      customListMovies: relations,
    );
  }

  WebLocalSnapshot decodeOrFallback(
    String raw, {
    required WebLocalSnapshot fallback,
    void Function(Object error)? onError,
  }) {
    try {
      return decode(raw);
    } catch (error) {
      onError?.call(error);
      return fallback;
    }
  }
}

class WebLocalSnapshotWriter {
  const WebLocalSnapshotWriter(this.codec);

  final WebLocalSnapshotCodec codec;

  Future<WebLocalSnapshot> persist(
    WebLocalSnapshot snapshot,
    Future<bool> Function(String encoded) write,
  ) async {
    try {
      final stored = await write(codec.encode(snapshot));
      if (!stored) {
        throw const WebLocalStoreWriteException(
          'Browser storage rejected the collection snapshot, possibly because its quota is full.',
        );
      }
      return snapshot;
    } on WebLocalStoreWriteException {
      rethrow;
    } catch (error) {
      throw WebLocalStoreWriteException(
        'Could not persist the web collection snapshot',
        error,
      );
    }
  }
}

class WebLocalStore {
  WebLocalStore._();

  static const _storageKey = 'cinefile_web_collections_v1';
  static const _codec = WebLocalSnapshotCodec();
  static const _writer = WebLocalSnapshotWriter(_codec);
  static WebLocalSnapshot _snapshot = const WebLocalSnapshot.empty();
  static Future<void> _writeQueue = Future.value();

  static WebLocalSnapshot get snapshot => _snapshot;

  /// Must complete before ProviderScope is created so provider initial values
  /// are hydrated synchronously and the UI never flashes an empty collection.
  static Future<void> initialize() async {
    if (!kIsWeb) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      _snapshot = _codec.decodeOrFallback(
        raw,
        fallback: _snapshot,
        onError: (error) =>
            reportError(error, null, where: 'webLocalStore.decode'),
      );
    } catch (error, stackTrace) {
      // A malformed/blocked local store must not prevent the app from opening.
      // Keep the last valid in-memory snapshot and let the next successful
      // write replace the browser value.
      reportError(error, stackTrace, where: 'webLocalStore.load');
    }
  }

  static Future<void> save({
    required Map<({int tmdbId, bool isTv}), Movie> movies,
    required Map<int, CustomList> customLists,
    required List<CustomListMovie> customListMovies,
  }) async {
    if (!kIsWeb) return;
    final next = WebLocalSnapshot(
      movies: Map.unmodifiable(movies),
      customLists: Map.unmodifiable(customLists),
      customListMovies: List.unmodifiable(customListMovies),
    );

    // CRUD calls can overlap (for example during rapid drag-and-drop). Queue
    // complete snapshots so an older, slower write can never land after the
    // newest state and resurrect a removed item on the next reload.
    final operation = _writeQueue.then((_) async {
      try {
        final preferences = await SharedPreferences.getInstance();
        _snapshot = await _writer.persist(
          next,
          (encoded) => preferences.setString(_storageKey, encoded),
        );
      } catch (error, stackTrace) {
        reportError(error, stackTrace, where: 'webLocalStore.save');
        rethrow;
      }
    });
    // The returned [operation] still completes with the error. This secondary
    // handler only repairs the internal queue so one failed browser write does
    // not prevent every later snapshot from being attempted.
    _writeQueue = operation.catchError((_) {});
    return operation;
  }
}
