part of 'database_provider.dart';

final watchRecordServiceProvider = Provider<WatchRecordService>(
  WatchRecordService.new,
);

class WatchRecordDraft {
  final int movieId;
  final bool isTv;
  final DateTime watchDate;
  final String? watchPlace;
  final String? watchCompanion;
  final double rating;
  final String mood;
  final String? notes;
  final String? tags;
  final int episodeCount;
  final String movieTitle;
  final String? movieOriginalTitle;
  final String? moviePosterPath;
  final String? movieBackdropPath;
  final int? movieReleaseYear;
  final int? movieRuntime;
  final String? movieGenres;
  final String? movieDirector;
  final String? movieActors;
  final String? movieOverview;
  final int? movieTotalEpisodes;
  final bool isPublic;
  final bool isActivelyWatching;
  final int? lastWatchedEpisode;

  const WatchRecordDraft({
    required this.movieId,
    required this.isTv,
    required this.watchDate,
    this.watchPlace,
    this.watchCompanion,
    required this.rating,
    required this.mood,
    this.notes,
    this.tags,
    required this.episodeCount,
    required this.movieTitle,
    this.movieOriginalTitle,
    this.moviePosterPath,
    this.movieBackdropPath,
    this.movieReleaseYear,
    this.movieRuntime,
    this.movieGenres,
    this.movieDirector,
    this.movieActors,
    this.movieOverview,
    this.movieTotalEpisodes,
    required this.isPublic,
    required this.isActivelyWatching,
    this.lastWatchedEpisode,
  });
}

class WatchRecordService {
  final Ref _ref;

  WatchRecordService(this._ref);

  Future<int> create(WatchRecordDraft draft) async {
    final user = _ref.currentUser;
    if (user == null) {
      throw StateError('Sign-in is required to create a watch record');
    }

    final identity = resolveUserIdentity(_ref.read(userModelProvider), user);
    final firestore = _ref.read(firestoreProvider);
    final logRef = firestore.collection('logs').doc();
    final settingsRef = firestore
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .doc('${draft.movieId}_${draft.isTv}');

    var seed = 0;
    final settingsBefore = await settingsRef.get();
    if (settingsBefore.data()?['watchCount'] == null) {
      final existingLogs = await firestore
          .collection('logs')
          .where('userId', isEqualTo: user.uid)
          .where('movieId', isEqualTo: draft.movieId)
          .where('isTv', isEqualTo: draft.isTv)
          .get();
      for (final doc in existingLogs.docs) {
        final number = (doc.data()['watchNumber'] as num?)?.toInt() ?? 0;
        if (number > seed) {
          seed = number;
        }
      }
    }

    return firestore.runTransaction<int>((tx) async {
      final settingsSnap = await tx.get(settingsRef);
      final existing = settingsSnap.data();
      final previous = (existing?['watchCount'] as num?)?.toInt() ?? seed;
      final next = previous + 1;

      tx.set(logRef, {
        'id': logRef.id,
        'userId': user.uid,
        'username': identity.username,
        'userAvatarUrl': identity.avatarUrl,
        'movieId': draft.movieId,
        'isTv': draft.isTv,
        'watchDate': Timestamp.fromDate(draft.watchDate),
        'watchPlace': draft.watchPlace,
        'watchCompanion': draft.watchCompanion,
        'rating': draft.rating,
        'mood': draft.mood,
        'notes': draft.notes,
        'watchNumber': next,
        'tags': draft.tags,
        'episodeCount': draft.episodeCount,
        'createdAt': FieldValue.serverTimestamp(),
        'movieTitle': draft.movieTitle,
        'movieOriginalTitle': draft.movieOriginalTitle,
        'moviePosterPath': draft.moviePosterPath,
        'movieBackdropPath': draft.movieBackdropPath,
        'movieReleaseYear': draft.movieReleaseYear,
        'movieRuntime': draft.movieRuntime,
        'movieGenres': draft.movieGenres,
        'movieDirector': draft.movieDirector,
        'movieActors': draft.movieActors,
        'movieOverview': draft.movieOverview,
        'movieTotalEpisodes': draft.movieTotalEpisodes,
        'starredBy': <String>[],
        'commentCount': 0,
        'isPublic': draft.isPublic,
      });

      tx.set(settingsRef, {
        'movieId': draft.movieId,
        'isTv': draft.isTv,
        'watchCount': next,
        'isFavorite':
            existing?['isFavorite'] == true || existing?['isFavorite'] == 1,
        'isReWatchList':
            existing?['isReWatchList'] == true ||
            existing?['isReWatchList'] == 1,
        'personalRanking': existing?['personalRanking'],
        'personalNotes': existing?['personalNotes'],
        'personalTags': existing?['personalTags'],
        'updatedAt': FieldValue.serverTimestamp(),
        'isActivelyWatching': draft.isActivelyWatching,
        'lastWatchedEpisode': draft.lastWatchedEpisode,
      }, SetOptions(merge: true));
      return next;
    });
  }

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
    String userId,
    WatchRecord record,
  ) async {
    final firestore = _ref.read(firestoreProvider);
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

  Future<void> delete(WatchRecord record) async {
    final user = _ref.currentUser;

    if (user != null) {
      final logRef = await _resolveLogRef(user.uid, record);
      if (logRef == null) {
        throw Exception(
          'No matching Firestore log to delete (movieId: ${record.movieId})',
        );
      }
      await logRef.delete();

      // Recalculate movie settings progress for this user & movie/show in Firestore
      final remainingQuery = await _ref
          .read(firestoreProvider)
          .collection('logs')
          .where('userId', isEqualTo: user.uid)
          .where('movieId', isEqualTo: record.movieId)
          .where('isTv', isEqualTo: record.isTv)
          .get();

      final settingsRef = _ref
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

    await _ref.read(movieRepositoryProvider).deleteWatchRecordLocal(record);
  }

  Future<void> update(
    WatchRecord record, {
    DateTime? watchDate,
    int? episodeCount,
    bool? isPublic,
  }) async {
    final user = _ref.currentUser;

    if (user != null) {
      final logRef = await _resolveLogRef(user.uid, record);
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

    await _ref
        .read(movieRepositoryProvider)
        .updateWatchRecordLocal(
          record,
          watchDate: watchDate,
          episodeCount: episodeCount,
          isPublic: isPublic,
        );
  }
}

Future<void> deleteWatchRecord(WidgetRef ref, WatchRecord record) =>
    ref.read(watchRecordServiceProvider).delete(record);

Future<void> updateWatchRecord(
  WidgetRef ref,
  WatchRecord record, {
  DateTime? watchDate,
  int? episodeCount,
  bool? isPublic,
}) => ref
    .read(watchRecordServiceProvider)
    .update(
      record,
      watchDate: watchDate,
      episodeCount: episodeCount,
      isPublic: isPublic,
    );
