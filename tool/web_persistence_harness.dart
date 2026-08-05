import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/web_local_store.dart';
import 'package:cinefile/core/platform/firebase_web_registrar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal browser harness for the real SharedPreferences-backed web store.
///
/// Build/run with:
/// `flutter run -d web-server -t tool/web_persistence_harness.dart`
///
/// `?seed=1` writes a deterministic collection. Opening the same origin
/// without that query and reloading proves startup hydration independently of
/// the production authentication flow.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFirebaseWebPlugins();

  final corruptStoreTest = Uri.base.queryParameters['corrupt'] == '1';
  if (corruptStoreTest) {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('cinefile_web_collections_v1', '{not-json');
  }
  await WebLocalStore.initialize();

  if (Uri.base.queryParameters['seed'] == '1') {
    final movie = Movie(
      tmdbId: 27205,
      title: 'Persistence Test Movie',
      isTv: false,
      createdAt: DateTime.utc(2026, 8, 5),
    );
    final list = CustomList(
      id: 1,
      name: 'Persistence Test Collection',
      description: 'browser reload regression fixture',
      createdAt: DateTime.utc(2026, 8, 5),
      isPublic: false,
    );
    await WebLocalStore.save(
      movies: {(tmdbId: movie.tmdbId, isTv: movie.isTv): movie},
      customLists: {list.id: list},
      customListMovies: [
        CustomListMovie(
          listId: list.id,
          movieId: movie.tmdbId,
          isTv: movie.isTv,
          rankingOrder: 1,
          addedAt: DateTime.utc(2026, 8, 5),
        ),
      ],
    );
  }

  final snapshot = WebLocalStore.snapshot;
  final collection = snapshot.customLists[1];
  final movie = snapshot.movies[(tmdbId: 27205, isTv: false)];
  final relationPresent = snapshot.customListMovies.any(
    (entry) => entry.listId == 1 && entry.movieId == 27205 && !entry.isTv,
  );

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Semantics(
            label: 'Web persistence result',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (corruptStoreTest) const Text('CORRUPT_STORE_RECOVERED'),
                Text(
                  collection == null
                      ? 'COLLECTION_MISSING'
                      : 'COLLECTION_OK:${collection.name}',
                ),
                Text(
                  movie == null ? 'MOVIE_MISSING' : 'MOVIE_OK:${movie.title}',
                ),
                Text(relationPresent ? 'RELATION_OK' : 'RELATION_MISSING'),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
