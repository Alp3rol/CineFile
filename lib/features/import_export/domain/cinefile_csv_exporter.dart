import 'package:csv/csv.dart';

import '../../../core/database/database_provider.dart';

class CineFileCsvExporter {
  const CineFileCsvExporter();

  String export(List<WatchRecordWithMovie> entries) {
    final rows = <List<dynamic>>[
      const [
        'Name',
        'Year',
        'Date',
        'Rating',
        'Rewatch',
        'TMDb ID',
        'Type',
        'Watch Number',
        'Episode Count',
        'Watch Place',
        'Watch Companion',
        'Mood',
        'Notes',
        'Tags',
        'Visibility',
      ],
      ...entries.map(_row),
    ];
    return csv.encode(rows);
  }

  List<dynamic> _row(WatchRecordWithMovie entry) {
    final record = entry.record;
    final movie = entry.movie;
    return [
      movie.title,
      movie.releaseYear ?? '',
      _date(record.watchDate),
      record.rating > 0 ? record.rating / 2 : '',
      record.watchNumber > 1 ? 'Yes' : 'No',
      movie.tmdbId,
      movie.isTv ? 'tv' : 'movie',
      record.watchNumber,
      record.episodeCount,
      record.watchPlace ?? '',
      record.watchCompanion ?? '',
      record.mood ?? '',
      record.notes ?? '',
      record.tags ?? '',
      record.isPublic ? 'public' : 'private',
    ];
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
