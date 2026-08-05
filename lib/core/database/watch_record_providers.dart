part of 'database_provider.dart';

final watchRecordsForMovieProvider =
    StreamProvider.family<List<WatchRecord>, MovieKey>((ref, key) {
      final authState = ref.watch(authStateProvider);
      final user = authState.value;
      if (user == null) {
        return Stream.value(<WatchRecord>[]);
      }

      return ref
          .read(firestoreProvider)
          .collection('logs')
          .where('userId', isEqualTo: user.uid)
          .where('movieId', isEqualTo: key.tmdbId)
          .where('isTv', isEqualTo: key.isTv)
          .snapshots()
          .map((snapshot) {
            final logs = snapshot.docs
                .map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id))
                .toList();
            // Sort descending by watchDate
            logs.sort((a, b) => b.watchDate.compareTo(a.watchDate));
            return logs
                .map((log) => log.toWatchRecordWithMovie().record)
                .toList();
          });
    });

// Reactive settings lookup unifying the web-guest in-memory map and the

class WatchRecordWithMovie {
  final WatchRecord record;
  final Movie movie;
  final UserMovieSetting? setting;
  WatchRecordWithMovie(this.record, this.movie, {this.setting});
}

/// How many of a profile's most recent watch records the profile screens load.
/// Generous enough for the "son izledikleri" grid and the featured showcase,
/// bounded so viewing an active user's profile isn't an unbounded read of
/// their entire history on every snapshot.
const int kProfileWatchRecordLimit = 100;

// Stream provider to get watch records for any user with movie details.
// The owner sees all of their own logs (public + private) â€” that satisfies
// firestore.rules' `auth.uid == resource.data.userId` clause. Viewing
// someone else's profile must filter to isPublic == true client-side too:
// Firestore denies a whole collection query if it could return documents
// the rules would reject, and the read rule's `isPublic == true` branch is
// the only one a non-owner can satisfy, so the query itself must include
// that filter for a stranger's profile.
final watchRecordsForUserProvider =
    StreamProvider.family<List<WatchRecordWithMovie>, String>((ref, userId) {
      final currentUserId = ref.watch(authStateProvider).value?.uid;
      final isOwnProfile = currentUserId == userId;

      var query = ref
          .read(firestoreProvider)
          .collection('logs')
          .where('userId', isEqualTo: userId);
      if (!isOwnProfile) {
        query = query.where('isPublic', isEqualTo: true);
      }

      // A profile screen shows a recent-activity grid, not an entire life's worth
      // of history, so the query is bounded. Ordering happens server-side because
      // a `limit` without one would return an arbitrary subset rather than the
      // newest entries (see firestore.indexes.json for the composite indexes this
      // needs). The list is still sorted again below: Firestore's ordering is
      // authoritative for *which* documents come back, but re-sorting keeps the
      // output stable regardless.
      return query
          .orderBy('watchDate', descending: true)
          .limit(kProfileWatchRecordLimit)
          .snapshots()
          .asyncMap((snapshot) async {
            final logs = snapshot.docs
                .map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id))
                .toList();
            // Sort descending by watchDate
            logs.sort((a, b) => b.watchDate.compareTo(a.watchDate));

            // One query for the whole settings collection instead of a per-log
            // document read. The previous shape issued one `get()` inside the
            // loop, so rendering a 200-entry profile cost 200 extra document
            // reads â€” repeated in full on every snapshot the listener emitted.
            final settingsMap = _movieSettingsMapFromSnapshot(
              await ref
                  .read(firestoreProvider)
                  .collection('users')
                  .doc(userId)
                  .collection('movie_settings')
                  .get(),
            );

            return logs.map((log) {
              final wRecord = log.toWatchRecordWithMovie();
              return WatchRecordWithMovie(
                wRecord.record,
                wRecord.movie,
                setting: settingsMap[(tmdbId: log.movieId, isTv: log.isTv)],
              );
            }).toList();
          });
    });

