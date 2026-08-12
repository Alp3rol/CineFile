import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../domain/import_duplicate_policy.dart';
import '../domain/letterboxd_csv_parser.dart';
import '../domain/tmdb_import_matcher.dart';

final letterboxdImportServiceProvider = Provider<LetterboxdImportService>(
  LetterboxdImportService.new,
);

class LetterboxdImportResult {
  const LetterboxdImportResult({
    required this.added,
    required this.merged,
    required this.skipped,
  });

  final int added;
  final int merged;
  final int skipped;
}

class LetterboxdImportService {
  LetterboxdImportService(this._ref);
  final Ref _ref;

  static const maxRowsPerImport = 200;

  Future<LetterboxdImportResult> execute({
    required List<LetterboxdPreviewRow> rows,
    required Map<int, ImportRowMatch> matches,
    required Map<int, ImportDuplicateConflict> conflicts,
  }) async {
    final user = _ref.currentUser;
    if (user == null) throw StateError('Sign-in is required');

    final actionable = rows
        .where((row) => row.isValid && matches[row.rowNumber]?.selected != null)
        .toList();
    if (actionable.length > maxRowsPerImport) {
      throw StateError('Import contains more than $maxRowsPerImport rows');
    }

    final unresolved = rows.any(
      (row) =>
          row.isValid &&
          matches[row.rowNumber]?.status != ImportMatchStatus.matched,
    );
    if (unresolved) throw StateError('Every valid row must be matched');

    final firestore = _ref.read(firestoreProvider);
    final batch = firestore.batch();
    final identity = resolveUserIdentity(_ref.read(userModelProvider), user);
    final existing = await _ref.read(allWatchRecordsProvider.future);
    final nextWatchNumbers = <String, int>{};
    for (final item in existing) {
      final key = '${item.record.movieId}:${item.record.isTv}';
      final current = nextWatchNumbers[key] ?? 0;
      if (item.record.watchNumber > current) {
        nextWatchNumbers[key] = item.record.watchNumber;
      }
    }

    var added = 0;
    var merged = 0;
    var skipped = 0;
    final settingsUpdates = <String, ({int movieId, bool isTv, int count})>{};

    for (final row in actionable) {
      final candidate = matches[row.rowNumber]!.selected!;
      final conflict = conflicts[row.rowNumber];
      final resolution = conflict?.resolution;
      if (resolution == ImportDuplicateResolution.skip) {
        skipped++;
        continue;
      }
      if (resolution == ImportDuplicateResolution.merge) {
        final target = conflict!.existingRecordIds
            .where((id) => id.isNotEmpty)
            .firstOrNull;
        if (target == null) throw StateError('Merge target is unavailable');
        if (row.rating != null) {
          batch.update(firestore.collection('logs').doc(target), {
            'rating': row.rating! * 2,
          });
        }
        merged++;
        continue;
      }

      final key = '${candidate.tmdbId}:${candidate.isTv}';
      final watchNumber = (nextWatchNumbers[key] ?? 0) + 1;
      nextWatchNumbers[key] = watchNumber;
      final logRef = firestore.collection('logs').doc();
      batch.set(logRef, {
        'id': logRef.id,
        'userId': user.uid,
        'username': identity.username,
        'userAvatarUrl': identity.avatarUrl,
        'movieId': candidate.tmdbId,
        'isTv': candidate.isTv,
        'watchDate': Timestamp.fromDate(row.watchedDate!),
        'watchPlace': null,
        'watchCompanion': null,
        'rating': (row.rating ?? 0) * 2,
        'mood': '',
        'notes': null,
        'watchNumber': watchNumber,
        'tags': null,
        'episodeCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'movieTitle': candidate.title,
        'movieOriginalTitle': null,
        'moviePosterPath': null,
        'movieBackdropPath': null,
        'movieReleaseYear': candidate.year,
        'movieRuntime': null,
        'movieGenres': null,
        'movieDirector': null,
        'movieActors': null,
        'movieOverview': null,
        'movieTotalEpisodes': null,
        'starredBy': <String>[],
        'commentCount': 0,
        'isPublic': false,
      });
      settingsUpdates[key] = (
        movieId: candidate.tmdbId,
        isTv: candidate.isTv,
        count: watchNumber,
      );
      added++;
    }

    for (final update in settingsUpdates.values) {
      final settingsRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('movie_settings')
          .doc('${update.movieId}_${update.isTv}');
      batch.set(settingsRef, {
        'movieId': update.movieId,
        'isTv': update.isTv,
        'watchCount': update.count,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
    return LetterboxdImportResult(
      added: added,
      merged: merged,
      skipped: skipped,
    );
  }
}
