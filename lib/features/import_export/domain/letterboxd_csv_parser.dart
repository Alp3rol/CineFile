import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

class LetterboxdCsvException implements Exception {
  const LetterboxdCsvException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LetterboxdPreviewRow {
  const LetterboxdPreviewRow({
    required this.rowNumber,
    required this.name,
    required this.year,
    required this.watchedDate,
    required this.rating,
    required this.rewatch,
    required this.issues,
  });

  final int rowNumber;
  final String name;
  final int? year;
  final DateTime? watchedDate;
  final double? rating;
  final bool rewatch;
  final List<String> issues;

  bool get isValid => issues.isEmpty;
}

class LetterboxdCsvPreview {
  const LetterboxdCsvPreview(this.rows);
  final List<LetterboxdPreviewRow> rows;

  int get validCount => rows.where((row) => row.isValid).length;
  int get invalidCount => rows.length - validCount;
}

class LetterboxdCsvParser {
  const LetterboxdCsvParser();

  static const maxBytes = 5 * 1024 * 1024;
  static const maxRows = 10000;

  LetterboxdCsvPreview parseBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const LetterboxdCsvException('CSV file is empty.');
    }
    if (bytes.length > maxBytes) {
      throw const LetterboxdCsvException('CSV file is larger than 5 MiB.');
    }

    late final String content;
    try {
      content = utf8.decode(bytes);
    } on FormatException {
      throw const LetterboxdCsvException('CSV file must use UTF-8 encoding.');
    }
    return parse(content);
  }

  LetterboxdCsvPreview parse(String content) {
    late final List<List<dynamic>> table;
    try {
      table = csv.decode(content);
    } catch (_) {
      throw const LetterboxdCsvException('CSV structure is invalid.');
    }
    if (table.isEmpty) {
      throw const LetterboxdCsvException('CSV file is empty.');
    }

    final headers = table.first
        .map((value) => value.toString().replaceFirst('\ufeff', '').trim())
        .toList();
    final index = <String, int>{
      for (var i = 0; i < headers.length; i++) headers[i].toLowerCase(): i,
    };
    if (!index.containsKey('name') || !index.containsKey('year')) {
      throw const LetterboxdCsvException(
        'Required columns are missing: Name and Year.',
      );
    }
    final dateKey = index.containsKey('watched date')
        ? 'watched date'
        : index.containsKey('date')
        ? 'date'
        : null;
    if (dateKey == null) {
      throw const LetterboxdCsvException(
        'Required date column is missing: Watched Date or Date.',
      );
    }
    if (table.length - 1 > maxRows) {
      throw const LetterboxdCsvException('CSV contains more than 10,000 rows.');
    }

    String field(List<dynamic> row, String name) {
      final position = index[name];
      if (position == null || position >= row.length) return '';
      return row[position].toString().trim();
    }

    final rows = <LetterboxdPreviewRow>[];
    for (var i = 1; i < table.length; i++) {
      final source = table[i];
      final name = field(source, 'name');
      final yearText = field(source, 'year');
      final dateText = field(source, dateKey);
      final ratingText = field(source, 'rating');
      final issues = <String>[];

      if (name.isEmpty) issues.add('Missing title');
      final year = int.tryParse(yearText);
      if (year == null || year < 1888 || year > DateTime.now().year + 5) {
        issues.add('Invalid year');
      }
      final watchedDate = DateTime.tryParse(dateText);
      if (watchedDate == null) issues.add('Invalid watched date');

      double? rating;
      if (ratingText.isNotEmpty) {
        rating = double.tryParse(ratingText.replaceAll(',', '.'));
        if (rating == null || rating < 0.5 || rating > 5) {
          issues.add('Invalid rating');
          rating = null;
        }
      }

      final rewatchText = field(source, 'rewatch').toLowerCase();
      rows.add(
        LetterboxdPreviewRow(
          rowNumber: i + 1,
          name: name,
          year: year,
          watchedDate: watchedDate,
          rating: rating,
          rewatch: rewatchText == 'yes' || rewatchText == 'true',
          issues: List.unmodifiable(issues),
        ),
      );
    }
    return LetterboxdCsvPreview(List.unmodifiable(rows));
  }
}
