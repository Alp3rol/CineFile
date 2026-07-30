import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import '../constants/tmdb_genres.dart';
import 'tables.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Movies,
  WatchRecords,
  UserMovieSettings,
  CustomLists,
  CustomListMovies,
  TitleCredits,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(createConnection());

  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 15;

  /// Indexes the query patterns in database_provider.dart and
  /// movie_repository.dart actually use. Declared here rather than inline in
  /// the migration so [_createIndexes] can also run on a freshly created
  /// database (onCreate), where there is no upgrade step to hang them off.
  ///
  /// `IF NOT EXISTS` throughout: onCreate and the v14 upgrade both call this,
  /// and a database created at v14 must not fail because the index is already
  /// there.
  static const List<String> _indexStatements = [
    // deleteWatchRecordLocal and every "records for this title" lookup filter
    // on (movie_id, is_tv); without this each one is a full table scan.
    'CREATE INDEX IF NOT EXISTS idx_watch_records_movie '
        'ON watch_records (movie_id, is_tv)',
    // The journal and insights read records newest-first.
    'CREATE INDEX IF NOT EXISTS idx_watch_records_watch_date '
        'ON watch_records (watch_date DESC)',
    // moviesInCustomListProvider and _mirrorSharedCollection both start from
    // a list id.
    'CREATE INDEX IF NOT EXISTS idx_custom_list_movies_list '
        'ON custom_list_movies (list_id)',
    // listsForMovieProvider goes the other way.
    'CREATE INDEX IF NOT EXISTS idx_custom_list_movies_movie '
        'ON custom_list_movies (movie_id, is_tv)',
  ];

  Future<void> _createIndexes(Migrator m) async {
    for (final statement in _indexStatements) {
      await customStatement(statement);
    }
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (m) async {
        await m.createAll();
        await _createIndexes(m);
      },
      onUpgrade: (m, from, to) async {
        if (from < 5) {
          // Versions 1-4 were pre-release dev builds with no real user data,
          // so a full recreate here is safe.
          for (final table in allTables) {
            await m.deleteTable(table.entityName);
            await m.createTable(table);
          }
          from = 5;
        }
        // From schemaVersion 5 onward the database may hold real watch
        // history, journal notes and custom lists. Never delete tables here.
        // Add an explicit, non-destructive step (m.addColumn, m.createTable,
        // etc.) for each new schemaVersion instead of falling through to
        // the StateError below.
        if (from < 6) {
          // v6: per-record episode count, so duration stats can scale with
          // how many episodes a watch record actually covers instead of
          // always applying the show's single flat TMDb runtime.
          await m.addColumn(watchRecords, watchRecords.episodeCount);
          from = 6;
        }
        if (from < 7) {
          // v7: "Aktif İzliyorum" episode tracking — cache the show's total
          // episode count, and let UserMovieSettings remember whether the
          // user is actively tracking it episode-by-episode plus the last
          // episode they logged.
          await m.addColumn(movies, movies.totalEpisodes);
          await m.addColumn(userMovieSettings, userMovieSettings.isActivelyWatching);
          await m.addColumn(userMovieSettings, userMovieSettings.lastWatchedEpisode);
          from = 7;
        }
        if (from < 8) {
          // v8: fix a real data-corruption bug. TMDb movie IDs and TV show
          // IDs come from separate counters, so a movie and a show can
          // legitimately share the same numeric tmdbId. Movies/UserMovieSettings/
          // CustomListMovies previously keyed only on tmdbId, so adding a show
          // with the same id as an already-saved movie silently overwrote it
          // via insertOnConflictUpdate — a journal entry for a TV show started
          // opening an unrelated movie that happened to share its tmdbId.
          //
          // Fix: make isTv part of the primary key everywhere. SQLite can't
          // ALTER a table's PRIMARY KEY or an existing FOREIGN KEY constraint
          // in place, so each affected table is recreated: renamed aside,
          // rebuilt with the new (isTv-aware) schema, all rows copied back
          // over (backfilling isTv for the tables that didn't have it yet
          // from the movies row they belonged to), then the old copy is
          // dropped. No user data is deleted — every row is carried forward.
          await customStatement('PRAGMA foreign_keys = OFF');

          await customStatement('ALTER TABLE movies RENAME TO movies_old_v7');
          await customStatement('ALTER TABLE watch_records RENAME TO watch_records_old_v7');
          await customStatement('ALTER TABLE user_movie_settings RENAME TO user_movie_settings_old_v7');
          await customStatement('ALTER TABLE custom_list_movies RENAME TO custom_list_movies_old_v7');

          await m.createTable(movies);
          await customStatement('''
            INSERT INTO movies (
              tmdb_id, title, original_title, poster_path, backdrop_path,
              release_year, runtime, genres, director, actors, overview,
              country, language, is_tv, created_at, total_episodes
            )
            SELECT
              tmdb_id, title, original_title, poster_path, backdrop_path,
              release_year, runtime, genres, director, actors, overview,
              country, language, is_tv, created_at, total_episodes
            FROM movies_old_v7
          ''');

          await m.createTable(watchRecords);
          await customStatement('''
            INSERT INTO watch_records (
              id, movie_id, is_tv, watch_date, watch_place, watch_companion,
              rating, mood, notes, watch_number, tags, episode_count, created_at
            )
            SELECT
              o.id, o.movie_id,
              COALESCE((SELECT is_tv FROM movies_old_v7 mo WHERE mo.tmdb_id = o.movie_id), 0),
              o.watch_date, o.watch_place, o.watch_companion, o.rating, o.mood,
              o.notes, o.watch_number, o.tags, o.episode_count, o.created_at
            FROM watch_records_old_v7 o
          ''');

          await m.createTable(userMovieSettings);
          await customStatement('''
            INSERT INTO user_movie_settings (
              tmdb_id, is_tv, is_favorite, is_re_watch_list, personal_ranking,
              personal_notes, personal_tags, updated_at, is_actively_watching,
              last_watched_episode
            )
            SELECT
              o.tmdb_id,
              COALESCE((SELECT is_tv FROM movies_old_v7 mo WHERE mo.tmdb_id = o.tmdb_id), 0),
              o.is_favorite, o.is_re_watch_list, o.personal_ranking,
              o.personal_notes, o.personal_tags, o.updated_at,
              o.is_actively_watching, o.last_watched_episode
            FROM user_movie_settings_old_v7 o
          ''');

          await m.createTable(customListMovies);
          await customStatement('''
            INSERT INTO custom_list_movies (
              list_id, movie_id, is_tv, ranking_order, added_at
            )
            SELECT
              o.list_id, o.movie_id,
              COALESCE((SELECT is_tv FROM movies_old_v7 mo WHERE mo.tmdb_id = o.movie_id), 0),
              o.ranking_order, o.added_at
            FROM custom_list_movies_old_v7 o
          ''');

          await customStatement('DROP TABLE movies_old_v7');
          await customStatement('DROP TABLE watch_records_old_v7');
          await customStatement('DROP TABLE user_movie_settings_old_v7');
          await customStatement('DROP TABLE custom_list_movies_old_v7');

          await customStatement('PRAGMA foreign_keys = ON');
          from = 8;
        }
        if (from < 9) {
          // v9: Community feed privacy control. New column defaults to
          // false, so every pre-existing watch record stays private until
          // the user explicitly opts in via the record's own share toggle
          // — no data is deleted or changed, only a visibility flag added.
          await m.addColumn(watchRecords, watchRecords.isPublic);
          from = 9;
        }
        if (from < 10) {
          // v10: live-synced "Koleksiyon Paylaş" community posts. New
          // column defaults to false, so every pre-existing collection
          // stays local-only until the user explicitly shares it — no data
          // is deleted or changed, only a visibility flag added.
          await m.addColumn(customLists, customLists.isPublic);
          from = 10;
        }
        if (from < 11) {
          // v11: dedicated episode-progress timestamp so İçgörüler/heatmap
          // can count quick-tap "advance episode" activity without
          // conflating it with unrelated settings writes (favorite, rank,
          // notes) that also touch `updatedAt`. New column defaults to
          // null — no existing data changed.
          await m.addColumn(userMovieSettings, userMovieSettings.lastEpisodeProgressAt);
          from = 11;
        }
        if (from < 12) {
          // v12: carry the Firestore `logs` document id on each watch record
          // (see WatchRecords.remoteId) so edits/deletes address the exact
          // document instead of searching for one whose id hashes to the
          // local int key. New column defaults to null — existing local rows
          // simply have no remote counterpart, which is the correct value for
          // them.
          await m.addColumn(watchRecords, watchRecords.remoteId);
          from = 12;
        }
        if (from < 13) {
          // v13: store language-independent TMDb genre ids alongside the
          // localized genre names (see Movies.genreIds). Adding a second
          // language makes `genres` unusable as an identity — the same title
          // logged before and after a language switch would count as two
          // different genres everywhere statistics are aggregated.
          //
          // Existing rows are backfilled from their stored names, which were
          // necessarily Turkish since that was the only language the app
          // supported. Names that don't resolve leave genreIds null; those
          // rows fill in on their own the next time TMDb details are fetched
          // for them. Nothing is deleted and `genres` is left untouched.
          await m.addColumn(movies, movies.genreIds);

          final existing = await select(movies).get();
          await batch((b) {
            for (final row in existing) {
              final ids = genreIdsFromLegacyNames(row.genres);
              if (ids.isEmpty) continue;
              b.update(
                movies,
                MoviesCompanion(genreIds: Value(formatGenreIds(ids))),
                where: (t) => t.tmdbId.equals(row.tmdbId) & t.isTv.equals(row.isTv),
              );
            }
          });
          from = 13;
        }
        if (from < 14) {
          // v14: indexes. The schema shipped with none, so every lookup by
          // (movie_id, is_tv) or list_id was a full scan of the table — cheap
          // on a small library, linear on a large one, and repeated on every
          // record deletion (deleteWatchRecordLocal issues three of them).
          // Adding an index changes no data.
          await _createIndexes(m);
          from = 14;
        }
        if (from < 15) {
          // v15: persistent cache for the İlişki Ağı's TMDb credits (see
          // TitleCredits). A new table only — nothing existing is touched, and
          // an empty cache simply behaves like the old code did.
          await m.createTable(titleCredits);
          from = 15;
        }
        if (from != to) {
          throw StateError(
            'No non-destructive migration defined from schema version $from '
            'to $to. Add one in AppDatabase.migration before releasing this '
            'schema change.',
          );
        }
      },
    );
  }
}
