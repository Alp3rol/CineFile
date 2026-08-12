import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/features/import_export/domain/cinefile_csv_exporter.dart';
import 'package:cinefile/features/import_export/domain/letterboxd_csv_parser.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final watchedAt = DateTime(2026, 8, 13, 21, 30);
  final entry = WatchRecordWithMovie(
    WatchRecord(
      id: 1,
      movieId: 125988,
      isTv: true,
      watchDate: watchedAt,
      rating: 8,
      mood: 'Great',
      watchNumber: 2,
      episodeCount: 3,
      createdAt: watchedAt,
      isPublic: false,
    ),
    Movie(
      tmdbId: 125988,
      title: 'Silo, Season One',
      releaseYear: 2023,
      isTv: true,
      createdAt: watchedAt,
    ),
  );

  test('exports readable CineFile fields with safe CSV escaping', () {
    final output = const CineFileCsvExporter().export([entry]);
    final table = csv.decode(output);

    expect(table, hasLength(2));
    expect(table.first.take(5), ['Name', 'Year', 'Date', 'Rating', 'Rewatch']);
    expect(table[1][0], 'Silo, Season One');
    expect(table[1][3], '4.0');
    expect(table[1][4], 'Yes');
    expect(table[1][6], 'tv');
    expect(table[1][8], '3');
    expect(table[1][14], 'private');
  });

  test('export can be read back by the Letterboxd-compatible parser', () {
    final output = const CineFileCsvExporter().export([entry]);

    final preview = const LetterboxdCsvParser().parse(output);

    expect(preview.validCount, 1);
    expect(preview.rows.single.name, 'Silo, Season One');
    expect(preview.rows.single.rating, 4);
    expect(preview.rows.single.rewatch, isTrue);
    expect(preview.rows.single.watchedDate, DateTime(2026, 8, 13));
  });
}
