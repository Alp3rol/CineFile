import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../widgets/premium_toast.dart';
import 'app_database.dart';
import 'database_provider.dart';

// Bumps the "which episode am I on" progress counter for a show the user is
// actively tracking, WITHOUT creating a diary/journal log entry. Used by
// every quick-add "+" in the app (Home's ActivelyWatchingRow and hero
// carousel, Journal's QuickAdvanceTag) — creating a full diary log entry per
// tap (an earlier version of this did, see git history) made the diary look
// like a brand-new show was being added every time someone caught up on a
// few episodes, no matter which screen the "+" was tapped from.
Future<void> advanceEpisodeProgress({
  required WidgetRef ref,
  required Movie movie,
  required UserMovieSetting setting,
}) async {
  final totalEpisodes = movie.totalEpisodes;
  final lastWatched = setting.lastWatchedEpisode ?? 0;
  final nextEpisode = totalEpisodes != null ? (lastWatched + 1).clamp(1, totalEpisodes) : lastWatched + 1;
  final newIsActivelyWatching = totalEpisodes == null || nextEpisode < totalEpisodes;

  await writeEpisodeProgressSettings(
    ref: ref,
    movie: movie,
    setting: setting,
    lastWatchedEpisode: nextEpisode,
    isActivelyWatching: newIsActivelyWatching,
  );
}

// Directly (over)writes a show's episode-progress fields (isActivelyWatching
// / lastWatchedEpisode) to explicit values, without any +1 advancement
// logic. Shared by advanceEpisodeProgress above and the duplicate-cleanup
// tool (see duplicate_cleanup.dart), which needs to restore a show's
// progress counter after removing extra log entries — deleteWatchRecord's
// own recompute only sums episodeCount within the single latest surviving
// record, so it can't be trusted to reconstruct multi-tap progress on its
// own.
Future<void> writeEpisodeProgressSettings({
  required WidgetRef ref,
  required Movie movie,
  required UserMovieSetting setting,
  required int? lastWatchedEpisode,
  required bool isActivelyWatching,
}) async {
  final movieId = movie.tmdbId;
  final isTv = movie.isTv;
  final now = DateTime.now();

  // --- Firebase Firestore path (primary for authenticated users, all platforms) ---
  final authState = ref.read(authStateProvider);
  final user = authState.value;

  if (user != null) {
    final settingsRef = ref.read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .doc('${movieId}_$isTv');

    final settingsDoc = await settingsRef.get();
    final existingSetting = settingsDoc.data();

    await settingsRef.set({
      'movieId': movieId,
      'isTv': isTv,
      'isFavorite': existingSetting?['isFavorite'] ?? setting.isFavorite,
      'isReWatchList': existingSetting?['isReWatchList'] ?? setting.isReWatchList,
      'personalRanking': existingSetting?['personalRanking'] ?? setting.personalRanking,
      'personalNotes': existingSetting?['personalNotes'] ?? setting.personalNotes,
      'personalTags': existingSetting?['personalTags'] ?? setting.personalTags,
      'updatedAt': FieldValue.serverTimestamp(),
      'isActivelyWatching': isActivelyWatching,
      'lastWatchedEpisode': lastWatchedEpisode,
    }, SetOptions(merge: true));

    return;
  }

  // --- Fallback for unauthenticated users ---
  if (kIsWeb) {
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
      isActivelyWatching: isActivelyWatching,
      lastWatchedEpisode: lastWatchedEpisode,
    );
    ref.read(webMovieSettingsProvider.notifier).state = updatedSettings;
    return;
  }

  // --- Fallback: local Drift/SQLite path (offline / unauthenticated / native) ---
  final db = ref.read(databaseProvider);
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
          isActivelyWatching: isActivelyWatching,
          lastWatchedEpisode: lastWatchedEpisode,
        ),
      );
}

// UI-facing convenience wrapper around advanceEpisodeProgress shared by every
// quick-add "+" tap handler (Home's ActivelyWatchingRow and hero carousel,
// Journal's QuickAdvanceTag), so the try/catch/toast logic exists in exactly
// one place instead of being copy-pasted per call site.
Future<void> advanceEpisodeWithToast(BuildContext context, WidgetRef ref, ActivelyWatchingShow show) async {
  try {
    await advanceEpisodeProgress(ref: ref, movie: show.movie, setting: show.setting);
  } catch (e) {
    debugPrint('advanceEpisodeWithToast failed: $e');
    if (context.mounted) {
      showPremiumToast(context, 'Bölüm kaydedilemedi: $e', isError: true);
    }
  }
}
