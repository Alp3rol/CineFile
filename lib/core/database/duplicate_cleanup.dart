import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'app_database.dart';
import 'database_provider.dart';
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
    final authState = ref.read(authStateProvider);
    final user = authState.value;

    if (user != null) {
      final query = await ref.read(firestoreProvider)
          .collection('logs')
          .where('userId', isEqualTo: user.uid)
          .where('movieId', isEqualTo: movieId)
          .where('isTv', isEqualTo: isTv)
          .get();

      final docsToDelete = <DocumentReference<Map<String, dynamic>>>[];
      for (final r in toDelete) {
        final record = r.record;
        for (final doc in query.docs) {
          final data = doc.data();
          final docWatchDate = (data['watchDate'] as Timestamp?)?.toDate();
          final isHashCodeMatch = doc.id.hashCode == record.id;
          final isExactMatch = docWatchDate != null &&
              docWatchDate.isAtSameMomentAs(record.watchDate) &&
              data['watchNumber'] == record.watchNumber &&
              data['episodeCount'] == record.episodeCount;
          if (isHashCodeMatch || isExactMatch) {
            docsToDelete.add(doc.reference);
            break;
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
    } else if (kIsWeb) {
      final idsToDelete = toDelete.map((r) => r.record.id).toSet();
      final currentList = ref.read(webWatchRecordsProvider);
      ref.read(webWatchRecordsProvider.notifier).state =
          currentList.where((r) => !idsToDelete.contains(r.id)).toList();
    } else {
      final db = ref.read(databaseProvider);
      final idsToDelete = toDelete.map((r) => r.record.id).toList();
      await (db.delete(db.watchRecords)..where((t) => t.id.isIn(idsToDelete))).go();
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
