import 'dart:convert';

import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/web_local_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = WebLocalSnapshotCodec();
  const writer = WebLocalSnapshotWriter(codec);

  final movie = Movie(
    tmdbId: 27205,
    title: 'Inception',
    isTv: false,
    createdAt: DateTime(2026, 8, 5),
  );
  final list = CustomList(
    id: 1,
    name: 'Favorites',
    createdAt: DateTime(2026, 8, 5),
    isPublic: false,
  );
  final relation = CustomListMovie(
    listId: 1,
    movieId: 27205,
    isTv: false,
    addedAt: DateTime(2026, 8, 5),
  );
  final snapshot = WebLocalSnapshot(
    movies: {(tmdbId: movie.tmdbId, isTv: movie.isTv): movie},
    customLists: {list.id: list},
    customListMovies: [relation],
  );

  test('current snapshot version round-trips every related table', () {
    final encoded = codec.encode(snapshot);
    expect(
      jsonDecode(encoded)['version'],
      WebLocalSnapshotCodec.currentVersion,
    );

    final decoded = codec.decode(encoded);
    expect(decoded.movies.values.single, movie);
    expect(decoded.customLists.values.single, list);
    expect(decoded.customListMovies.single, relation);
  });

  test('missing legacy version falls back without replacing valid data', () {
    Object? reported;
    final decoded = codec.decodeOrFallback(
      '{"movies":[]}',
      fallback: snapshot,
      onError: (error) => reported = error,
    );

    expect(decoded, same(snapshot));
    expect(reported, isA<UnsupportedWebLocalSnapshotVersion>());
  });

  test('unknown future version falls back without replacing valid data', () {
    final decoded = codec.decodeOrFallback(
      '{"version":999,"movies":[]}',
      fallback: snapshot,
    );

    expect(decoded, same(snapshot));
  });

  test(
    'quota rejection is surfaced and never reports a committed snapshot',
    () async {
      var acceptedSnapshot = false;

      await expectLater(
        writer.persist(snapshot, (_) async => false).then((_) {
          acceptedSnapshot = true;
        }),
        throwsA(isA<WebLocalStoreWriteException>()),
      );
      expect(acceptedSnapshot, isFalse);
    },
  );

  test(
    'browser write exceptions are wrapped with their original cause',
    () async {
      final quotaError = StateError('QuotaExceededError');

      await expectLater(
        writer.persist(snapshot, (_) async => throw quotaError),
        throwsA(
          isA<WebLocalStoreWriteException>().having(
            (error) => error.cause,
            'cause',
            same(quotaError),
          ),
        ),
      );
    },
  );
}
