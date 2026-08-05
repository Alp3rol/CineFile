part of 'database_provider.dart';

// Web collection state is hydrated from browser storage before ProviderScope
// starts; repository mutations persist each complete snapshot.
final webCustomListsProvider = StateProvider<Map<int, CustomList>>(
  (ref) => Map.of(WebLocalStore.snapshot.customLists),
);
final webCustomListMoviesProvider = StateProvider<List<CustomListMovie>>(
  (ref) => List.of(WebLocalStore.snapshot.customListMovies),
);

// Stream provider to get all custom lists
final customListsProvider = StreamProvider<List<CustomList>>((ref) {
  if (kIsWeb) {
    final map = ref.watch(webCustomListsProvider);
    final sorted = map.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Stream.value(sorted);
  }

  final db = ref.watch(databaseProvider);
  return (db.select(
    db.customLists,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
});

class CustomListMovieWithMovie {
  final CustomListMovie relation;
  final Movie movie;
  CustomListMovieWithMovie(this.relation, this.movie);
}

// Stream provider to get movies in a specific list, ordered by rankingOrder or addedAt
final moviesInCustomListProvider =
    StreamProvider.family<List<CustomListMovieWithMovie>, int>((ref, listId) {
      if (kIsWeb) {
        final list = ref.watch(webCustomListMoviesProvider);
        final movies = ref.watch(webMoviesProvider);

        final filtered = list.where((r) => r.listId == listId).map((r) {
          final movie =
              movies[(tmdbId: r.movieId, isTv: r.isTv)] ??
              Movie(
                tmdbId: r.movieId,
                title: 'Bilinmeyen Film',
                isTv: r.isTv,
                createdAt: DateTime.now(),
              );
          return CustomListMovieWithMovie(r, movie);
        }).toList();

        // Sort: if rankingOrder is not null, sort by it, otherwise sort by addedAt descending
        filtered.sort((a, b) {
          final rA = a.relation.rankingOrder;
          final rB = b.relation.rankingOrder;
          if (rA != null && rB != null) {
            return rA.compareTo(rB);
          } else if (rA != null) {
            return -1;
          } else if (rB != null) {
            return 1;
          } else {
            return b.relation.addedAt.compareTo(a.relation.addedAt);
          }
        });
        return Stream.value(filtered);
      }

      final db = ref.watch(databaseProvider);
      final query = db.select(db.customListMovies).join([
        leftOuterJoin(
          db.movies,
          db.movies.tmdbId.equalsExp(db.customListMovies.movieId) &
              db.movies.isTv.equalsExp(db.customListMovies.isTv),
        ),
      ])..where(db.customListMovies.listId.equals(listId));

      // Order: first by rankingOrder (ascending), then addedAt (descending)
      query.orderBy([
        OrderingTerm.asc(db.customListMovies.rankingOrder),
        OrderingTerm.desc(db.customListMovies.addedAt),
      ]);

      return query.watch().map((rows) {
        return rows.map((row) {
          return CustomListMovieWithMovie(
            row.readTable(db.customListMovies),
            row.readTable(db.movies),
          );
        }).toList();
      });
    });

// Stream provider to find which lists a movie belongs to
final listsForMovieProvider = StreamProvider.family<Set<int>, MovieKey>((
  ref,
  key,
) {
  if (kIsWeb) {
    final list = ref.watch(webCustomListMoviesProvider);
    return Stream.value(
      list
          .where((r) => r.movieId == key.tmdbId && r.isTv == key.isTv)
          .map((r) => r.listId)
          .toSet(),
    );
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.customListMovies)
        ..where((t) => t.movieId.equals(key.tmdbId) & t.isTv.equals(key.isTv)))
      .watch()
      .map((list) => list.map((e) => e.listId).toSet());
});

// --- CUSTOM LIST ACTIONS ---
//
// These delegate to movieRepositoryProvider (see movie_repository.dart),
// which picks the native (Drift/SQLite) or web (in-memory) implementation.
// Kept as free functions so existing call sites don't need to change.

Future<void> createCustomList(
  WidgetRef ref,
  String name,
  String? description, {
  DateTime? targetDate,
}) => ref
    .read(movieRepositoryProvider)
    .createCustomList(name, description, targetDate: targetDate);

Future<void> updateCustomList(
  WidgetRef ref,
  int id,
  String name,
  String? description, {
  DateTime? targetDate,
  bool clearTargetDate = false,
}) => ref
    .read(movieRepositoryProvider)
    .updateCustomList(
      id,
      name,
      description,
      targetDate: targetDate,
      clearTargetDate: clearTargetDate,
    );

Future<void> deleteCustomList(WidgetRef ref, int id) =>
    ref.read(movieRepositoryProvider).deleteCustomList(id);

Future<void> addMovieToCustomList(WidgetRef ref, int listId, Movie movieData) =>
    ref.read(movieRepositoryProvider).addMovieToCustomList(listId, movieData);

Future<void> removeMovieFromCustomList(
  WidgetRef ref,
  int listId,
  int tmdbId,
  bool isTv,
) => ref
    .read(movieRepositoryProvider)
    .removeMovieFromCustomList(listId, tmdbId, isTv);

Future<void> reorderCustomListMovies(
  WidgetRef ref,
  int listId,
  Map<MovieKey, int> rankings,
) =>
    ref.read(movieRepositoryProvider).reorderCustomListMovies(listId, rankings);

Future<void> setCollectionVisibility(
  WidgetRef ref,
  int listId,
  bool isPublic,
) =>
    ref.read(movieRepositoryProvider).setCollectionVisibility(listId, isPublic);

// Live view of a shared collection's current contents â€” used by the
// Community feed's 'collection' post cards and shared_collection_detail_
// screen.dart. Returns null once the doc doesn't exist (owner turned
// sharing off, or it was never shared), which callers render as a graceful
// "no longer shared" state rather than an error.
final sharedCollectionProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((
      ref,
      collectionRefId,
    ) {
      return ref
          .watch(firestoreProvider)
          .collection('shared_collections')
          .doc(collectionRefId)
          .snapshots()
          .map((doc) => doc.data());
    });
