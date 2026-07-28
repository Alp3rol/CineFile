/// The single source of truth for TMDb genre identity.
///
/// Genres used to be handled as *localized display names* — TMDb was asked for
/// Turkish, and the Turkish name was stored in `Movies.genres`, matched against
/// hardcoded Turkish strings for statistics and achievements, and mapped back
/// to TMDb ids through two separate copies of a name→id table. That works
/// exactly as long as the app only ever speaks one language: the moment a user
/// switches to English, newly stored titles carry English genre names, the
/// stored history carries Turkish ones, and every genre-based statistic splits
/// in two.
///
/// Ids are language-independent, so they are what gets stored and compared.
/// Display names are looked up at render time.
library;

/// TMDb genre ids.
///
/// Movies and TV shows have separate genre vocabularies on TMDb, but the ids
/// share one numeric space and never collide, so a single set of constants
/// covers both. Ids marked "TV" only ever appear on shows and vice versa.
abstract final class TmdbGenre {
  // Movie vocabulary
  static const int action = 28;
  static const int adventure = 12;
  static const int fantasy = 14;
  static const int horror = 27;
  static const int history = 36;
  static const int romance = 10749;
  static const int scienceFiction = 878;
  static const int thriller = 53;
  static const int music = 10402;
  static const int war = 10752;

  // Shared between movies and TV
  static const int animation = 16;
  static const int comedy = 35;
  static const int crime = 80;
  static const int documentary = 99;
  static const int drama = 18;
  static const int family = 10751;
  static const int mystery = 9648;
  static const int western = 37;

  // TV vocabulary
  static const int actionAdventure = 10759;
  static const int kids = 10762;
  static const int news = 10763;
  static const int reality = 10764;
  static const int sciFiFantasy = 10765;
  static const int soap = 10766;
  static const int talk = 10767;
  static const int warPolitics = 10768;
}

/// Genres offered as filter chips / discovery targets for movies, in the order
/// they should be shown.
const List<int> kMovieGenreIds = [
  TmdbGenre.action,
  TmdbGenre.adventure,
  TmdbGenre.animation,
  TmdbGenre.comedy,
  TmdbGenre.crime,
  TmdbGenre.documentary,
  TmdbGenre.drama,
  TmdbGenre.family,
  TmdbGenre.fantasy,
  TmdbGenre.history,
  TmdbGenre.horror,
  TmdbGenre.music,
  TmdbGenre.mystery,
  TmdbGenre.romance,
  TmdbGenre.scienceFiction,
  TmdbGenre.thriller,
  TmdbGenre.war,
  TmdbGenre.western,
];

/// Genres offered for TV shows, in display order.
const List<int> kTvGenreIds = [
  TmdbGenre.actionAdventure,
  TmdbGenre.animation,
  TmdbGenre.comedy,
  TmdbGenre.crime,
  TmdbGenre.documentary,
  TmdbGenre.drama,
  TmdbGenre.family,
  TmdbGenre.kids,
  TmdbGenre.mystery,
  TmdbGenre.news,
  TmdbGenre.reality,
  TmdbGenre.sciFiFantasy,
  TmdbGenre.soap,
  TmdbGenre.talk,
  TmdbGenre.warPolitics,
  TmdbGenre.western,
];

/// TMDb's Turkish genre names, keyed by id.
///
/// Only used to recover ids from rows written before ids were stored — every
/// such row was necessarily written in Turkish, because that was the only
/// language the app supported. Not for display: that goes through
/// AppLocalizations so it follows the user's chosen language.
const Map<int, String> _legacyTurkishNames = {
  TmdbGenre.action: 'Aksiyon',
  TmdbGenre.adventure: 'Macera',
  TmdbGenre.animation: 'Animasyon',
  TmdbGenre.comedy: 'Komedi',
  TmdbGenre.crime: 'Suç',
  TmdbGenre.documentary: 'Belgesel',
  TmdbGenre.drama: 'Dram',
  TmdbGenre.family: 'Aile',
  TmdbGenre.fantasy: 'Fantastik',
  TmdbGenre.history: 'Tarih',
  TmdbGenre.horror: 'Korku',
  TmdbGenre.music: 'Müzik',
  TmdbGenre.mystery: 'Gizem',
  TmdbGenre.romance: 'Romantik',
  TmdbGenre.scienceFiction: 'Bilim Kurgu',
  TmdbGenre.thriller: 'Gerilim',
  TmdbGenre.war: 'Savaş',
  TmdbGenre.western: 'Vahşi Batı',
  TmdbGenre.actionAdventure: 'Aksiyon & Macera',
  TmdbGenre.kids: 'Çocuk',
  TmdbGenre.news: 'Haberler',
  TmdbGenre.reality: 'Realite',
  TmdbGenre.sciFiFantasy: 'Bilim Kurgu & Fantazi',
  TmdbGenre.soap: 'Pembe Dizi',
  TmdbGenre.talk: 'Talk Show',
  TmdbGenre.warPolitics: 'Savaş & Politika',
};

/// Reverse of [_legacyTurkishNames], lowercased so matching tolerates the
/// casing TMDb happened to return.
final Map<String, int> _legacyTurkishIds = {
  for (final entry in _legacyTurkishNames.entries) entry.value.toLowerCase(): entry.key,
};

/// Parses the comma-separated `Movies.genreIds` column.
///
/// Unparseable fragments are skipped rather than throwing: this column is
/// written by backfill and by restored backups, and one malformed row should
/// not break a screen that aggregates over the whole library.
List<int> parseGenreIds(String? stored) {
  if (stored == null || stored.isEmpty) return const [];
  return stored
      .split(',')
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .toList();
}

/// Serialises ids for storage in `Movies.genreIds`. Returns null for an empty
/// list so "no genres" stays a NULL column rather than an empty string.
String? formatGenreIds(Iterable<int> ids) {
  if (ids.isEmpty) return null;
  return ids.join(',');
}

/// Recovers genre ids from a legacy comma-separated Turkish name string.
///
/// Used by the schema 12→13 migration and when restoring a backup taken before
/// ids were stored. Names TMDb has since changed, or that were never in the
/// table, simply don't resolve — the row keeps an empty [genreIds] and is
/// repopulated for free the next time its details are fetched from TMDb.
List<int> genreIdsFromLegacyNames(String? genres) {
  if (genres == null || genres.isEmpty) return const [];
  return genres
      .split(',')
      .map((name) => _legacyTurkishIds[name.trim().toLowerCase()])
      .whereType<int>()
      .toList();
}

/// Extracts genre ids from a raw TMDb payload.
///
/// Detail endpoints return `genres: [{id, name}]` while search/discover
/// endpoints return a flat `genre_ids: [int]`, so both shapes are accepted.
List<int> genreIdsFromTmdbPayload(Map<String, dynamic> payload) {
  final detailed = payload['genres'];
  if (detailed is List) {
    final ids = detailed
        .map((e) => e is Map ? (e['id'] as num?)?.toInt() : null)
        .whereType<int>()
        .toList();
    if (ids.isNotEmpty) return ids;
  }

  final flat = payload['genre_ids'];
  if (flat is List) {
    return flat.map((e) => (e as num?)?.toInt()).whereType<int>().toList();
  }

  return const [];
}
