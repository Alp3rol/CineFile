// Verifies the native repository extracted from database_provider.dart
// during the kIsWeb -> repository-abstraction refactor still behaves
// correctly against a real (in-memory) drift database.
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/core/database/movie_repository.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('create, add movie to, reorder, and delete a custom list', () async {
    final repo = container.read(movieRepositoryProvider);
    expect(repo, isA<NativeMovieRepository>());

    await repo.createCustomList('Watchlist', 'desc');
    final lists = await db.select(db.customLists).get();
    expect(lists.length, 1);
    final listId = lists.first.id;

    final movieA = Movie(tmdbId: 1, title: 'A', isTv: false, createdAt: DateTime.now());
    final movieB = Movie(tmdbId: 2, title: 'B', isTv: false, createdAt: DateTime.now());
    await repo.addMovieToCustomList(listId, movieA);
    await repo.addMovieToCustomList(listId, movieB);

    final relations = await (db.select(db.customListMovies)..where((t) => t.listId.equals(listId))).get();
    expect(relations.length, 2);
    expect(relations.map((r) => r.rankingOrder).toSet(), {1, 2});

    await repo.reorderCustomListMovies(listId, {
      (tmdbId: 1, isTv: false): 2,
      (tmdbId: 2, isTv: false): 1,
    });
    final reordered = await (db.select(db.customListMovies)..where((t) => t.movieId.equals(2))).getSingle();
    expect(reordered.rankingOrder, 1);

    await repo.removeMovieFromCustomList(listId, 1, false);
    final remaining = await (db.select(db.customListMovies)..where((t) => t.listId.equals(listId))).get();
    expect(remaining.length, 1);

    await repo.deleteCustomList(listId);
    final listsAfterDelete = await db.select(db.customLists).get();
    expect(listsAfterDelete, isEmpty);
  });

  test('updateWatchRecordRankings inserts a new setting row when none exists', () async {
    final repo = container.read(movieRepositoryProvider);
    await db.into(db.movies).insert(
          MoviesCompanion.insert(tmdbId: 42, title: 'Test'),
        );

    await repo.updateWatchRecordRankings({(tmdbId: 42, isTv: false): 3});
    final setting = await (db.select(db.userMovieSettings)..where((t) => t.tmdbId.equals(42))).getSingle();
    expect(setting.personalRanking, 3);
  });
}
