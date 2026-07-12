// End-to-end coverage of the "Koleksiyon Paylaş" compose flow:
// ShareCollectionPickerSheet (pick which collection) -> ShareComposeSheet
// (mandatory caption) -> submit turns the collection's live sync on AND
// creates the referencing `posts` doc, in that order.
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/core/database/app_database.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'package:filmdizi/core/database/movie_repository.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/community/presentation/widgets/share_collection_picker_sheet.dart';

void main() {
  testWidgets('picking a collection and submitting a caption shares it live and creates a post', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final firestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com'));

    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      firebaseAuthProvider.overrideWithValue(mockAuth),
      firestoreProvider.overrideWithValue(firestore),
    ]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    await container.read(authStateProvider.future);

    // Seed a collection via the repository, exactly as the app's own
    // "Yeni Liste" flow would.
    final repo = container.read(movieRepositoryProvider);
    await repo.createCustomList('Halloween Marathon', 'spooky picks');
    final listId = (await db.select(db.customLists).get()).first.id;

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: ShareCollectionPickerSheet())),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Halloween Marathon'));
    await tester.pumpAndSettle();

    // The picker closed and the compose sheet opened in its place.
    expect(find.text('Koleksiyon Paylaş'), findsOneWidget);

    final shareButtonFinder = find.widgetWithText(ElevatedButton, 'Paylaş');
    expect(tester.widget<ElevatedButton>(shareButtonFinder).onPressed, isNull); // disabled, no caption yet

    await tester.enterText(find.byType(TextField), 'işte cadılar bayramı listem');
    await tester.pumpAndSettle();
    await tester.tap(shareButtonFinder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3)); // flush the success toast's auto-dismiss timer

    // Sharing turned on: the mirror doc exists...
    final mirrorDoc = await firestore.collection('shared_collections').doc('me_$listId').get();
    expect(mirrorDoc.exists, isTrue);
    expect(mirrorDoc.data()!['name'], 'Halloween Marathon');

    // ...and a post referencing it was created.
    final posts = await firestore.collection('posts').get();
    expect(posts.docs.length, 1);
    final post = posts.docs.first.data();
    expect(post['type'], 'collection');
    expect(post['caption'], 'işte cadılar bayramı listem');
    expect(post['collectionRefId'], 'me_$listId');
  });
}
