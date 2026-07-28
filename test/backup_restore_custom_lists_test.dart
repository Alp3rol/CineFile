// BackupService spans two stores: the local drift database (collections and
// cached title metadata) and Firestore (`logs` + `users/{uid}/movie_settings`,
// where a signed-in user's watch history actually lives). These tests cover
// both halves, plus the signed-out and legacy-file cases.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/settings/presentation/settings_provider.dart';

const _uid = 'user-1';

void main() {
  group('BackupService Native Tests', () {
    late AppDatabase db;
    late FakeFirebaseFirestore firestore;
    late ProviderContainer container;

    ProviderContainer buildContainer({required bool signedIn}) {
      return ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        firestoreProvider.overrideWithValue(firestore),
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(
            signedIn: signedIn,
            mockUser: MockUser(uid: _uid, email: 'a@b.com'),
          ),
        ),
      ]);
    }

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      firestore = FakeFirebaseFirestore();
      container = buildContainer(signedIn: true);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<void> seedLocalCollection() async {
      await db.into(db.movies).insert(
            Movie(tmdbId: 101, title: 'Inception', isTv: false, createdAt: DateTime.now()),
          );
      await db.into(db.customLists).insert(
            CustomList(
              id: 1,
              name: 'My Best Movies',
              description: 'Favorites of all time',
              createdAt: DateTime.now(),
              isPublic: true,
            ),
          );
      await db.into(db.customListMovies).insert(
            CustomListMovie(
              listId: 1,
              movieId: 101,
              isTv: false,
              rankingOrder: 1,
              addedAt: DateTime.now(),
            ),
          );
    }

    Future<void> seedCloudHistory() async {
      await firestore.collection('logs').add({
        'userId': _uid,
        'movieId': 101,
        'isTv': false,
        'movieTitle': 'Inception',
        'watchDate': Timestamp.fromDate(DateTime(2024, 5, 1, 21, 30)),
        'createdAt': Timestamp.fromDate(DateTime(2024, 5, 1, 21, 30)),
        'rating': 9.0,
        'mood': '🍿',
        'watchNumber': 1,
        'episodeCount': 1,
        'starredBy': <String>['someone-else'],
        'commentCount': 3,
        'isPublic': true,
      });
      await firestore
          .collection('users')
          .doc(_uid)
          .collection('movie_settings')
          .doc('101_false')
          .set({
        'movieId': 101,
        'isTv': false,
        'isFavorite': true,
        'updatedAt': Timestamp.fromDate(DateTime(2024, 5, 2)),
      });
    }

    test('Native: export and import custom lists correctly', () async {
      await seedLocalCollection();

      final exportedJson = await BackupService.exportData(container);

      expect(exportedJson.containsKey('custom_lists'), isTrue);
      expect(exportedJson.containsKey('custom_list_movies'), isTrue);

      final exportedLists = exportedJson['custom_lists'] as List<dynamic>;
      final exportedMovies = exportedJson['custom_list_movies'] as List<dynamic>;

      expect(exportedLists.length, 1);
      expect(exportedLists.first['name'], 'My Best Movies');
      expect(exportedMovies.length, 1);
      expect(exportedMovies.first['movieId'], 101);

      // Import after clear/change
      await db.delete(db.customListMovies).go();
      await db.delete(db.customLists).go();

      await BackupService.importData(container, exportedJson);

      final restoredLists = await db.select(db.customLists).get();
      final restoredMovies = await db.select(db.customListMovies).get();

      expect(restoredLists.length, 1);
      expect(restoredLists.first.name, 'My Best Movies');
      expect(restoredLists.first.isPublic, isTrue);

      expect(restoredMovies.length, 1);
      expect(restoredMovies.first.movieId, 101);
    });

    // The regression this whole file's cloud half exists for: watch history is
    // written to Firestore, never to the local `watch_records` table, so an
    // export that only read drift produced a file with no history in it at all
    // while the UI promised "tüm izleme geçmişiniz".
    test('exports the signed-in user\'s Firestore watch history and settings', () async {
      await seedCloudHistory();

      final json = await BackupService.exportData(container);

      final logs = json['logs'] as List<dynamic>;
      expect(logs, hasLength(1));
      expect(logs.first['movieTitle'], 'Inception');
      expect(logs.first['rating'], 9.0);
      // Timestamps are normalised to ISO-8601 so the map is JSON-encodable.
      expect(logs.first['watchDate'], isA<String>());
      expect(DateTime.parse(logs.first['watchDate'] as String).year, 2024);

      final settings = json['movie_settings'] as List<dynamic>;
      expect(settings, hasLength(1));
      expect(settings.first['isFavorite'], isTrue);
      expect(settings.first['updatedAt'], isA<String>());
    });

    test('restores watch history into Firestore, replacing what was there', () async {
      await seedCloudHistory();
      final json = await BackupService.exportData(container);

      // Simulate a different device: one unrelated log that the restore must
      // clear, and none of the original ones.
      await firestore.collection('logs').get().then((s) async {
        for (final d in s.docs) {
          await d.reference.delete();
        }
      });
      await firestore.collection('logs').add({
        'userId': _uid,
        'movieId': 999,
        'isTv': false,
        'movieTitle': 'Stale entry',
        'watchDate': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'rating': 1.0,
        'watchNumber': 1,
        'episodeCount': 1,
      });

      await BackupService.importData(container, json);

      final logs = await firestore.collection('logs').get();
      expect(logs.docs, hasLength(1));
      final restored = logs.docs.first.data();
      expect(restored['movieTitle'], 'Inception');
      expect(restored['userId'], _uid);
      // Timestamps come back as real Timestamps, not strings.
      expect(restored['watchDate'], isA<Timestamp>());
      // Social state belongs to the original posting, not a restored copy.
      expect(restored['starredBy'], isEmpty);
      expect(restored['commentCount'], 0);

      final settings =
          await firestore.collection('users').doc(_uid).collection('movie_settings').get();
      expect(settings.docs, hasLength(1));
      expect(settings.docs.first.id, '101_false');
      expect(settings.docs.first.data()['isFavorite'], isTrue);
      expect(settings.docs.first.data()['updatedAt'], isA<Timestamp>());
    });

    test('a signed-out export contains only local data and does not touch Firestore', () async {
      await seedLocalCollection();
      await seedCloudHistory();

      final signedOut = buildContainer(signedIn: false);
      addTearDown(signedOut.dispose);

      final json = await BackupService.exportData(signedOut);
      expect(json.containsKey('logs'), isFalse);
      expect(json['custom_lists'], hasLength(1));

      await BackupService.importData(signedOut, json);
      // The other user's cloud data is untouched.
      expect((await firestore.collection('logs').get()).docs, hasLength(1));
    });

    test('Native: backward compatibility with legacy backups missing custom_lists keys', () async {
      await seedCloudHistory();

      // Legacy (version 1) JSON backup: local sections only, no cloud data.
      final legacyJson = {
        'version': 1,
        'movies': [
          {
            'tmdbId': 102,
            'title': 'Interstellar',
            'isTv': false,
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
        'watch_records': [],
        'user_movie_settings': []
      };

      // Import shouldn't fail
      await BackupService.importData(container, legacyJson);

      final restoredMovies = await db.select(db.movies).get();
      expect(restoredMovies.length, 1);
      expect(restoredMovies.first.title, 'Interstellar');

      final restoredLists = await db.select(db.customLists).get();
      expect(restoredLists, isEmpty);

      // A file with no cloud sections means "this backup predates them", not
      // "the user had no history" — deleting their cloud data here would be
      // the worst possible reading of "restore".
      expect((await firestore.collection('logs').get()).docs, hasLength(1));
    });
  });
}
