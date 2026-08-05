import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/core/database/movie_repository.dart';
import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _nativeRepositoryProvider = Provider<MovieRepository>(
  NativeMovieRepository.new,
);
final _webRepositoryProvider = Provider<MovieRepository>(
  WebMovieRepository.new,
);

class _RepositoryHarness {
  _RepositoryHarness(this.container, this.repository, [this.database]);

  final ProviderContainer container;
  final MovieRepository repository;
  final AppDatabase? database;

  Future<void> dispose() async {
    container.dispose();
    await database?.close();
  }
}

_RepositoryHarness _nativeHarness() {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
    ],
  );
  return _RepositoryHarness(
    container,
    container.read(_nativeRepositoryProvider),
    database,
  );
}

_RepositoryHarness _webHarness() {
  final container = ProviderContainer(
    overrides: [firebaseAuthProvider.overrideWithValue(MockFirebaseAuth())],
  );
  return _RepositoryHarness(container, container.read(_webRepositoryProvider));
}

Map<String, dynamic> _fullBackup({
  List<Map<String, dynamic>> movies = const [],
  List<Map<String, dynamic>> records = const [],
  List<Map<String, dynamic>> settings = const [],
  List<Map<String, dynamic>> lists = const [],
  List<Map<String, dynamic>> relations = const [],
}) => {
  'version': 1,
  'movies': movies,
  'watch_records': records,
  'user_movie_settings': settings,
  'custom_lists': lists,
  'custom_list_movies': relations,
};

List<Map<String, dynamic>> _section(Map<String, dynamic> backup, String key) =>
    (backup[key] as List<dynamic>).cast<Map<String, dynamic>>();

