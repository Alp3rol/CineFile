import 'dart:convert';
import 'dart:typed_data';

import 'package:cinefile/features/import_export/domain/letterboxd_csv_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = LetterboxdCsvParser();

  test('previews a Letterboxd diary without writing data', () {
    final preview = parser.parse('''
Date,Name,Year,Letterboxd URI,Rating,Rewatch,Tags,Watched Date
2026-08-01,"Arrival, The",2016,https://boxd.it/a,4.5,Yes,sci-fi,2026-07-31
2026-08-02,Silo,2023,https://boxd.it/b,4,No,,2026-08-02
''');

    expect(preview.rows, hasLength(2));
    expect(preview.validCount, 2);
    expect(preview.invalidCount, 0);
    expect(preview.rows.first.name, 'Arrival, The');
    expect(preview.rows.first.rating, 4.5);
    expect(preview.rows.first.rewatch, isTrue);
  });

  test('reports invalid rows instead of rejecting the whole preview', () {
    final preview = parser.parse('''
Name,Year,Date,Rating
,nope,not-a-date,8
Valid Film,2020,2026-08-01,3.5
''');

    expect(preview.validCount, 1);
    expect(preview.invalidCount, 1);
    expect(
      preview.rows.first.issues,
      containsAll([
        'Missing title',
        'Invalid year',
        'Invalid watched date',
        'Invalid rating',
      ]),
    );
  });

  test('requires Letterboxd title, year and date columns', () {
    expect(
      () => parser.parse('Title,Released\nArrival,2016'),
      throwsA(isA<LetterboxdCsvException>()),
    );
  });

  test('rejects an oversized file before decoding', () {
    expect(
      () => parser.parseBytes(
        Uint8List.fromList(
          utf8.encode('x' * (LetterboxdCsvParser.maxBytes + 1)),
        ),
      ),
      throwsA(isA<LetterboxdCsvException>()),
    );
  });
}
