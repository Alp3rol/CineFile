import 'package:cinefile/features/import_export/domain/letterboxd_csv_parser.dart';
import 'package:cinefile/features/import_export/domain/tmdb_import_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LetterboxdPreviewRow row({String name = 'Silo', int year = 2023}) =>
      LetterboxdPreviewRow(
        rowNumber: 2,
        name: name,
        year: year,
        watchedDate: DateTime(2026, 8, 13),
        rating: 4,
        rewatch: false,
        issues: const [],
      );

  test('exact title and year is matched automatically', () async {
    final matcher = TmdbImportMatcher(
      (_) async => [
        {
          'id': 125988,
          'name': 'Silo',
          'original_name': 'Silo',
          'first_air_date': '2023-05-04',
          'media_type': 'tv',
        },
      ],
    );

    final result = await matcher.match(row());

    expect(result.status, ImportMatchStatus.matched);
    expect(result.selected?.tmdbId, 125988);
    expect(result.selected?.isTv, isTrue);
  });

  test('ambiguous results require user review', () async {
    final matcher = TmdbImportMatcher(
      (_) async => [
        {
          'id': 1,
          'title': 'Crash',
          'release_date': '1996-07-17',
          'media_type': 'movie',
        },
        {
          'id': 2,
          'title': 'Crash',
          'release_date': '2004-09-10',
          'media_type': 'movie',
        },
      ],
    );

    final result = await matcher.match(row(name: 'Crash', year: 2000));

    expect(result.status, ImportMatchStatus.needsReview);
    expect(result.selected, isNull);
    expect(result.candidates, hasLength(2));
  });

  test('empty results are reported as not found', () async {
    final result = await TmdbImportMatcher((_) async => []).match(row());

    expect(result.status, ImportMatchStatus.notFound);
  });

  test('search failure is contained per row', () async {
    final matcher = TmdbImportMatcher((_) async => throw Exception('offline'));

    final result = await matcher.match(row());

    expect(result.status, ImportMatchStatus.failed);
  });

  test('user can confirm a review candidate', () async {
    const candidate = ImportMatchCandidate(
      tmdbId: 7,
      title: 'Silo',
      year: 2023,
      isTv: true,
      score: .8,
    );
    const match = ImportRowMatch(
      status: ImportMatchStatus.needsReview,
      candidates: [candidate],
    );

    final confirmed = match.confirm(candidate);

    expect(confirmed.status, ImportMatchStatus.matched);
    expect(confirmed.selected, same(candidate));
  });
}
