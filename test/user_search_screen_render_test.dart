// Verifies UserSearchScreen's three states (empty query, no results, results)
// and that a search result's FollowButton reflects isFollowingProvider and
// calls toggleFollow on tap. New screen added so users can discover other
// people by username instead of only finding them via the feed/comments.
import 'dart:io';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/community/presentation/user_search_screen.dart';
import 'support/network_image_mock.dart';

Future<void> _seedUsers(FakeFirebaseFirestore firestore) async {
  await firestore.collection('users').doc('me').set({
    'email': 'me@test.com',
    'username': 'me',
    'usernameLower': 'me',
    'followerCount': 0,
    'followingCount': 0,
  });
  // Mixed/capitalized casing on purpose — the search query below is typed
  // fully lowercase, so this exercises the exact bug report: a
  // capital-first-letter username must still be findable via a lowercase
  // query, matched through usernameLower rather than username itself.
  await firestore.collection('users').doc('alice').set({
    'email': 'alice@test.com',
    'username': 'Alice',
    'usernameLower': 'alice',
    'followerCount': 3,
    'followingCount': 1,
  });
  await firestore.collection('users').doc('alicia').set({
    'email': 'alicia@test.com',
    'username': 'Alicia',
    'usernameLower': 'alicia',
    'followerCount': 0,
    'followingCount': 0,
  });
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;

  final originalHttpOverrides = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  tearDownAll(() => HttpOverrides.global = originalHttpOverrides);

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com'));
    await _seedUsers(firestore);
  });

  Widget app() {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockAuth),
        firestoreProvider.overrideWithValue(firestore),
      ],
      child: const MaterialApp(home: UserSearchScreen()),
    );
  }

  testWidgets('shows the "start searching" state when the query is empty', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Kullanıcı Ara'), findsWidgets); // app bar title + empty-state heading
    expect(find.text('Kullanıcı adına göre arama yapın.'), findsOneWidget);
  });

  testWidgets('shows matching users by username prefix, excluding the current user', (tester) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump(const Duration(milliseconds: 400)); // past the debounce
    await tester.pumpAndSettle();

    // Not asserting takeException() here: each result row's dicebear-avatar
    // NetworkImage has no real network in tests and logs an unrelated,
    // expected NetworkImageLoadException (same as widget_test.dart's note).
    // Displayed usernames keep their original casing ("Alice"/"Alicia") even
    // though the query and the field matched on ("usernameLower") are both
    // lowercase — this is the case-insensitivity fix in action.
    expect(find.textContaining('@Alice'), findsOneWidget);
    expect(find.textContaining('@Alicia'), findsOneWidget);
    expect(find.textContaining('@me'), findsNothing);
  });

  testWidgets('shows a no-results state for a query that matches nobody', (tester) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Kullanıcı Bulunamadı'), findsOneWidget);
  });

  testWidgets('tapping Takip Et on a result creates a follow doc and flips the button label', (tester) async {
    await tester.pumpWidget(app());
    await tester.enterText(find.byType(TextField), 'alice');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Takip Et'), findsOneWidget);

    await tester.tap(find.text('Takip Et'));
    await tester.pumpAndSettle();

    expect(find.text('Takibi Bırak'), findsOneWidget);

    final followDoc = await firestore.collection('follows').doc('me_alice').get();
    expect(followDoc.exists, isTrue);
  });
}