void _registerRepositoryContract(
  String implementation,
  _RepositoryHarness Function() createHarness,
) {
  group('$implementation MovieRepository contract', () {
    late _RepositoryHarness harness;
    late MovieRepository repository;

    setUp(() {
      harness = createHarness();
      repository = harness.repository;
    });

    tearDown(() => harness.dispose());

    test('collection CRUD keeps membership and ranking consistent', () async {
      await repository.createCustomList(
        'Weekend',
        'Two films',
        targetDate: DateTime(2026, 8, 9),
      );
      var backup = await repository.exportBackupData();
      final list = _section(backup, 'custom_lists').single;
      final listId = list['id'] as int;

      final createdAt = DateTime(2026, 8, 5);
      await repository.addMovieToCustomList(
        listId,
        Movie(tmdbId: 10, title: 'Ten', isTv: false, createdAt: createdAt),
      );
      await repository.addMovieToCustomList(
        listId,
        Movie(tmdbId: 20, title: 'Twenty', isTv: true, createdAt: createdAt),
      );
      await repository.reorderCustomListMovies(listId, {
        (tmdbId: 10, isTv: false): 2,
        (tmdbId: 20, isTv: true): 1,
      });
      await repository.updateCustomList(
        listId,
        'Updated weekend',
        null,
        clearTargetDate: true,
      );

      backup = await repository.exportBackupData();
      final updatedList = _section(backup, 'custom_lists').single;
      final relations = _section(backup, 'custom_list_movies');
      expect(updatedList['name'], 'Updated weekend');
      expect(updatedList['description'], isNull);
      expect(updatedList['targetDate'], isNull);
      expect(relations, hasLength(2));
      expect(
        relations.singleWhere((row) => row['movieId'] == 20)['rankingOrder'],
        1,
      );

      await repository.removeMovieFromCustomList(listId, 10, false);
      await repository.deleteCustomList(listId);
      backup = await repository.exportBackupData();
      expect(_section(backup, 'custom_lists'), isEmpty);
      expect(_section(backup, 'custom_list_movies'), isEmpty);
    });

    test('metadata and episode progress preserve personal settings', () async {
      const tmdbId = 1399;
      final initialSetting = UserMovieSetting(
        tmdbId: tmdbId,
        isTv: true,
        isFavorite: true,
        isReWatchList: true,
        personalRanking: 8,
        personalNotes: 'Keep this',
        personalTags: '#fantasy',
        updatedAt: DateTime(2026, 8, 5),
        isActivelyWatching: false,
      );

      await repository.updatePersonalRankingLocal(
        tmdbId: tmdbId,
        isTv: true,
        movieData: {
          'name': 'Game of Thrones',
          'first_air_date': '2011-04-17',
          'number_of_episodes': 73,
          'genres': [
            {'id': 18, 'name': 'Drama'},
          ],
        },
        settings: initialSetting,
        rank: 3,
      );
      await repository.writeEpisodeProgressSettingsLocal(
        tmdbId: tmdbId,
        isTv: true,
        setting: initialSetting.copyWith(personalRanking: const Value(3)),
        lastWatchedEpisode: 17,
        isActivelyWatching: true,
      );

      final backup = await repository.exportBackupData();
      final movie = _section(backup, 'movies').single;
      final setting = _section(backup, 'user_movie_settings').single;
      expect(movie['title'], 'Game of Thrones');
      expect(movie['releaseYear'], 2011);
      expect(movie['totalEpisodes'], 73);
      expect(setting['personalRanking'], 3);
      expect(setting['personalNotes'], 'Keep this');
      expect(setting['personalTags'], '#fantasy');
      expect(setting['lastWatchedEpisode'], 17);
      expect(setting['isActivelyWatching'], isTrue);
      expect(setting['lastEpisodeProgressAt'], isNotNull);
    });

    test('watch-record updates and deletes keep progress consistent', () async {
      final first = WatchRecord(
        id: 1,
        movieId: 100,
        isTv: true,
        watchDate: DateTime(2026, 8, 1),
        rating: 8,
        watchNumber: 1,
        createdAt: DateTime(2026, 8, 1),
        episodeCount: 2,
        isPublic: false,
      );
      final second = WatchRecord(
        id: 2,
        movieId: 100,
        isTv: true,
        watchDate: DateTime(2026, 8, 2),
        rating: 9,
        watchNumber: 1,
        createdAt: DateTime(2026, 8, 2),
        episodeCount: 3,
        isPublic: false,
      );
      final setting = UserMovieSetting(
        tmdbId: 100,
        isTv: true,
        isFavorite: false,
        isReWatchList: false,
        updatedAt: DateTime(2026, 8, 2),
        isActivelyWatching: true,
        lastWatchedEpisode: 5,
      );
      await repository.importBackupData(
        _fullBackup(
          movies: [
            Movie(
              tmdbId: 100,
              title: 'Show',
              isTv: true,
              createdAt: DateTime(2026, 8, 1),
              totalEpisodes: 10,
            ).toJson(),
          ],
          records: [first.toJson(), second.toJson()],
          settings: [setting.toJson()],
        ),
      );

      await repository.updateWatchRecordLocal(
        second,
        watchDate: DateTime(2026, 8, 3),
        episodeCount: 4,
        isPublic: true,
      );
      var backup = await repository.exportBackupData();
      final updated = _section(
        backup,
        'watch_records',
      ).singleWhere((row) => row['id'] == 2);
      expect(updated['episodeCount'], 4);
      expect(updated['isPublic'], isTrue);
      expect(updated['watchDate'], DateTime(2026, 8, 3).millisecondsSinceEpoch);

      await repository.deleteWatchRecordLocal(second);
      backup = await repository.exportBackupData();
      expect(_section(backup, 'watch_records'), hasLength(1));
      var progress = _section(backup, 'user_movie_settings').single;
      expect(progress['lastWatchedEpisode'], 2);
      expect(progress['isActivelyWatching'], isTrue);

      await repository.deleteWatchRecordLocal(first);
      backup = await repository.exportBackupData();
      expect(_section(backup, 'watch_records'), isEmpty);
      progress = _section(backup, 'user_movie_settings').single;
      expect(progress['lastWatchedEpisode'], isNull);
      expect(progress['isActivelyWatching'], isFalse);
    });

    test('a full backup replaces every existing section', () async {
      await repository.importBackupData(
        _fullBackup(
          movies: [
            Movie(
              tmdbId: 1,
              title: 'Old',
              isTv: false,
              createdAt: DateTime(2026, 1, 1),
            ).toJson(),
          ],
        ),
      );
      await repository.importBackupData(
        _fullBackup(
          movies: [
            Movie(
              tmdbId: 2,
              title: 'New',
              isTv: false,
              createdAt: DateTime(2026, 2, 2),
            ).toJson(),
          ],
        ),
      );

      final backup = await repository.exportBackupData();
      expect(_section(backup, 'movies').map((row) => row['tmdbId']), [2]);
      expect(_section(backup, 'watch_records'), isEmpty);
      expect(_section(backup, 'user_movie_settings'), isEmpty);
      expect(_section(backup, 'custom_lists'), isEmpty);
      expect(_section(backup, 'custom_list_movies'), isEmpty);
    });
  });
}

void main() {
  _registerRepositoryContract('native', _nativeHarness);
  _registerRepositoryContract('web', _webHarness);
}
