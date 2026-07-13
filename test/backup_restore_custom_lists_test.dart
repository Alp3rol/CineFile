import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/settings/presentation/settings_provider.dart';
import 'package:drift/drift.dart';

void main() {
  group('BackupService Native Tests', () {
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

    test('Native: export and import custom lists correctly', () async {
      // 1. Insert dummy data to DB
      final movie = Movie(tmdbId: 101, title: 'Inception', isTv: false, createdAt: DateTime.now());
      await db.into(db.movies).insert(movie);

      final customList = CustomList(
        id: 1,
        name: 'My Best Movies',
        description: 'Favorites of all time',
        createdAt: DateTime.now(),
        isPublic: true,
      );
      await db.into(db.customLists).insert(customList);

      final customListMovie = CustomListMovie(
        listId: 1,
        movieId: 101,
        isTv: false,
        rankingOrder: 1,
        addedAt: DateTime.now(),
      );
      await db.into(db.customListMovies).insert(customListMovie);

      // 2. Export
      final exportedJson = await BackupService.exportData(container);

      expect(exportedJson.containsKey('custom_lists'), isTrue);
      expect(exportedJson.containsKey('custom_list_movies'), isTrue);

      final exportedLists = exportedJson['custom_lists'] as List<dynamic>;
      final exportedMovies = exportedJson['custom_list_movies'] as List<dynamic>;

      expect(exportedLists.length, 1);
      expect(exportedLists.first['name'], 'My Best Movies');
      expect(exportedMovies.length, 1);
      expect(exportedMovies.first['movieId'], 101);

      // 3. Import after clear/change
      await db.delete(db.customListMovies).go();
      await db.delete(db.customLists).go();

      await BackupService.importData(container, exportedJson);

      // 4. Verify restored data
      final restoredLists = await db.select(db.customLists).get();
      final restoredMovies = await db.select(db.customListMovies).get();

      expect(restoredLists.length, 1);
      expect(restoredLists.first.name, 'My Best Movies');
      expect(restoredLists.first.isPublic, isTrue);

      expect(restoredMovies.length, 1);
      expect(restoredMovies.first.movieId, 101);
    });

    test('Native: backward compatibility with legacy backups missing custom_lists keys', () async {
      // Legacy JSON backup format without custom lists
      final legacyJson = {
        'version': 1,
        'movies': [
          {
            'tmdbId': 102,
            'title': 'Interstellar',
            'isTv': false,
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
        'watch_records': [],
        'user_movie_settings': []
      };

      // Import shouldn't fail
      await BackupService.importData(container, legacyJson);

      final restoredMovies = await db.select(db.movies).get();
      expect(restoredMovies.length, 1);
      expect(restoredMovies.first.title, 'Interstellar');

      final restoredLists = await db.select(db.customLists).get();
      expect(restoredLists, isEmpty);
    });
  });
}
