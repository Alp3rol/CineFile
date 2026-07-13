// Verifies findDuplicateWatchGroups groups same-show-same-day records
// correctly and keeps the record with the furthest progress (highest
// watchNumber) as the one NOT slated for deletion — this determines exactly
// which diary entries the Settings cleanup tool will delete, so it needs
// direct coverage.
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/core/database/duplicate_cleanup.dart';

Movie _movie(int id, String title) {
  return Movie(tmdbId: id, title: title, isTv: true, createdAt: DateTime(2026, 1, id));
}

WatchRecord _watchRecord(int id, int movieId, DateTime watchDate, int watchNumber) {
  return WatchRecord(
    id: id,
    movieId: movieId,
    isTv: true,
    watchDate: watchDate,
    rating: 7,
    watchNumber: watchNumber,
    createdAt: watchDate,
    episodeCount: 1,
    isPublic: false,
  );
}

void main() {
  test('groups only same-show-same-day records with more than one entry', () {
    final movieA = _movie(1, 'Aktif Dizi');
    final movieB = _movie(2, 'Başka Dizi');

    final records = [
      // Movie A: 3 duplicate taps on the same day.
      WatchRecordWithMovie(_watchRecord(1, 1, DateTime(2026, 1, 10, 20, 0), 1), movieA),
      WatchRecordWithMovie(_watchRecord(2, 1, DateTime(2026, 1, 10, 20, 5), 2), movieA),
      WatchRecordWithMovie(_watchRecord(3, 1, DateTime(2026, 1, 10, 20, 10), 3), movieA),
      // Movie A: a single, unrelated entry on a different day — not a duplicate.
      WatchRecordWithMovie(_watchRecord(4, 1, DateTime(2026, 1, 11, 21, 0), 4), movieA),
      // Movie B: only one entry ever — not a duplicate.
      WatchRecordWithMovie(_watchRecord(5, 2, DateTime(2026, 1, 10, 20, 0), 1), movieB),
    ];

    final groups = findDuplicateWatchGroups(records);

    expect(groups.length, 1);
    final group = groups.single;
    expect(group.movie.tmdbId, 1);
    expect(group.records.length, 3);

    // The record with the highest watchNumber (furthest progress) is kept;
    // the other two are slated for deletion.
    expect(group.keep.record.watchNumber, 3);
    expect(group.toDelete.map((r) => r.record.watchNumber).toSet(), {1, 2});
  });

  test('returns no groups when there are no same-day duplicates', () {
    final movie = _movie(1, 'Tek Kayıt');
    final records = [
      WatchRecordWithMovie(_watchRecord(1, 1, DateTime(2026, 1, 10), 1), movie),
      WatchRecordWithMovie(_watchRecord(2, 1, DateTime(2026, 1, 11), 2), movie),
    ];

    expect(findDuplicateWatchGroups(records), isEmpty);
  });
}
