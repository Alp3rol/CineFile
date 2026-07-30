// Covers the schema 12 -> 13 migration that introduced Movies.genreIds, and
// the pure helpers it is built on.
//
// The migration is exercised against a real on-disk v12 database rather than a
// mocked one: the whole point of the change is that existing user libraries
// keep working, so the test has to prove drift actually runs onUpgrade and
// backfills rows that were written before ids were stored.
import 'dart:io';

// drift also exports an `isNull` (a SQL expression builder), which would
// shadow matcher's.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/constants/tmdb_genres.dart';
import 'package:cinefile/core/database/app_database.dart';

/// The `movies` table exactly as schema 12 defined it — same column names and
/// types drift generates, minus `genre_ids`. Only this table is created: the
/// 12 -> 13 step touches nothing else.
const _v12MoviesDdl = '''
CREATE TABLE movies (
  tmdb_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  original_title TEXT,
  poster_path TEXT,
  backdrop_path TEXT,
  release_year INTEGER,
  runtime INTEGER,
  genres TEXT,
  director TEXT,
  actors TEXT,
  overview TEXT,
  country TEXT,
  language TEXT,
  is_tv INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL DEFAULT 0,
  total_episodes INTEGER,
  PRIMARY KEY (tmdb_id, is_tv)
)
''';

// A real v12 database has all five tables, not just `movies`. They were left
// out of this fixture while the only migration under test touched `movies`
// alone — but the v14 step creates indexes on `watch_records` and
// `custom_list_movies`, and CREATE INDEX on a missing table is an error. The
// fixture has to look like the database it stands in for.
const _v12OtherTablesDdl = <String>[
  '''
CREATE TABLE watch_records (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  movie_id INTEGER NOT NULL,
  is_tv INTEGER NOT NULL DEFAULT 0,
  watch_date INTEGER NOT NULL,
  watch_place TEXT,
  watch_companion TEXT,
  rating REAL NOT NULL,
  mood TEXT,
  notes TEXT,
  watch_number INTEGER NOT NULL,
  tags TEXT,
  episode_count INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL DEFAULT 0,
  is_public INTEGER NOT NULL DEFAULT 0,
  remote_id TEXT
)
''',
  '''
CREATE TABLE user_movie_settings (
  tmdb_id INTEGER NOT NULL,
  is_tv INTEGER NOT NULL DEFAULT 0,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  is_re_watch_list INTEGER NOT NULL DEFAULT 0,
  personal_ranking INTEGER,
  personal_notes TEXT,
  personal_tags TEXT,
  updated_at INTEGER NOT NULL DEFAULT 0,
  is_actively_watching INTEGER NOT NULL DEFAULT 0,
  last_watched_episode INTEGER,
  last_episode_progress_at INTEGER,
  PRIMARY KEY (tmdb_id, is_tv)
)
''',
  '''
CREATE TABLE custom_lists (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  target_date INTEGER,
  created_at INTEGER NOT NULL DEFAULT 0,
  is_public INTEGER NOT NULL DEFAULT 0
)
''',
  '''
CREATE TABLE custom_list_movies (
  list_id INTEGER NOT NULL REFERENCES custom_lists (id) ON DELETE CASCADE,
  movie_id INTEGER NOT NULL,
  is_tv INTEGER NOT NULL DEFAULT 0,
  ranking_order INTEGER,
  added_at INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (list_id, movie_id, is_tv)
)
''',
];

