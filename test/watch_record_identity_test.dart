// A WatchRecord materialised from Firestore carries the id of the document it
// came from (WatchRecords.remoteId). Before that field existed, the local int
// `id` was `docId.hashCode` and deletes/edits had to search for a document
// that hashed back to it — falling back to matching on
// (watchDate, watchNumber, episodeCount) when the hash didn't line up.
//
// That tuple is not unique. Two episodes of the same show logged in the same
// minute with the same episodeCount are indistinguishable by it, so the
// fallback could resolve to a different record than the one the user tapped
// and delete the wrong entry. These tests pin the exact-document behaviour.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/core/database/app_database.dart';
import 'package:cinefile/core/database/database_provider.dart';
import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:cinefile/features/journal/models/diary_log_model.dart';

const _uid = 'user-1';

/// `deleteWatchRecord`/`updateWatchRecord` take a WidgetRef, so the calls run
/// inside a real (if trivial) widget tree rather than a bare container.
///
/// Everything that touches Firestore afterwards has to go through
/// `tester.runAsync`: widget tests run in a fake-async zone where timer-backed
/// futures never complete, and fake_cloud_firestore's writes are timer-backed.
Future<WidgetRef> _refIn(WidgetTester tester, ProviderContainer container) async {
  late WidgetRef captured;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          captured = ref;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

Map<String, dynamic> _logData({required int episodeCount, required DateTime watchDate}) => {
      'userId': _uid,
      'movieId': 7,
      'isTv': true,
      'movieTitle': 'Same Show',
      'watchDate': Timestamp.fromDate(watchDate),
      'createdAt': Timestamp.fromDate(watchDate),
      'rating': 8.0,
      'mood': '🍿',
      'watchNumber': 1,
      'episodeCount': episodeCount,
      'isPublic': false,
    };

void main() {
  late FakeFirebaseFirestore firestore;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      // The signed-in paths under test never touch drift, but the repository
      // provider is constructed eagerly enough that the real (path_provider
      // backed) connection would be opened in a test with no plugins.
      databaseProvider.overrideWithValue(db),
      firestoreProvider.overrideWithValue(firestore),
      firebaseAuthProvider.overrideWithValue(
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: _uid, email: 'a@b.com')),
      ),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<List<WatchRecord>> loadRecords() async {
    final snapshot =
        await firestore.collection('logs').where('userId', isEqualTo: _uid).get();
    return snapshot.docs
        .map((d) => DiaryLogModel.fromMap(d.data(), d.id).toWatchRecordWithMovie().record)
        .toList();
  }

  testWidgets('deletes exactly the record it was given, not a look-alike', (tester) async {
    final ref = await _refIn(tester, container);

    await tester.runAsync(() async {
      // Two logs identical in every field the old fallback compared.
      final sameMoment = DateTime(2026, 3, 1, 22, 15);
      await firestore.collection('logs').add(_logData(episodeCount: 1, watchDate: sameMoment));
      await firestore.collection('logs').add(_logData(episodeCount: 1, watchDate: sameMoment));

      final records = await loadRecords();
      expect(records, hasLength(2));
      final target = records.first;
      final survivor = records.last;
      expect(target.remoteId, isNotNull);

      await deleteWatchRecord(ref, target);

      final remaining = await loadRecords();
      expect(remaining, hasLength(1));
      expect(remaining.single.remoteId, survivor.remoteId);
    });
  });

  testWidgets('updates exactly the record it was given', (tester) async {
    final ref = await _refIn(tester, container);

    await tester.runAsync(() async {
      final sameMoment = DateTime(2026, 3, 1, 22, 15);
      await firestore.collection('logs').add(_logData(episodeCount: 2, watchDate: sameMoment));
      await firestore.collection('logs').add(_logData(episodeCount: 2, watchDate: sameMoment));

      final records = await loadRecords();
      final target = records.first;

      await updateWatchRecord(ref, target, episodeCount: 9, isPublic: true);

      final byId = {for (final r in await loadRecords()) r.remoteId: r};
      expect(byId[target.remoteId]!.episodeCount, 9);
      expect(byId[target.remoteId]!.isPublic, isTrue);
      // The look-alike is untouched.
      final other = byId.keys.firstWhere((k) => k != target.remoteId);
      expect(byId[other]!.episodeCount, 2);
      expect(byId[other]!.isPublic, isFalse);
    });
  });

  testWidgets('a stale remoteId removes nothing rather than a "close enough" record',
      (tester) async {
    final ref = await _refIn(tester, container);

    await tester.runAsync(() async {
      final sameMoment = DateTime(2026, 3, 1, 22, 15);
      await firestore.collection('logs').add(_logData(episodeCount: 1, watchDate: sameMoment));

      final ghost = WatchRecord(
        id: 12345,
        remoteId: 'does-not-exist',
        movieId: 7,
        isTv: true,
        watchDate: sameMoment,
        rating: 8,
        watchNumber: 1,
        createdAt: sameMoment,
        episodeCount: 1,
        isPublic: false,
      );

      // Deleting a document that isn't there is a no-op in Firestore. What
      // must NOT happen is the old behaviour: scanning the movie's logs for a
      // record with a matching (watchDate, watchNumber, episodeCount) — which
      // the surviving entry above would have satisfied exactly.
      await deleteWatchRecord(ref, ghost);
      expect(await loadRecords(), hasLength(1));
    });
  });
}
