// The migration strategy carries thirteen years of this app's schema history
// and had no test at all — a broken step would only be discovered by a user
// whose library it had already mangled.
//
// Reconstructing every historical version retroactively isn't possible (the
// schemas were never dumped when they shipped), so these cover what still can
// be: the newest upgrade step runs against a real on-disk database, existing
// rows survive it, a database created from scratch ends up in the same shape as
// one that was upgraded into it, and the guard against an undefined migration
// actually fires.
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/database/app_database.dart';

/// Index names created by the v14 step.
const _indexNames = {
  'idx_watch_records_movie',
  'idx_watch_records_watch_date',
  'idx_custom_list_movies_list',
  'idx_custom_list_movies_movie',
};

Future<Set<String>> _indexesIn(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
      .get();
  return rows.map((r) => r.read<String>('name')).toSet();
}

Future<int> _userVersion(AppDatabase db) async {
  final row = await db.customSelect('PRAGMA user_version').getSingle();
  return row.read<int>('user_version');
}

void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cinefile_migration_test');
    dbFile = File('${tempDir.path}/app.sqlite');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  /// Rewinds a current database to look like v13: undo everything the steps
  /// after 13 added (v14's indexes, v15's title_credits table) and step
  /// `user_version` back, reproducing a real pre-upgrade file.
  ///
  /// Every new migration step needs its undo added here — that is deliberate.
  /// It is the one place that has to be touched, and forgetting it makes this
  /// test fail rather than silently stop covering the new step.
  Future<void> rewindToV13(AppDatabase db) async {
    for (final name in _indexNames) {
      await db.customStatement('DROP INDEX IF EXISTS $name');
    }
    await db.customStatement('DROP TABLE IF EXISTS title_credits');
    await db.customStatement('PRAGMA user_version = 13');
  }

  test('upgrading from v13 adds the indexes and keeps every row', () async {
    var db = AppDatabase.forTesting(NativeDatabase(dbFile));

    await db.into(db.movies).insert(MoviesCompanion.insert(
          tmdbId: 27205,
          title: 'Inception',
          isTv: const Value(false),
          genres: const Value('Bilim Kurgu, Aksiyon'),
          genreIds: const Value('878,28'),
        ));
    await db.into(db.watchRecords).insert(WatchRecordsCompanion.insert(
          movieId: 27205,
          watchDate: DateTime(2025, 1, 2),
          rating: 9,
          watchNumber: 1,
          tags: const Value('#gece'),
        ));
    await db.into(db.customLists).insert(
          CustomListsCompanion.insert(name: 'Noir', description: const Value('siyah beyaz')),
        );

    await rewindToV13(db);
    expect(await _indexesIn(db), isNot(containsAll(_indexNames)));
    await db.close();

    // Reopening replays every step from 13 to the current version against the
    // file written above.
    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    expect(await _userVersion(db), db.schemaVersion);
    expect(await _indexesIn(db), containsAll(_indexNames),
        reason: 'the v14 step must create every index');
    expect(
      await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'title_credits'",
      ).get(),
      hasLength(1),
      reason: 'the v15 step must create the credits cache table',
    );

    // Nothing was dropped or rewritten on the way through.
    final movie = await (db.select(db.movies)
          ..where((t) => t.tmdbId.equals(27205) & t.isTv.equals(false)))
        .getSingle();
    expect(movie.title, 'Inception');
    expect(movie.genreIds, '878,28');

    final record = await db.select(db.watchRecords).getSingle();
    expect(record.movieId, 27205);
    expect(record.rating, 9);
    expect(record.tags, '#gece');

    final list = await db.select(db.customLists).getSingle();
    expect(list.name, 'Noir');
    expect(list.description, 'siyah beyaz');
  });

  test('a freshly created database has the same indexes as an upgraded one', () async {
    // onCreate and onUpgrade are separate code paths; an index added only to
    // the upgrade step would be missing on every new install, which is exactly
    // the kind of drift that goes unnoticed for a year.
    final fresh = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(fresh.close);
    await fresh.customSelect('SELECT 1').get(); // force open

    expect(await _userVersion(fresh), fresh.schemaVersion);
    expect(await _indexesIn(fresh), containsAll(_indexNames));
  });

  test('the upgrade is idempotent if it runs again', () async {
    var db = AppDatabase.forTesting(NativeDatabase(dbFile));
    await db.customSelect('SELECT 1').get();
    // Step the version back WITHOUT undoing anything, so every statement from
    // 13 onwards re-runs over objects that already exist. This is what a
    // half-applied migration looks like on a real device, and it must not throw.
    await db.customStatement('PRAGMA user_version = 13');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);
    expect(await _userVersion(db), db.schemaVersion);
    expect(await _indexesIn(db), containsAll(_indexNames));
  });

  test('an undefined migration path fails loudly instead of losing data', () async {
    var db = AppDatabase.forTesting(NativeDatabase(dbFile));
    await db.into(db.movies).insert(MoviesCompanion.insert(tmdbId: 1, title: 'Keep Me'));
    // A version this build has no step for — the guard at the end of onUpgrade
    // exists so a schema bump without a migration is caught here rather than
    // falling through and silently leaving the database half-migrated.
    await db.customStatement('PRAGMA user_version = 4242');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    await expectLater(
      db.customSelect('SELECT 1').get(),
      throwsA(isA<StateError>()),
    );
    await db.close();
  });
}