void main() {
  group('genre id helpers', () {
    test('round-trips ids through the stored comma-separated form', () {
      expect(formatGenreIds([TmdbGenre.action, TmdbGenre.drama]), '28,18');
      expect(parseGenreIds('28,18'), [TmdbGenre.action, TmdbGenre.drama]);
      expect(parseGenreIds(' 28 , 18 '), [TmdbGenre.action, TmdbGenre.drama]);
    });

    test('represents "no genres" as null rather than an empty string', () {
      expect(formatGenreIds(const []), isNull);
      expect(parseGenreIds(null), isEmpty);
      expect(parseGenreIds(''), isEmpty);
    });

    test('skips malformed fragments instead of throwing', () {
      // One bad row must not break a screen that aggregates the whole library.
      expect(parseGenreIds('28,,oops,18'), [TmdbGenre.action, TmdbGenre.drama]);
    });

    test('recovers ids from the Turkish names older rows stored', () {
      expect(
        genreIdsFromLegacyNames('Bilim Kurgu, Dram'),
        [TmdbGenre.scienceFiction, TmdbGenre.drama],
      );
      // TV-only vocabulary, and names containing "&" that must not be split.
      expect(
        genreIdsFromLegacyNames('Aksiyon & Macera, Bilim Kurgu & Fantazi'),
        [TmdbGenre.actionAdventure, TmdbGenre.sciFiFantasy],
      );
      // Unknown names resolve to nothing rather than a wrong id.
      expect(genreIdsFromLegacyNames('Bilinmeyen Tür'), isEmpty);
      expect(genreIdsFromLegacyNames(null), isEmpty);
    });

    test('reads both TMDb payload shapes', () {
      // Detail endpoints.
      expect(
        genreIdsFromTmdbPayload({
          'genres': [
            {'id': 28, 'name': 'Aksiyon'},
            {'id': 18, 'name': 'Dram'},
          ],
        }),
        [TmdbGenre.action, TmdbGenre.drama],
      );
      // Search/discover endpoints.
      expect(
        genreIdsFromTmdbPayload({'genre_ids': [16, 35]}),
        [TmdbGenre.animation, TmdbGenre.comedy],
      );
      expect(genreIdsFromTmdbPayload({'title': 'no genres here'}), isEmpty);
    });
  });

  group('schema 12 -> 13 migration', () {
    late File file;

    setUp(() async {
      final dir = await Directory.systemTemp.createTemp('cinefile_migration_test');
      file = File('${dir.path}/app.db');
    });

    tearDown(() async {
      if (await file.exists()) await file.delete();
    });

    /// Writes a v12 database holding [rows] of (tmdbId, isTv, genres).
    Future<void> seedV12(List<(int, bool, String?)> rows) async {
      final raw = NativeDatabase(file);
      final db = _RawDb(raw);
      await db.customStatement(_v12MoviesDdl);
      for (final ddl in _v12OtherTablesDdl) {
        await db.customStatement(ddl);
      }
      for (final (tmdbId, isTv, genres) in rows) {
        await db.customStatement(
          'INSERT INTO movies (tmdb_id, title, genres, is_tv, created_at) VALUES (?, ?, ?, ?, 0)',
          [tmdbId, 'Title $tmdbId', genres, isTv ? 1 : 0],
        );
      }
      await db.customStatement('PRAGMA user_version = 12');
      await db.close();
    }

    test('adds genre_ids and backfills it from the stored Turkish names', () async {
      await seedV12([
        (1, false, 'Bilim Kurgu, Dram'),
        (2, true, 'Aksiyon & Macera'),
        // Same numeric id as the movie above but a show — the composite key
        // means these are two distinct rows and must be backfilled separately.
        (1, true, 'Komedi'),
        // A name that no longer resolves, and a row with no genres at all.
        (3, false, 'Bilinmeyen Tür'),
        (4, false, null),
      ]);

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final movies = await db.select(db.movies).get();
      Movie rowFor(int tmdbId, bool isTv) =>
          movies.firstWhere((m) => m.tmdbId == tmdbId && m.isTv == isTv);

      expect(movies.length, 5);
      expect(parseGenreIds(rowFor(1, false).genreIds),
          [TmdbGenre.scienceFiction, TmdbGenre.drama]);
      expect(parseGenreIds(rowFor(2, true).genreIds), [TmdbGenre.actionAdventure]);
      expect(parseGenreIds(rowFor(1, true).genreIds), [TmdbGenre.comedy]);

      // Unresolvable and empty rows are left null rather than guessed at; they
      // fill in the next time TMDb details are fetched for that title.
      expect(rowFor(3, false).genreIds, isNull);
      expect(rowFor(4, false).genreIds, isNull);

      // The original names are untouched — nothing is destroyed by the upgrade.
      expect(rowFor(1, false).genres, 'Bilim Kurgu, Dram');
    });
  });
}

/// Minimal drift database used only to write the pre-migration schema. It
/// declares no tables, so opening it never triggers AppDatabase's migration.
class _RawDb extends GeneratedDatabase {
  _RawDb(super.executor);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 1;
}
