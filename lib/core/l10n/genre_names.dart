import '../../l10n/app_localizations.dart';
import '../constants/tmdb_genres.dart';

/// Resolves a stored TMDb genre id to its name in the user's language.
///
/// Genres are stored and compared as ids (see [TmdbGenre]); this is the only
/// place they turn back into text. An id the app doesn't know — TMDb has
/// retired genres before — renders as "unknown" rather than disappearing, so a
/// title never silently looks genre-less.
String genreName(AppLocalizations l10n, int id) {
  return switch (id) {
    TmdbGenre.action => l10n.genreAction,
    TmdbGenre.adventure => l10n.genreAdventure,
    TmdbGenre.animation => l10n.genreAnimation,
    TmdbGenre.comedy => l10n.genreComedy,
    TmdbGenre.crime => l10n.genreCrime,
    TmdbGenre.documentary => l10n.genreDocumentary,
    TmdbGenre.drama => l10n.genreDrama,
    TmdbGenre.family => l10n.genreFamily,
    TmdbGenre.fantasy => l10n.genreFantasy,
    TmdbGenre.history => l10n.genreHistory,
    TmdbGenre.horror => l10n.genreHorror,
    TmdbGenre.music => l10n.genreMusic,
    TmdbGenre.mystery => l10n.genreMystery,
    TmdbGenre.romance => l10n.genreRomance,
    TmdbGenre.scienceFiction => l10n.genreScienceFiction,
    TmdbGenre.thriller => l10n.genreThriller,
    TmdbGenre.war => l10n.genreWar,
    TmdbGenre.western => l10n.genreWestern,
    TmdbGenre.actionAdventure => l10n.genreActionAdventure,
    TmdbGenre.kids => l10n.genreKids,
    TmdbGenre.news => l10n.genreNews,
    TmdbGenre.reality => l10n.genreReality,
    TmdbGenre.sciFiFantasy => l10n.genreSciFiFantasy,
    TmdbGenre.soap => l10n.genreSoap,
    TmdbGenre.talk => l10n.genreTalk,
    TmdbGenre.warPolitics => l10n.genreWarPolitics,
    _ => l10n.genreUnknown,
  };
}
