// Verifies the "canlı senkron" (live sync) design for "Koleksiyon Paylaş":
// turning sharing on mirrors the collection to Firestore immediately;
// turning it off deletes the mirror; and — the actual point of this
// feature — editing a SHARED collection afterward (adding/removing a
// movie) re-mirrors it automatically, while editing a private collection
// never touches Firestore at all.
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/core/database/movie_repository.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';

void main() {
  late AppDatabase db;
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      firebaseAuthProvider.overrideWithValue(
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'owner', email: 'owner@test.com')),
      ),
      firestoreProvider.overrideWithValue(firestore),
    ]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    // Settle authStateProvider before the repository reads it synchronously
    // (same gotcha documented in movie_repository_test.dart).
    await container.read(authStateProvider.future);
  });

  test('turning sharing on mirrors the collection; turning it off deletes the mirror', () async {
    final repo = container.read(movieRepositoryProvider);
    await repo.createCustomList('Halloween Marathon', 'spooky picks');
    final listId = (await db.select(db.customLists).get()).first.id;

    final movie = Movie(tmdbId: 1, title: 'Scream', isTv: false, posterPath: '/scream.jpg', createdAt: DateTime.now());
    await repo.addMovieToCustomList(listId, movie);

    await repo.setCollectionVisibility(listId, true);

    final docId = 'owner_$listId';
    final doc = await firestore.collection('shared_collections').doc(docId).get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['name'], 'Halloween Marathon');
    expect((doc.data()!['movies'] as List).length, 1);
    expect((doc.data()!['movies'] as List).first['title'], 'Scream');

    final listRow = await (db.select(db.customLists)..where((t) => t.id.equals(listId))).getSingle();
    expect(listRow.isPublic, isTrue);

    await repo.setCollectionVisibility(listId, false);

    final docAfter = await firestore.collection('shared_collections').doc(docId).get();
    expect(docAfter.exists, isFalse);
    final listRowAfter = await (db.select(db.customLists)..where((t) => t.id.equals(listId))).getSingle();
    expect(listRowAfter.isPublic, isFalse);
  });

  test('editing a SHARED collection re-mirrors it live', () async {
    final repo = container.read(movieRepositoryProvider);
    await repo.createCustomList('Watchlist', null);
    final listId = (await db.select(db.customLists).get()).first.id;
    await repo.setCollectionVisibility(listId, true);

    // The owner adds a movie AFTER sharing — the whole point of "canlı
    // senkron" is that viewers see this without the owner re-sharing.
    final newMovie = Movie(tmdbId: 2, title: 'Newly Added', isTv: false, createdAt: DateTime.now());
    await repo.addMovieToCustomList(listId, newMovie);

    final doc = await firestore.collection('shared_collections').doc('owner_$listId').get();
    final movies = doc.data()!['movies'] as List;
    expect(movies.length, 1);
    expect(movies.first['title'], 'Newly Added');

    // Removing it again also propagates.
    await repo.removeMovieFromCustomList(listId, 2, false);
    final docAfterRemove = await firestore.collection('shared_collections').doc('owner_$listId').get();
    expect((docAfterRemove.data()!['movies'] as List), isEmpty);
  });

  test('editing a PRIVATE collection never touches Firestore', () async {
    final repo = container.read(movieRepositoryProvider);
    await repo.createCustomList('Private List', null);
    final listId = (await db.select(db.customLists).get()).first.id;

    final movie = Movie(tmdbId: 3, title: 'Secret Movie', isTv: false, createdAt: DateTime.now());
    await repo.addMovieToCustomList(listId, movie);

    final doc = await firestore.collection('shared_collections').doc('owner_$listId').get();
    expect(doc.exists, isFalse);
  });
}
