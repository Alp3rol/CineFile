// Verifies the two-step share flow: ShareMoviePickerSheet only picks WHAT
// to share (a movie, or several diary entries) and never writes anything
// itself; selecting routes to ShareComposeSheet, which requires a caption
// and performs the single `posts` write. Neither step touches a record's
// isPublic flag anymore — that flag is now fully decoupled from the
// Community feed (see add_watch_record_sheet.dart's "Profilimde Göster").
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/community/presentation/widgets/share_movie_picker_sheet.dart';

Future<void> _seedLogs(FakeFirebaseFirestore firestore) async {
  await firestore.collection('logs').doc('log1').set({
    'userId': 'me',
    'username': 'me',
    'userAvatarUrl': '',
    'movieId': 1,
    'movieTitle': 'First Movie',
    'isTv': false,
    'watchDate': Timestamp.fromDate(DateTime(2026, 1, 6)),
    'rating': 8.0,
    'mood': '🍿',
    'watchNumber': 1,
    'episodeCount': 1,
    'createdAt': Timestamp.fromDate(DateTime(2026, 1, 6)),
    'starredBy': <String>[],
    'commentCount': 0,
    'isPublic': false,
  });
  await firestore.collection('logs').doc('log2').set({
    'userId': 'me',
    'username': 'me',
    'userAvatarUrl': '',
    'movieId': 2,
    'movieTitle': 'Second Movie',
    'isTv': false,
    'watchDate': Timestamp.fromDate(DateTime(2026, 1, 5)),
    'rating': 7.0,
    'mood': '🍿',
    'watchNumber': 1,
    'episodeCount': 1,
    'createdAt': Timestamp.fromDate(DateTime(2026, 1, 5)),
    'starredBy': <String>[],
    'commentCount': 0,
    'isPublic': false,
  });
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com'));
    await _seedLogs(firestore);
  });

  Widget app(Widget sheet) {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firestoreProvider.overrideWithValue(firestore),
      ],
      child: MaterialApp(home: Scaffold(body: sheet)),
    );
  }

  testWidgets('single-select: picking a movie opens the compose sheet; submitting creates a movie post', (tester) async {
    await tester.pumpWidget(app(const ShareMoviePickerSheet()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('First Movie'));
    await tester.pumpAndSettle();

    // The picker closed and the compose sheet opened in its place.
    expect(find.text('Film Paylaş'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    final shareButtonFinder = find.widgetWithText(ElevatedButton, 'Paylaş');
    expect(tester.widget<ElevatedButton>(shareButtonFinder).onPressed, isNull); // disabled, no caption yet

    await tester.enterText(find.byType(TextField), 'çok güzel filmdi bitirdim');
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(shareButtonFinder).onPressed, isNotNull);

    await tester.tap(shareButtonFinder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3)); // flush the success toast's auto-dismiss timer

    final posts = await firestore.collection('posts').get();
    expect(posts.docs.length, 1);
    final post = posts.docs.first.data();
    expect(post['type'], 'movie');
    expect(post['movieTitle'], 'First Movie');
    expect(post['caption'], 'çok güzel filmdi bitirdim');

    // isPublic on the source log is untouched — sharing no longer flips it.
    final log = await firestore.collection('logs').doc('log1').get();
    expect(log.data()!['isPublic'], isFalse);
  });

  testWidgets('multi-select: "Devam Et" is disabled until something is checked, then opens compose with a snapshot', (tester) async {
    await tester.pumpWidget(app(const ShareMoviePickerSheet(multiSelect: true)));
    await tester.pumpAndSettle();

    final continueButtonFinder = find.widgetWithText(ElevatedButton, 'Devam Et');
    expect(tester.widget<ElevatedButton>(continueButtonFinder).onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.tap(find.byType(CheckboxListTile).last);
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(continueButtonFinder).onPressed, isNotNull);

    await tester.tap(continueButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Günlüğünü Paylaş'), findsOneWidget);
    expect(find.text('2 kayıt paylaşılacak'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'bugüne kadar izlediğim filmler');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Paylaş'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    final posts = await firestore.collection('posts').get();
    expect(posts.docs.length, 1);
    final post = posts.docs.first.data();
    expect(post['type'], 'diary_snapshot');
    expect(post['caption'], 'bugüne kadar izlediğim filmler');
    expect((post['entries'] as List).length, 2);

    // Neither source log's isPublic was touched.
    final log1 = await firestore.collection('logs').doc('log1').get();
    final log2 = await firestore.collection('logs').doc('log2').get();
    expect(log1.data()!['isPublic'], isFalse);
    expect(log2.data()!['isPublic'], isFalse);
  });
}
