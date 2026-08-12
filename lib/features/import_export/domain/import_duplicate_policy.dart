import 'letterboxd_csv_parser.dart';
import 'tmdb_import_matcher.dart';

enum ImportDuplicateResolution { skip, merge, addAsRewatch }

class ExistingImportRecord {
  const ExistingImportRecord({
    required this.tmdbId,
    required this.isTv,
    required this.watchDate,
    this.rating,
  });

  final int tmdbId;
  final bool isTv;
  final DateTime watchDate;
  final double? rating;
}

class ImportDuplicateConflict {
  const ImportDuplicateConflict({
    required this.row,
    required this.match,
    required this.existingCount,
    required this.csvRowNumbers,
    this.resolution = ImportDuplicateResolution.skip,
  });

  final LetterboxdPreviewRow row;
  final ImportMatchCandidate match;
  final int existingCount;
  final List<int> csvRowNumbers;
  final ImportDuplicateResolution resolution;

  ImportDuplicateConflict resolve(ImportDuplicateResolution value) =>
      ImportDuplicateConflict(
        row: row,
        match: match,
        existingCount: existingCount,
        csvRowNumbers: csvRowNumbers,
        resolution: value,
      );
}

class ImportDuplicatePolicy {
  const ImportDuplicatePolicy();

  Map<int, ImportDuplicateConflict> detect({
    required List<LetterboxdPreviewRow> rows,
    required Map<int, ImportRowMatch> matches,
    required List<ExistingImportRecord> existingRecords,
  }) {
    final incoming = <String, List<int>>{};
    for (final row in rows) {
      final candidate = matches[row.rowNumber]?.selected;
      if (!row.isValid || row.watchedDate == null || candidate == null) {
        continue;
      }
      incoming
          .putIfAbsent(
            _key(candidate.tmdbId, candidate.isTv, row.watchedDate!),
            () => [],
          )
          .add(row.rowNumber);
    }

    final existingCounts = <String, int>{};
    for (final record in existingRecords) {
      final key = _key(record.tmdbId, record.isTv, record.watchDate);
      existingCounts[key] = (existingCounts[key] ?? 0) + 1;
    }

    final conflicts = <int, ImportDuplicateConflict>{};
    for (final row in rows) {
      final candidate = matches[row.rowNumber]?.selected;
      if (!row.isValid || row.watchedDate == null || candidate == null) {
        continue;
      }
      final key = _key(candidate.tmdbId, candidate.isTv, row.watchedDate!);
      final csvRows = incoming[key] ?? const <int>[];
      final existingCount = existingCounts[key] ?? 0;
      if (existingCount == 0 && csvRows.length < 2) continue;
      conflicts[row.rowNumber] = ImportDuplicateConflict(
        row: row,
        match: candidate,
        existingCount: existingCount,
        csvRowNumbers: List.unmodifiable(csvRows),
      );
    }
    return conflicts;
  }

  String _key(int tmdbId, bool isTv, DateTime date) =>
      '$tmdbId:${isTv ? 1 : 0}:${date.year}-${date.month}-${date.day}';
}
