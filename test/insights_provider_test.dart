// Verifies genre/director/actor/tag counting still works after extracting
// the shared _countCommaSeparatedField helper in insights_provider.dart.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/insights/presentation/insights_provider.dart';

WatchRecordWithMovie _record({
  required int id,
  required int movieId,
  required String genres,
  required String director,
  required String actors,
  String? tags,
  int? runtime,
  int episodeCount = 1,
}) {
  final movie = Movie(
    tmdbId: movieId,
    title: 'Movie $movieId',
    isTv: false,
    genres: genres,
    director: director,
    actors: actors,
    runtime: runtime,
    createdAt: DateTime.now(),
  );
  final record = WatchRecord(
    id: id,
    movieId: movieId,
    isTv: false,
    watchDate: DateTime(2026, 1, id),
    rating: 8,
    watchNumber: 1,
    tags: tags,
    createdAt: DateTime.now(),
    episodeCount: episodeCount,
    isPublic: false,
  );
  return WatchRecordWithMovie(record, movie);
}

void main() {
  test('insightsProvider aggregates genres, directors, actors and tags correctly', () async {
    final records = [
      _record(id: 1, movieId: 1, genres: 'Dram, Bilim Kurgu', director: 'Christopher Nolan', actors: 'A, B', tags: 'sinema,gece'),
      _record(id: 2, movieId: 2, genres: 'Dram', director: 'Christopher Nolan', actors: 'B, C', tags: 'gece'),
    ];

    final container = ProviderContainer(overrides: [
      allWatchRecordsProvider.overrideWith((ref) => Stream.value(records)),
    ]);
    addTearDown(container.dispose);

    await container.read(allWatchRecordsProvider.future);
    final data = container.read(insightsProvider)!;

    expect(data.topGenres.firstWhere((e) => e.key == 'Dram').value, 2);
    expect(data.topGenres.firstWhere((e) => e.key == 'Bilim Kurgu').value, 1);
    expect(data.topDirectors.firstWhere((e) => e.key == 'Christopher Nolan').value, 2);
    expect(data.topActors.firstWhere((e) => e.key == 'B').value, 2);
    expect(data.topTags.firstWhere((e) => e.key == 'gece').value, 2);
    expect(data.totalWatchCount, 2);
  });

  test('totalDurationMinutes scales a watch record by its episodeCount', () async {
    final records = [
      // A single-movie watch: duration is just the runtime.
      _record(id: 1, movieId: 1, genres: 'Dram', director: 'A', actors: 'A', runtime: 120, episodeCount: 1),
      // A binge-watched TV record covering 3 episodes of a 120-minute show.
      _record(id: 2, movieId: 2, genres: 'Dram', director: 'B', actors: 'B', runtime: 120, episodeCount: 3),
    ];

    final container = ProviderContainer(overrides: [
      allWatchRecordsProvider.overrideWith((ref) => Stream.value(records)),
    ]);
    addTearDown(container.dispose);

    await container.read(allWatchRecordsProvider.future);
    final data = container.read(insightsProvider)!;

    expect(data.totalDurationMinutes, 120 * 1 + 120 * 3);
  });
}
