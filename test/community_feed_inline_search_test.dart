// Verifies the Community feed's inline user search: the search icon opens
// a search field IN PLACE (no route push, mirrors journal_screen.dart's
// _showSearch toggle), results render inline over the feed area, and
// tapping a result still navigates to that user's profile (only the SEARCH
// itself must stay on-screen, not the eventual "view a profile" action).
//
// Note: like journal_screen.dart's own search field, the TextField is kept
// in the widget tree at all times (AnimatedCrossFade builds both children,
// just crossfades between them) — so "is search open" is asserted via the
// content area (compose bar vs. search results), not TextField presence.
import 'dart:io';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/auth/presentation/user_profile_screen.dart';
import 'package:filmdizi/features/community/presentation/community_feed_provider.dart';
import 'package:filmdizi/features/community/presentation/community_feed_screen.dart';
import 'package:filmdizi/features/community/presentation/user_search_screen.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'support/network_image_mock.dart';

Future<void> _seedUsers(FakeFirebaseFirestore firestore) async {
  await firestore.collection('users').doc('me').set({
    'email': 'me@test.com',
    'username': 'me',
    'usernameLower': 'me',
    'followerCount': 0,
    'followingCount': 0,
  });
  await firestore.collection('users').doc('alice').set({
    'email': 'alice@test.com',
    'username': 'Alice',
    'usernameLower': 'alice',
    'followerCount': 3,
    'followingCount': 1,
  });
}

void main() {
  late FakeFirebaseFirestore firestore;

  final originalHttpOverrides = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  tearDownAll(() => HttpOverrides.global = originalHttpOverrides);

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await _seedUsers(firestore);
  });

  Widget app() {
    return ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com')),
        ),
        firestoreProvider.overrideWithValue(firestore),
        communityFeedProvider.overrideWith((ref) => Stream.value(const [])),
        followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
      ],
      child: const MaterialApp(home: CommunityFeedScreen()),
    );
  }

  testWidgets('tapping the search icon swaps the compose bar for the inline search results, without pushing UserSearchScreen', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Closed: normal feed content (compose bar), no search empty-state text.
    expect(find.text('Bir şeyler paylaş...'), findsOneWidget);
    expect(find.text('Kullanıcı adına göre arama yapın.'), findsNothing);

    await tester.tap(find.byKey(const Key('communitySearchToggle')));
    await tester.pumpAndSettle();

    // Open: search's own empty-state text appears, compose bar is gone.
    expect(find.text('Kullanıcı adına göre arama yapın.'), findsOneWidget);
    expect(find.text('Bir şeyler paylaş...'), findsNothing);
    expect(find.byType(UserSearchScreen), findsNothing);
    // Still on CommunityFeedScreen — no navigation happened.
    expect(find.byType(CommunityFeedScreen), findsOneWidget);
  });

  testWidgets('typing shows matching users inline, and tapping a result navigates to their profile', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('communitySearchToggle')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'ali');
    await tester.pump(const Duration(milliseconds: 400)); // past the debounce
    await tester.pumpAndSettle();

    expect(find.textContaining('@Alice'), findsOneWidget);

    await tester.tap(find.textContaining('@Alice'));
    await tester.pumpAndSettle();

    expect(find.byType(UserProfileScreen), findsOneWidget);
  });

  testWidgets('tapping the search icon again closes the field and clears the query', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('communitySearchToggle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'ali');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.textContaining('@Alice'), findsOneWidget);

    await tester.tap(find.byKey(const Key('communitySearchToggle')));
    await tester.pumpAndSettle();

    // Back to normal feed content; the query was cleared, not just hidden.
    expect(find.text('Bir şeyler paylaş...'), findsOneWidget);
    expect(find.textContaining('@Alice'), findsNothing);
  });
}
