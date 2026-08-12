import 'package:cinefile/features/import_export/domain/import_duplicate_policy.dart';
import 'package:cinefile/features/import_export/domain/letterboxd_csv_parser.dart';
import 'package:cinefile/features/import_export/domain/tmdb_import_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LetterboxdPreviewRow row(int number, DateTime date) => LetterboxdPreviewRow(
    rowNumber: number,
    name: 'Silo',
    year: 2023,
    watchedDate: date,
    rating: 4,
    rewatch: number > 2,
    issues: const [],
  );

  const candidate = ImportMatchCandidate(
    tmdbId: 125988,
    title: 'Silo',
    year: 2023,
    isTv: true,
    score: .95,
  );
  const matched = ImportRowMatch(
    status: ImportMatchStatus.matched,
    candidates: [candidate],
    selected: candidate,
  );

  test('detects an exact title type and calendar-date collision', () {
    final date = DateTime(2026, 8, 13, 20);
    final conflicts = const ImportDuplicatePolicy().detect(
      rows: [row(2, date)],
      matches: const {2: matched},
      existingRecords: [
        ExistingImportRecord(
          tmdbId: 125988,
          isTv: true,
          watchDate: DateTime(2026, 8, 13, 9),
        ),
      ],
    );

    expect(conflicts[2]?.existingCount, 1);
    expect(conflicts[2]?.resolution, ImportDuplicateResolution.skip);
  });

  test('movie and TV ids do not collide', () {
    final conflicts = const ImportDuplicatePolicy().detect(
      rows: [row(2, DateTime(2026, 8, 13))],
      matches: const {2: matched},
      existingRecords: [
        ExistingImportRecord(
          tmdbId: 125988,
          isTv: false,
          watchDate: DateTime(2026, 8, 13),
        ),
      ],
    );

    expect(conflicts, isEmpty);
  });

  test('detects duplicates inside the same CSV', () {
    final date = DateTime(2026, 8, 13);
    final conflicts = const ImportDuplicatePolicy().detect(
      rows: [row(2, date), row(3, date)],
      matches: const {2: matched, 3: matched},
      existingRecords: const [],
    );

    expect(conflicts.keys, containsAll([2, 3]));
    expect(conflicts[2]?.csvRowNumbers, [2, 3]);
  });

  test('a user resolution is retained without changing the conflict', () {
    final conflict = ImportDuplicateConflict(
      row: row(2, DateTime(2026, 8, 13)),
      match: candidate,
      existingCount: 1,
      csvRowNumbers: const [2],
    );

    final resolved = conflict.resolve(ImportDuplicateResolution.addAsRewatch);

    expect(resolved.resolution, ImportDuplicateResolution.addAsRewatch);
    expect(resolved.match.tmdbId, conflict.match.tmdbId);
  });
}
