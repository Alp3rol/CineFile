import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/journal/models/diary_log_model.dart';
import '../utils/safe_parsers.dart';
import 'app_database.dart';
import 'movie_repository.dart';
import 'web_local_store.dart';

part 'watch_record_providers.dart';
part 'movie_settings_providers.dart';
part 'collection_providers.dart';
part 'follow_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// TMDb movie IDs and TV show IDs come from separate counters, so a movie and
// a show can legitimately share the same numeric tmdbId. Every place that
// used to key by tmdbId alone now keys by this (tmdbId, isTv) pair instead â€”
// otherwise adding one silently overwrites/aliases the other (see
// tables.dart's Movies.primaryKey comment for the full story).
typedef MovieKey = ({int tmdbId, bool isTv});

// --- IN-MEMORY PROVIDERS FOR WEB COMPATIBILITY ---
// Since sql.js is not loaded on Flutter Web without hosting setup,
// we use in-memory Riverpod lists to simulate database operations on Web.
final webWatchRecordsProvider = StateProvider<List<WatchRecord>>((ref) => []);
final webMovieSettingsProvider = StateProvider<Map<MovieKey, UserMovieSetting>>(
  (ref) => {},
);
final webMoviesProvider = StateProvider<Map<MovieKey, Movie>>(
  (ref) => Map.of(WebLocalStore.snapshot.movies),
);

// Stream provider to get watch records for a specific movie
