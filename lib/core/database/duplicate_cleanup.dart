import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'app_database.dart';
import 'database_provider.dart';
import 'movie_repository.dart';
import 'episode_logging.dart';

// A show/movie with more than one diary entry on the same calendar day —
// the signature left behind by the "+" quick-add bug that used to create a
// brand-new log entry per tap (fixed to only bump the progress counter, see
// advanceEpisodeProgress in episode_logging.dart). Grouped so the user can
// review and bulk-delete the extras from Settings.
class DuplicateWatchGroup {
  final Movie movie;
  final DateTime day;
  final List<WatchRecordWithMovie> records;

  DuplicateWatchGroup({required this.movie, required this.day, required this.records});

  String get key => '${movie.tmdbId}_${movie.isTv}_${day.toIso8601String()}';

  // The record with the furthest progress (highest watchNumber, i.e. the
  // last tap of that day) is the one worth keeping; everything else in the
  // group is the clutter to remove.
  WatchRecordWithMovie get keep =>
      records.reduce((a, b) => a.record.watchNumber >= b.record.watchNumber ? a : b);

  List<WatchRecordWithMovie> get toDelete => records.where((r) => r != keep).toList();
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

List<DuplicateWatchGroup> findDuplicateWatchGroups(List<WatchRecordWithMovie> records) {
  final groups = <String, List<WatchRecordWithMovie>>{};
  for (final r in records) {
    final day = _dayOnly(r.record.watchDate);
    final key = '${r.movie.tmdbId}_${r.movie.isTv}_${day.toIso8601String()}';
    groups.putIfAbsent(key, () => []).add(r);
  }

  return groups.values
      .where((list) => list.length > 1)
      .map((list) => DuplicateWatchGroup(
            movie: list.first.movie,
            day: _dayOnly(list.first.record.watchDate),
            records: list,
          ))
      .toList();
}

// Deletes every record in the group except the one with the furthest
// progress, then restores the show's progress counter (lastWatchedEpisode /
// isActivelyWatching) to what it already correctly was before cleanup —
// deleteWatchRecord's own recompute only looks at the single surviving
// record's episodeCount, so left alone it would reset progress back down.
//
// Deliberately does NOT call deleteWatchRecord per record: that function
// does one Firestore query + one delete + one recompute-query + one
// settings write PER record, which made bulk cleanup extremely slow for
// groups with many duplicates. Since every record in a group shares the
// same movie, this does a single shared query to find all of that movie's
// logs, a single batched delete, and a single settings write for the whole
// group instead.
Future<void> cleanupDuplicateGroup(WidgetRef ref, DuplicateWatchGroup group) async {
  final keep = group.keep;
  final toDelete = group.toDelete;
  final preservedSetting = keep.setting;

  if (toDelete.isNotEmpty) {
    final movieId = keep.movie.tmdbId;
    final isTv = keep.movie.isTv;
    final user = ref.currentUser;

    if (user != null) {
      final firestore = ref.read(firestoreProvider);
      final keepRemoteId = keep.record.remoteId;

      // Records carry their Firestore document id (see WatchRecords.remoteId),
      // so the documents to remove are known outright.
      //
      // This used to search the movie's logs for a document matching each
      // record's id hash, falling back to matching on
      // (watchDate, watchNumber, episodeCount) — which is precisely the tuple
      // that duplicates within one group share. That fallback could resolve a
      // to-delete record to the *kept* record's document and delete the one
      // entry the cleanup exists to preserve.
      final docsToDelete = <DocumentReference<Map<String, dynamic>>>[];
      final unresolved = <WatchRecord>[];
      for (final r in toDelete) {
        final remoteId = r.record.remoteId;
        if (remoteId != null && remoteId.isNotEmpty) {
          docsToDelete.add(firestore.collection('logs').doc(remoteId));
        } else {
          unresolved.add(r.record);
        }
      }

      // Legacy rows with no remoteId (restored from an old backup, or written
      // by a build that predates the field) still need the hash lookup — but
      // only the hash, never the ambiguous tuple, and never the kept document.
      if (unresolved.isNotEmpty) {
        final query = await firestore
            .collection('logs')
            .where('userId', isEqualTo: user.uid)
            .where('movieId', isEqualTo: movieId)
            .where('isTv', isEqualTo: isTv)
            .get();

        for (final record in unresolved) {
          for (final doc in query.docs) {
            if (doc.id == keepRemoteId) continue;
            if (doc.id.hashCode == record.id) {
              docsToDelete.add(doc.reference);
              break;
            }
          }
        }
      }

      // Firestore batches cap at 500 operations; chunk defensively even
      // though a single day's duplicate group is very unlikely to reach that.
      for (var i = 0; i < docsToDelete.length; i += 400) {
        final chunk = docsToDelete.skip(i).take(400);
        final batch = ref.read(firestoreProvider).batch();
        for (final ref_ in chunk) {
          batch.delete(ref_);
        }
        await batch.commit();
      }
    } else {
      final idsToDelete = toDelete.map((r) => r.record.id).toList();
      await ref.read(movieRepositoryProvider).deleteWatchRecordsByIds(idsToDelete);
    }
  }

  if (preservedSetting != null) {
    await writeEpisodeProgressSettings(
      ref: ref,
      movie: keep.movie,
      setting: preservedSetting,
      lastWatchedEpisode: preservedSetting.lastWatchedEpisode,
      isActivelyWatching: preservedSetting.isActivelyWatching,
    );
  }
}
