import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/features/journal/presentation/journal_logic.dart';

void main() {
  final movieA = Movie(
    tmdbId: 1,
    title: 'Alpha',
    createdAt: DateTime(2026, 1, 1),
    isTv: false,
    releaseYear: 2010,
    runtime: 120,
  );

  final movieB = Movie(
    tmdbId: 2,
    title: 'Zeta',
    createdAt: DateTime(2026, 1, 1),
    isTv: false,
    releaseYear: 2024,
    runtime: 90,
  );

  final recordA = WatchRecord(
    id: 1,
    movieId: 1,
    isTv: false,
    watchDate: DateTime(2026, 1, 10),
    rating: 7.5,
    watchNumber: 1,
    episodeCount: 1,
    createdAt: DateTime(2026, 1, 10),
    isPublic: true,
  );

  final recordB = WatchRecord(
    id: 2,
    movieId: 2,
    isTv: false,
    watchDate: DateTime(2026, 2, 20),
    rating: 9.0,
    watchNumber: 1,
    episodeCount: 1,
    createdAt: DateTime(2026, 2, 20),
    isPublic: true,
  );

  final itemA = WatchRecordWithMovie(recordA, movieA);
  final itemB = WatchRecordWithMovie(recordB, movieB);
  final list = [itemA, itemB];

  group('Journal sort tests', () {
    test('sorts by watchDate descending and ascending', () {
      final desc = sortJournalRecords(list, sortBy: JournalSortOption.watchDate, ascending: false);
      expect(desc.first.movie.title, 'Zeta');

      final asc = sortJournalRecords(list, sortBy: JournalSortOption.watchDate, ascending: true);
      expect(asc.first.movie.title, 'Alpha');
    });

    test('sorts by rating descending and ascending', () {
      final desc = sortJournalRecords(list, sortBy: JournalSortOption.rating, ascending: false);
      expect(desc.first.movie.title, 'Zeta');

      final asc = sortJournalRecords(list, sortBy: JournalSortOption.rating, ascending: true);
      expect(asc.first.movie.title, 'Alpha');
    });

    test('sorts by title alphabetically', () {
      final asc = sortJournalRecords(list, sortBy: JournalSortOption.title, ascending: true);
      expect(asc.first.movie.title, 'Alpha');

      final desc = sortJournalRecords(list, sortBy: JournalSortOption.title, ascending: false);
      expect(desc.first.movie.title, 'Zeta');
    });

    test('sorts by runtime', () {
      final desc = sortJournalRecords(list, sortBy: JournalSortOption.runtime, ascending: false);
      expect(desc.first.movie.title, 'Alpha'); // 120 > 90
    });

    test('sorts by releaseYear', () {
      final desc = sortJournalRecords(list, sortBy: JournalSortOption.releaseYear, ascending: false);
      expect(desc.first.movie.title, 'Zeta'); // 2024 > 2010
    });
  });
}