Map<MovieKey, UserMovieSetting> _movieSettingsMapFromSnapshot(
  QuerySnapshot<Map<String, dynamic>> snapshot,
) {
  final map = <MovieKey, UserMovieSetting>{};
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final movieId = parseInt(data['movieId']);
    final isTv = parseBool(data['isTv']);
    if (movieId == null) continue;
    map[(tmdbId: movieId, isTv: isTv)] = UserMovieSetting(
      tmdbId: movieId,
      isTv: isTv,
      isFavorite: parseBool(data['isFavorite']),
      isReWatchList: parseBool(data['isReWatchList']),
      personalRanking: parseInt(data['personalRanking']),
      personalNotes: data['personalNotes'] as String?,
      personalTags: data['personalTags'] as String?,
      updatedAt: parseDateTime(data['updatedAt']),
      isActivelyWatching: parseBool(data['isActivelyWatching']),
      lastWatchedEpisode: parseInt(data['lastWatchedEpisode']),
      lastEpisodeProgressAt: parseNullableDateTime(
        data['lastEpisodeProgressAt'],
      ),
    );
  }
  return map;
}

// Reactive map of the current user's per-movie settings, keyed by

// logged in user). Manually merges two independent Firestore listeners
// (logs + movie_settings) into one output stream that re-emits whenever
// EITHER source updates, without ever tearing down/recreating either
// subscription â€” combining them via ref.watch(allMovieSettingsProvider)
// instead would rebuild this whole provider (and its logs subscription) on
// every settings change, which briefly resets consumers to a loading state
// and shows up as a visible flicker/jump in the Journal list.
final allWatchRecordsProvider = StreamProvider<List<WatchRecordWithMovie>>((
  ref,
) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<WatchRecordWithMovie>[]);
  }

  final controller = StreamController<List<WatchRecordWithMovie>>();
  var latestLogs = <DiaryLogModel>[];
  var latestSettings = const <MovieKey, UserMovieSetting>{};
  var hasLogs = false;

  void emit() {
    // Settings may not have loaded yet on the very first tick â€” that's fine,
    // records just render with a null setting briefly. Logs are the primary
    // data source, so wait for at least one logs snapshot before emitting.
    if (!hasLogs) return;
    final sorted = [...latestLogs]
      ..sort((a, b) => b.watchDate.compareTo(a.watchDate));
    final list = sorted.map((log) {
      final key = (tmdbId: log.movieId, isTv: log.isTv);
      final wRecord = log.toWatchRecordWithMovie();
      return WatchRecordWithMovie(
        wRecord.record,
        wRecord.movie,
        setting: latestSettings[key],
      );
    }).toList();
    if (!controller.isClosed) controller.add(list);
  }

  final logsSub = ref
      .read(firestoreProvider)
      .collection('logs')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .listen(
        (snapshot) {
          latestLogs = snapshot.docs
              .map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id))
              .toList();
          hasLogs = true;
          emit();
        },
        onError: (Object e, StackTrace st) {
          if (!controller.isClosed) controller.addError(e, st);
        },
      );

  final settingsSub = ref
      .read(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('movie_settings')
      .snapshots()
      .listen(
        (snapshot) {
          latestSettings = _movieSettingsMapFromSnapshot(snapshot);
          emit();
        },
        onError: (Object e, StackTrace st) {
          if (!controller.isClosed) controller.addError(e, st);
        },
      );

  ref.onDispose(() {
    logsSub.cancel();
    settingsSub.cancel();
    controller.close();
  });

  return controller.stream;
});

// Stream provider to get all followed user IDs for the current user

// --- WATCH RECORD ACTIONS ---

