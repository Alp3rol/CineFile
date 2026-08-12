import 'letterboxd_csv_parser.dart';

enum ImportMatchStatus { matched, needsReview, notFound, failed }

class ImportMatchCandidate {
  const ImportMatchCandidate({
    required this.tmdbId,
    required this.title,
    required this.year,
    required this.isTv,
    required this.score,
  });

  final int tmdbId;
  final String title;
  final int? year;
  final bool isTv;
  final double score;
}

class ImportRowMatch {
  const ImportRowMatch({
    required this.status,
    required this.candidates,
    this.selected,
  });

  final ImportMatchStatus status;
  final List<ImportMatchCandidate> candidates;
  final ImportMatchCandidate? selected;

  ImportRowMatch confirm(ImportMatchCandidate candidate) => ImportRowMatch(
    status: ImportMatchStatus.matched,
    candidates: candidates,
    selected: candidate,
  );
}

typedef TmdbTitleSearch =
    Future<List<Map<String, dynamic>>> Function(String query);

class TmdbImportMatcher {
  const TmdbImportMatcher(this._search);
  final TmdbTitleSearch _search;

  Future<ImportRowMatch> match(LetterboxdPreviewRow row) async {
    if (!row.isValid || row.year == null) {
      return const ImportRowMatch(
        status: ImportMatchStatus.failed,
        candidates: [],
      );
    }
    try {
      final results = await _search(row.name);
      final candidates =
          results
              .map((result) => _candidate(row, result))
              .whereType<ImportMatchCandidate>()
              .toList()
            ..sort((a, b) => b.score.compareTo(a.score));
      final shortlist = candidates.take(5).toList(growable: false);
      if (shortlist.isEmpty || shortlist.first.score < 0.45) {
        return const ImportRowMatch(
          status: ImportMatchStatus.notFound,
          candidates: [],
        );
      }
      final first = shortlist.first;
      final gap = shortlist.length == 1
          ? 1.0
          : first.score - shortlist[1].score;
      final confident = first.score >= 0.9 && gap >= 0.15;
      return ImportRowMatch(
        status: confident
            ? ImportMatchStatus.matched
            : ImportMatchStatus.needsReview,
        candidates: shortlist,
        selected: confident ? first : null,
      );
    } catch (_) {
      return const ImportRowMatch(
        status: ImportMatchStatus.failed,
        candidates: [],
      );
    }
  }

  ImportMatchCandidate? _candidate(
    LetterboxdPreviewRow row,
    Map<String, dynamic> result,
  ) {
    final id = (result['id'] as num?)?.toInt();
    if (id == null) return null;
    final title = (result['title'] ?? result['name'] ?? '').toString().trim();
    if (title.isEmpty) return null;
    final original = (result['original_title'] ?? result['original_name'] ?? '')
        .toString();
    final date = (result['release_date'] ?? result['first_air_date'] ?? '')
        .toString();
    final year = DateTime.tryParse(date)?.year;
    final source = _normalize(row.name);
    final normalizedTitle = _normalize(title);
    final normalizedOriginal = _normalize(original);

    var score = 0.0;
    if (source == normalizedTitle) {
      score += 0.65;
    } else if (normalizedTitle.contains(source) ||
        source.contains(normalizedTitle)) {
      score += 0.45;
    }
    if (source == normalizedOriginal && normalizedOriginal.isNotEmpty) {
      score += 0.05;
    }
    if (year == row.year) {
      score += 0.3;
    } else if (year != null && (year - row.year!).abs() == 1) {
      score += 0.1;
    }
    return ImportMatchCandidate(
      tmdbId: id,
      title: title,
      year: year,
      isTv: result['media_type'] == 'tv',
      score: score.clamp(0, 1),
    );
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ş', 's')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}
