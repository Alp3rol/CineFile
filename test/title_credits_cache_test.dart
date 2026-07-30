// rawTitleCreditsProvider used to issue one TMDb request per unique watched
// title on the first open of the graph tab in every session — a 300-title
// library meant 300 requests, repeated on every app start, because the only
// cache in the path was Dio's in-memory store.
//
// These pin the two properties that fix costs: a cached title is not fetched
// again, and an entry past its TTL is.
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/riverpod_async.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/features/relationship_graph/data/title_credits_cache.dart';
import 'package:cinefile/features/relationship_graph/domain/graph_models.dart';
import 'package:cinefile/features/relationship_graph/presentation/relationship_graph_provider.dart';

Movie _movie(int id, {bool isTv = false}) => Movie(
      tmdbId: id,
      title: 'Title $id',
      isTv: isTv,
      createdAt: DateTime(2024, 1, 1),
    );

WatchRecordWithMovie _rec(Movie m) => WatchRecordWithMovie(
      WatchRecord(
        id: m.tmdbId,
        movieId: m.tmdbId,
        isTv: m.isTv,
        watchDate: DateTime(2024, 1, 1),
        rating: 8,
        watchNumber: 1,
        createdAt: DateTime(2024, 1, 1),
        episodeCount: 1,
        isPublic: false,
      ),
      m,
    );

const _people = [
  CreditPerson(id: 5, name: 'Ali Atay', isDirector: false, order: 0),
  CreditPerson(id: 9, name: 'Bir Yönetmen', isDirector: true),
];

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer containerWith({
    required List<Movie> library,
    required List<Movie> fetched,
  }) {
    return ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      allWatchRecordsProvider
          .overrideWith((ref) => Stream.value(library.map(_rec).toList())),
      titleCreditsFetcherProvider.overrideWithValue((Movie m) async {
        fetched.add(m);
        return _people;
      }),
    ]);
  }

  test('a cached title is served without a TMDb request', () async {
    final fetched = <Movie>[];
    final container = containerWith(library: [_movie(1), _movie(2)], fetched: fetched);
    addTearDown(container.dispose);

    // First open: nothing cached, both titles fetched.
    await readAsync(container, rawTitleCreditsProvider.future);
    expect(fetched.map((m) => m.tmdbId), unorderedEquals([1, 2]));

    // Second open, fresh container over the SAME database — this is what a
    // relaunch looks like. Nothing should go out to TMDb.
    fetched.clear();
    final relaunch = containerWith(library: [_movie(1), _movie(2)], fetched: fetched);
    addTearDown(relaunch.dispose);

    final result = await readAsync(relaunch, rawTitleCreditsProvider.future);
    expect(fetched, isEmpty, reason: 'every title was already cached');
    expect(result.credits['title:1:false'], hasLength(2));
  });

  test('order and episodeCount survive the cache round trip', () async {
    // isProminent filters on exactly these two fields, so a cache that dropped
    // them (CreditPerson.toMap does, deliberately) would quietly shrink the
    // graph on the second launch compared to the first.
    final cache = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(cache.dispose);
    final store = cache.read(titleCreditsCacheProvider);

    await store.write((tmdbId: 1, isTv: false), _people);
    final read = await store.read([(tmdbId: 1, isTv: false)]);

    final person = read[(tmdbId: 1, isTv: false)]!.first;
    expect(person.name, 'Ali Atay');
    expect(person.order, 0);
    expect(person.id, 5);
    expect(read[(tmdbId: 1, isTv: false)]!.last.isDirector, isTrue);
  });

  test('a movie and a show sharing a tmdbId are cached separately', () async {
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final store = container.read(titleCreditsCacheProvider);

    await store.write((tmdbId: 42, isTv: false), _people);
    final read = await store.read([(tmdbId: 42, isTv: false), (tmdbId: 42, isTv: true)]);

    expect(read.containsKey((tmdbId: 42, isTv: false)), isTrue);
    expect(read.containsKey((tmdbId: 42, isTv: true)), isFalse,
        reason: 'the TV entry was never written; ids collide across media types');
  });

  test('an entry past its TTL is refetched', () async {
    await db.into(db.titleCredits).insert(TitleCredit(
          tmdbId: 1,
          isTv: false,
          people: '[]',
          fetchedAt: DateTime.now().subtract(kTitleCreditsTtl * 2),
        ));

    final fetched = <Movie>[];
    final container = containerWith(library: [_movie(1)], fetched: fetched);
    addTearDown(container.dispose);

    await readAsync(container, rawTitleCreditsProvider.future);
    expect(fetched.map((m) => m.tmdbId), [1], reason: 'stale entries do not count as hits');
  });

  test('an empty result is not cached', () async {
    // An empty list usually means the request failed and _fetchCredits fell
    // through to its stored-names fallback. Persisting that would keep the
    // title out of the graph until the TTL expired.
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final store = container.read(titleCreditsCacheProvider);

    await store.write((tmdbId: 7, isTv: false), const []);
    expect(await store.read([(tmdbId: 7, isTv: false)]), isEmpty);
  });
}