/// Resolves the Firestore `logs` document a [WatchRecord] came from.
///
/// Records materialised from Firestore carry the document id in
/// [WatchRecord.remoteId], so this is normally a direct reference with no
/// lookup at all. The fallback exists only for rows that predate that field
/// (restored from an older backup, or written by an older build still on the
/// device): it matches on the id hash the old code used, and deliberately
/// does NOT fall back further to matching on
/// (watchDate, watchNumber, episodeCount) â€” that tuple is not unique for a
/// show binged in one sitting, so it could resolve to a different record than
/// the one the user acted on and delete the wrong entry.
///
/// Returns null when nothing matches, which callers surface as an error
/// rather than silently doing nothing.
Future<DocumentReference<Map<String, dynamic>>?> _resolveLogRef(
  WidgetRef ref,
  String userId,
  WatchRecord record,
) async {
  final firestore = ref.read(firestoreProvider);
  final remoteId = record.remoteId;
  if (remoteId != null && remoteId.isNotEmpty) {
    return firestore.collection('logs').doc(remoteId);
  }

  final query = await firestore
      .collection('logs')
      .where('userId', isEqualTo: userId)
      .where('movieId', isEqualTo: record.movieId)
      .where('isTv', isEqualTo: record.isTv)
      .get();

  for (final doc in query.docs) {
    if (doc.id.hashCode == record.id) return doc.reference;
  }
  return null;
}

Future<void> deleteWatchRecord(WidgetRef ref, WatchRecord record) async {
  final user = ref.currentUser;

  if (user != null) {
    final logRef = await _resolveLogRef(ref, user.uid, record);
    if (logRef == null) {
      throw Exception(
        'No matching Firestore log to delete (movieId: ${record.movieId})',
      );
    }
    await logRef.delete();

    // Recalculate movie settings progress for this user & movie/show in Firestore
    final remainingQuery = await ref
        .read(firestoreProvider)
        .collection('logs')
        .where('userId', isEqualTo: user.uid)
        .where('movieId', isEqualTo: record.movieId)
        .where('isTv', isEqualTo: record.isTv)
        .get();

    final settingsRef = ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .doc('${record.movieId}_${record.isTv}');

    if (remainingQuery.docs.isEmpty) {
      await settingsRef.set({
        'isActivelyWatching': false,
        'lastWatchedEpisode': null,
      }, SetOptions(merge: true));
    } else {
      final remainingLogs = remainingQuery.docs
          .map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id))
          .toList();
      remainingLogs.sort((a, b) => b.watchDate.compareTo(a.watchDate));

      final latestLog = remainingLogs.first;
      final latestWatchNumber = latestLog.watchNumber;

      final currentEpisodeProgress = remainingLogs
          .where((log) => log.watchNumber == latestWatchNumber)
          .fold<int>(0, (acc, log) => acc + log.episodeCount);

      final totalEpisodes = latestLog.totalEpisodes;
      final newIsActivelyWatching =
          totalEpisodes == null || currentEpisodeProgress < totalEpisodes;

      await settingsRef.set({
        'isActivelyWatching': newIsActivelyWatching,
        'lastWatchedEpisode': currentEpisodeProgress,
      }, SetOptions(merge: true));
    }
    return;
  }

  await ref.read(movieRepositoryProvider).deleteWatchRecordLocal(record);
}

Future<void> updateWatchRecord(
  WidgetRef ref,
  WatchRecord record, {
  DateTime? watchDate,
  int? episodeCount,
  bool? isPublic,
}) async {
  final user = ref.currentUser;

  if (user != null) {
    final logRef = await _resolveLogRef(ref, user.uid, record);
    if (logRef == null) {
      throw Exception(
        'No matching Firestore log to update (movieId: ${record.movieId})',
      );
    }

    final updates = <String, dynamic>{};
    if (watchDate != null) {
      updates['watchDate'] = Timestamp.fromDate(watchDate);
    }
    if (episodeCount != null) {
      updates['episodeCount'] = episodeCount;
    }
    if (isPublic != null) {
      updates['isPublic'] = isPublic;
    }

    if (updates.isNotEmpty) {
      await logRef.update(updates);
    }
    return;
  }

  await ref
      .read(movieRepositoryProvider)
      .updateWatchRecordLocal(
        record,
        watchDate: watchDate,
        episodeCount: episodeCount,
        isPublic: isPublic,
      );
}
