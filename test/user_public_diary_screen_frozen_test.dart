// Root-cause regression test for the bug report that drove this rework:
// a "Günlüğünü Paylaş" post must be a FROZEN snapshot — adding new movies
// to the diary after the post was published must never retroactively
// change what that post shows. Exercises the real path: pick two records
// via ShareMoviePickerSheet -> ShareComposeSheet writes the `posts` doc ->
// re-fetch that doc from Firestore -> confirm a movie added to the diary
// AFTER the post was created does not appear when rendering
// UserPublicDiaryScreen from the post's own (re-fetched) entries.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/community/models/community_post_model.dart';
import 'package:filmdizi/features/community/presentation/user_public_diary_screen.dart';
import 'package:filmdizi/features/community/presentation/widgets/share_movie_picker_sheet.dart';

void main() {
  testWidgets('a diary_snapshot post does not show a movie added to the diary after it was published', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com'));

    await firestore.collection('logs').doc('log1').set({
      'userId': 'me',
      'username': 'me',
      'userAvatarUrl': '',
      'movieId': 1,
      'movieTitle': 'Before Movie',
      'isTv': false,
      'watchDate': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'rating': 8.0,
      'mood': '🍿',
      'watchNumber': 1,
      'episodeCount': 1,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'starredBy': <String>[],
      'commentCount': 0,
      'isPublic': false,
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firestoreProvider.overrideWithValue(firestore),
      ],
      child: const MaterialApp(home: Scaffold(body: ShareMoviePickerSheet(multiSelect: true))),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Devam Et'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'bugüne kadar izlediğim filmler');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Paylaş'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    final postSnapshot = await firestore.collection('posts').get();
    expect(postSnapshot.docs.length, 1);

    // Simulate the user adding a brand-new movie to their diary AFTER the
    // post above was already published.
    await firestore.collection('logs').doc('log2').set({
      'userId': 'me',
      'username': 'me',
      'userAvatarUrl': '',
      'movieId': 2,
      'movieTitle': 'After Movie',
      'isTv': false,
      'watchDate': Timestamp.fromDate(DateTime(2026, 2, 1)),
      'rating': 7.0,
      'mood': '🍿',
      'watchNumber': 1,
      'episodeCount': 1,
      'createdAt': Timestamp.fromDate(DateTime(2026, 2, 1)),
      'starredBy': <String>[],
      'commentCount': 0,
      'isPublic': false,
    });

    // Re-fetch the post exactly as the feed would, and render its frozen
    // entries — this is the actual regression check.
    final refetched = await firestore.collection('posts').doc(postSnapshot.docs.first.id).get();
    final post = CommunityPost.fromMap(refetched.data()!, refetched.id);

    expect(post.entries.length, 1);
    expect(post.entries.first['movieTitle'], 'Before Movie');

    await tester.pumpWidget(MaterialApp(
      home: UserPublicDiaryScreen(username: post.username, entries: post.entries),
    ));
    await tester.pumpAndSettle();

    // The grid renders one poster tile per frozen entry — exactly 1, not 2
    // (it would be 2 if this screen queried the live diary instead).
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(ClipRRect), findsOneWidget);
  });
}
