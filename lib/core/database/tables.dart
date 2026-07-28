import 'package:drift/drift.dart';

@DataClassName('Movie')
class Movies extends Table {
  IntColumn get tmdbId => integer()();
  TextColumn get title => text()();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  IntColumn get releaseYear => integer().nullable()();
  IntColumn get runtime => integer().nullable()();
  // The genre names TMDb returned, in whatever language it was asked for at
  // the time the row was written. Display-only, and only as a fallback for
  // rows genreIds could not be recovered for — see genreIds below.
  TextColumn get genres => text().nullable()(); // Comma-separated string
  // Comma-separated TMDb genre ids, the language-independent identity of this
  // title's genres. Everything that *compares* genres (statistics, tier
  // badges, filters, recommendations) must key off this rather than `genres`
  // above, which changes meaning when the user switches language and would
  // otherwise split a user's history into two incompatible halves.
  //
  // Nullable because rows written before schema 13 are backfilled from their
  // Turkish names on a best-effort basis; anything that doesn't resolve is
  // repopulated the next time the title's details are fetched.
  TextColumn get genreIds => text().nullable()();
  TextColumn get director => text().nullable()();
  TextColumn get actors => text().nullable()(); // Comma-separated string
  TextColumn get overview => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get language => text().nullable()();
  BoolColumn get isTv => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // TV shows only: total episode count from TMDb, cached so the "how many
  // episodes did you watch" input can be bounded without a live API call.
  IntColumn get totalEpisodes => integer().nullable()();

  // TMDb movie IDs and TV show IDs come from separate counters, so a movie
  // and a show can legitimately share the same numeric id. isTv must be part
  // of the primary key — otherwise adding one silently overwrites the other's
  // row via insertOnConflictUpdate (this caused a real bug: a TV show's
  // journal entry started opening an unrelated movie that happened to share
  // its tmdbId).
  @override
  Set<Column> get primaryKey => {tmdbId, isTv};
}

@DataClassName('WatchRecord')
class WatchRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get movieId => integer()();
  // Paired with movieId to identify which Movies row (movie or TV show) this
  // record belongs to, since Movies.primaryKey is now {tmdbId, isTv}. Plain
  // Drift doesn't support a declarative composite foreign key, so this isn't
  // wrapped in .references(); the (movieId, isTv) pair is matched explicitly
  // in every query/join instead (see database_provider.dart).
  BoolColumn get isTv => boolean().withDefault(const Constant(false))();
  DateTimeColumn get watchDate => dateTime()();
  TextColumn get watchPlace => text().nullable()();
  TextColumn get watchCompanion => text().nullable()();
  RealColumn get rating => real()(); // 1.0 - 10.0
  TextColumn get mood => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get watchNumber => integer()(); // 1st, 2nd, 3rd time etc.
  TextColumn get tags => text().nullable()(); // Comma-separated tags (e.g. "#cinema,#night")
  // How many episodes this single watch record covers (TV only; always 1
  // for movies). TMDb only exposes one flat episode_run_time per show, so
  // this lets duration stats scale with an actual binge session instead of
  // applying that single estimate uniformly to every logged watch.
  IntColumn get episodeCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // Whether the user chose to share this record on the Community feed.
  // Defaults to false (opt-in) so nothing is ever exposed without an
  // explicit choice.
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  // The Firestore `logs` document id this record came from, when it came from
  // Firestore (null for rows that only ever existed locally — guest mode, or
  // a restored backup taken before this field existed).
  //
  // `id` above is an autoIncrement int because the UI keys rows by it, so
  // records materialised from Firestore used to synthesise one as
  // `docId.hashCode`. Edits and deletes then had to *search* for the document
  // that hashed back to it, falling back to matching on
  // (watchDate, watchNumber, episodeCount) when the hash didn't line up — and
  // that tuple is not unique: two episodes logged in the same minute with the
  // same episodeCount are indistinguishable, so a delete could remove the
  // wrong one. Carrying the real document id makes the write path an exact
  // `doc(remoteId)` reference instead of a guess.
  TextColumn get remoteId => text().nullable()();
}

@DataClassName('UserMovieSetting')
class UserMovieSettings extends Table {
  IntColumn get tmdbId => integer()();
  // See Movies.isTv / WatchRecords.isTv for why this must be part of the key.
  BoolColumn get isTv => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isReWatchList => boolean().withDefault(const Constant(false))();
  IntColumn get personalRanking => integer().nullable()(); // Custom top list rank
  TextColumn get personalNotes => text().nullable()();
  TextColumn get personalTags => text().nullable()(); // Comma-separated string
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  // TV shows only: whether the user is currently tracking this show
  // episode-by-episode, and the last episode number they logged. Cleared
  // (isActivelyWatching=false) automatically once lastWatchedEpisode
  // reaches Movies.totalEpisodes — i.e. the show is "Tamamlandı".
  BoolColumn get isActivelyWatching => boolean().withDefault(const Constant(false))();
  IntColumn get lastWatchedEpisode => integer().nullable()();
  // Timestamp of the last quick-tap episode-progress advance (writeEpisode-
  // ProgressSettings), kept separate from `updatedAt` above because that
  // field is bumped by ANY settings write (favorite, ranking, notes...).
  // Insights/heatmap uses this dedicated field so favoriting a show isn't
  // mistaken for a day of watching activity.
  DateTimeColumn get lastEpisodeProgressAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tmdbId, isTv};
}

@DataClassName('CustomList')
class CustomLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()(); // Target end date for a watch marathon/challenge
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // Whether this collection is live-mirrored to Firestore's
  // shared_collections/{ownerId_listId} for the Community feed's "Koleksiyon
  // Paylaş" post type. Defaults to false (opt-in), same as
  // WatchRecords.isPublic — nothing is exposed without an explicit choice.
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
}

@DataClassName('CustomListMovie')
class CustomListMovies extends Table {
  IntColumn get listId => integer().references(CustomLists, #id, onDelete: KeyAction.cascade)();
  IntColumn get movieId => integer()();
  // See Movies.isTv / WatchRecords.isTv for why this must be part of the key.
  BoolColumn get isTv => boolean().withDefault(const Constant(false))();
  IntColumn get rankingOrder => integer().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {listId, movieId, isTv};
}
