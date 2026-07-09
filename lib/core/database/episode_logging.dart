import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'app_database.dart';
import 'database_provider.dart';

// Logs the next episode for a show the user is actively tracking (see
// UserMovieSettings.isActivelyWatching), used by the Home/Journal quick-add
// "Aktif İzlediklerin" sections. Mirrors the same active-tracking bookkeeping
// as AddWatchRecordSheet._saveRecord (episodeCount is always 1 here since
// this always advances by exactly one episode), kept as a single shared
// function so the two call sites can't drift out of sync.
Future<void> logNextEpisode({
  required WidgetRef ref,
  required Movie movie,
  required UserMovieSetting setting,
  required double rating,
}) async {
  final movieId = movie.tmdbId;
  final isTv = movie.isTv;
  final totalEpisodes = movie.totalEpisodes;
  final lastWatched = setting.lastWatchedEpisode ?? 0;
  final nextEpisode = totalEpisodes != null ? (lastWatched + 1).clamp(1, totalEpisodes) : lastWatched + 1;
  final newIsActivelyWatching = totalEpisodes == null || nextEpisode < totalEpisodes;
  final now = DateTime.now();

  if (kIsWeb) {
    final currentList = ref.read(webWatchRecordsProvider);
    final nextId = currentList.isEmpty ? 1 : currentList.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
    final watchNumber = currentList.where((r) => r.movieId == movieId && r.isTv == isTv).length + 1;

    final newRecord = WatchRecord(
      id: nextId,
      movieId: movieId,
      isTv: isTv,
      watchDate: now,
      rating: rating,
      watchNumber: watchNumber,
      createdAt: now,
      episodeCount: 1,
    );
    ref.read(webWatchRecordsProvider.notifier).state = [...currentList, newRecord];

    final key = (tmdbId: movieId, isTv: isTv);
    final currentSettings = ref.read(webMovieSettingsProvider);
    final updatedSettings = Map<MovieKey, UserMovieSetting>.from(currentSettings);
    updatedSettings[key] = UserMovieSetting(
      tmdbId: movieId,
      isTv: isTv,
      isFavorite: setting.isFavorite,
      isReWatchList: setting.isReWatchList,
      personalRanking: setting.personalRanking,
      personalNotes: setting.personalNotes,
      personalTags: setting.personalTags,
      updatedAt: now,
      isActivelyWatching: newIsActivelyWatching,
      lastWatchedEpisode: nextEpisode,
    );
    ref.read(webMovieSettingsProvider.notifier).state = updatedSettings;
    return;
  }

  final db = ref.read(databaseProvider);
  final existingRecords =
      await (db.select(db.watchRecords)..where((t) => t.movieId.equals(movieId) & t.isTv.equals(isTv))).get();
  final watchNumber = existingRecords.length + 1;

  await db.into(db.watchRecords).insert(
        WatchRecordsCompanion.insert(
          movieId: movieId,
          isTv: drift.Value(isTv),
          watchDate: now,
          rating: rating,
          watchNumber: watchNumber,
          episodeCount: const drift.Value(1),
        ),
      );

  await db.into(db.userMovieSettings).insertOnConflictUpdate(
        UserMovieSetting(
          tmdbId: movieId,
          isTv: isTv,
          isFavorite: setting.isFavorite,
          isReWatchList: setting.isReWatchList,
          personalRanking: setting.personalRanking,
          personalNotes: setting.personalNotes,
          personalTags: setting.personalTags,
          updatedAt: now,
          isActivelyWatching: newIsActivelyWatching,
          lastWatchedEpisode: nextEpisode,
        ),
      );
}
