// The web MovieRepository used to hand-write its backup JSON per table instead
// of using Drift's generated toJson/fromJson. That copy fell out of step with
// the schema and silently dropped four columns on every export —
// WatchRecords.tags and .remoteId, UserMovieSettings.personalRanking and
// .lastEpisodeProgressAt — so a user who backed up and restored on web lost
// every tag they had written and their entire personal ranking, with no error
// shown anywhere.
//
// These tests pin the round trip field-by-field, and cover the older file
// shapes the hand-written parser used to special-case (ISO date strings,
// columns that did not exist yet) so replacing it with fromJson doesn't
// regress them.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/core/database/movie_repository.dart';

// WebMovieRepository takes a Ref (it reads/writes the in-memory web providers),
// so it is built inside a provider rather than from the container directly.
final _webRepoProvider = Provider<MovieRepository>((ref) => WebMovieRepository(ref));

void main() {
  late ProviderContainer container;
  late MovieRepository repo;

  setUp(() {
    container = ProviderContainer();
    repo = container.read(_webRepoProvider);
    addTearDown(container.dispose);
  });

  test('a web backup round trip preserves every watch-record field', () async {
    final original = WatchRecord(
      id: 1,
      movieId: 27205,
      isTv: false,
      watchDate: DateTime(2025, 3, 14, 21, 30),
      watchPlace: 'Sinema',
      watchCompanion: 'Arkadaşlar',
      rating: 9.5,
      mood: '🍿',
      notes: 'ikinci izleyiş, daha iyi',
      watchNumber: 2,
      tags: '#sinema,#gece',
      episodeCount: 1,
      createdAt: DateTime(2025, 3, 14, 22),
      isPublic: true,
      remoteId: 'firestore-doc-abc',
    );
    container.read(webWatchRecordsProvider.notifier).state = [original];

    final json = await repo.exportBackupData();
    // Clear everything first so a passing assertion can only come from the file.
    container.read(webWatchRecordsProvider.notifier).state = [];
    await repo.importBackupData(json);

    final restored = container.read(webWatchRecordsProvider).single;
    expect(restored, original);
    // Named individually so a future drop is reported by field, not as one
    // opaque object mismatch.
    expect(restored.tags, '#sinema,#gece', reason: 'tags used to be dropped');
    expect(restored.remoteId, 'firestore-doc-abc', reason: 'remoteId used to be dropped');
    expect(restored.isPublic, isTrue);
    expect(restored.episodeCount, 1);
  });

  test('a web backup round trip preserves every settings field', () async {
    final original = UserMovieSetting(
      tmdbId: 1399,
      isTv: true,
      isFavorite: true,
      isReWatchList: false,
      personalRanking: 3,
      personalNotes: 'en iyi dizi',
      personalTags: '#fantastik',
      updatedAt: DateTime(2025, 5, 1),
      isActivelyWatching: true,
      lastWatchedEpisode: 17,
      lastEpisodeProgressAt: DateTime(2025, 5, 2, 23, 15),
    );
    container.read(webMovieSettingsProvider.notifier).state = {
      (tmdbId: 1399, isTv: true): original,
    };

    final json = await repo.exportBackupData();
    container.read(webMovieSettingsProvider.notifier).state = {};
    await repo.importBackupData(json);

    final restored = container.read(webMovieSettingsProvider)[(tmdbId: 1399, isTv: true)]!;
    expect(restored, original);
    expect(restored.personalRanking, 3, reason: 'personalRanking used to be dropped');
    expect(restored.lastEpisodeProgressAt, DateTime(2025, 5, 2, 23, 15),
        reason: 'lastEpisodeProgressAt used to be dropped');
  });

  test('a web backup round trip preserves movies and collections', () async {
    container.read(webMoviesProvider.notifier).state = {
      (tmdbId: 27205, isTv: false): Movie(
        tmdbId: 27205,
        title: 'Inception',
        originalTitle: 'Inception',
        posterPath: '/p.jpg',
        backdropPath: '/b.jpg',
        releaseYear: 2010,
        runtime: 148,
        genres: 'Bilim Kurgu, Aksiyon',
        genreIds: '878,28',
        director: 'Christopher Nolan',
        actors: 'Leonardo DiCaprio',
        overview: 'rüya içinde rüya',
        isTv: false,
        createdAt: DateTime(2024, 1, 1),
        totalEpisodes: null,
      ),
    };
    container.read(webCustomListsProvider.notifier).state = {
      1: CustomList(
        id: 1,
        name: 'Noir',
        description: 'siyah beyaz',
        targetDate: DateTime(2025, 12, 31),
        createdAt: DateTime(2025, 1, 1),
        isPublic: true,
      ),
    };
    container.read(webCustomListMoviesProvider.notifier).state = [
      CustomListMovie(
        listId: 1,
        movieId: 27205,
        isTv: false,
        rankingOrder: 4,
        addedAt: DateTime(2025, 2, 2),
      ),
    ];

    final json = await repo.exportBackupData();
    container.read(webMoviesProvider.notifier).state = {};
    container.read(webCustomListsProvider.notifier).state = {};
    container.read(webCustomListMoviesProvider.notifier).state = [];
    await repo.importBackupData(json);

    final movie = container.read(webMoviesProvider)[(tmdbId: 27205, isTv: false)]!;
    expect(movie.genreIds, '878,28');
    expect(movie.runtime, 148);
    expect(movie.createdAt, DateTime(2024, 1, 1));

    final list = container.read(webCustomListsProvider)[1]!;
    expect(list.name, 'Noir');
    expect(list.targetDate, DateTime(2025, 12, 31));
    expect(list.isPublic, isTrue);

    final relation = container.read(webCustomListMoviesProvider).single;
    expect(relation.rankingOrder, 4);
    expect(relation.addedAt, DateTime(2025, 2, 2));
  });

  test('restores an older file: ISO date strings and columns that did not exist yet', () async {
    // Exactly the shape the previous hand-written web exporter produced, minus
    // the columns added after it was written. fromJson has to cope with both.
    await repo.importBackupData({
      'version': 1,
      'movies': [
        {
          'tmdbId': 155,
          'title': 'The Dark Knight',
          'genres': 'Aksiyon, Suç',
          'createdAt': '2023-06-01T10:00:00.000',
          // no isTv, no genreIds
        }
      ],
      'watch_records': [
        {
          'id': 9,
          'movieId': 155,
          'watchDate': '2023-06-02T20:00:00.000',
          'rating': 8.0,
          'watchNumber': 1,
          'createdAt': '2023-06-02T20:05:00.000',
          // no isTv, no episodeCount, no isPublic, no tags, no remoteId
        }
      ],
      'user_movie_settings': [
        {
          'tmdbId': 155,
          'isFavorite': 1, // legacy int-as-bool
          'updatedAt': '2023-06-02T20:05:00.000',
        }
      ],
      'custom_lists': [
        {'id': 1, 'name': 'Eski Liste'},
      ],
      'custom_list_movies': [
        {'listId': 1, 'movieId': 155},
      ],
    });

    final record = container.read(webWatchRecordsProvider).single;
    expect(record.isTv, isFalse);
    expect(record.episodeCount, 1, reason: 'defaults to one episode per record');
    expect(record.isPublic, isFalse, reason: 'privacy is opt-in, so absent means private');
    expect(record.watchDate, DateTime(2023, 6, 2, 20));

    final setting = container.read(webMovieSettingsProvider)[(tmdbId: 155, isTv: false)]!;
    expect(setting.isFavorite, isTrue, reason: 'legacy 1/0 booleans still parse');
    expect(setting.isActivelyWatching, isFalse);

    final movie = container.read(webMoviesProvider)[(tmdbId: 155, isTv: false)]!;
    expect(movie.createdAt, DateTime(2023, 6, 1, 10));
    expect(movie.genreIds, isNotNull,
        reason: 'pre-schema-13 files recover genre ids from the stored names');

    expect(container.read(webCustomListsProvider)[1]!.name, 'Eski Liste');
    expect(container.read(webCustomListMoviesProvider).single.movieId, 155);
  });
}
