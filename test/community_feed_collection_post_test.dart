// Verifies the feed's 'collection' post card: it watches
// sharedCollectionProvider LIVE (unlike movie/diary_snapshot cards, which
// render frozen post data), and shows a graceful notice instead of
// crashing when the referenced shared_collections doc is gone (owner
// stopped sharing after this post was created).
import 'dart:io';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/community/models/community_post_model.dart';
import 'package:filmdizi/features/community/presentation/community_feed_provider.dart';
import 'package:filmdizi/features/community/presentation/community_feed_screen.dart';
import 'package:filmdizi/features/community/presentation/shared_collection_detail_screen.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'support/network_image_mock.dart';

CommunityPost _collectionPost(String id, String collectionRefId) {
  return CommunityPost(
    id: id,
    userId: 'owner',
    username: 'owner_user',
    userAvatarUrl: '',
    type: 'collection',
    caption: 'işte cadılar bayramı listem',
    createdAt: DateTime(2026, 1, 1),
    starredBy: const [],
    commentCount: 0,
    collectionRefId: collectionRefId,
  );
}

Widget _app(List<Override> overrides) {
  return ProviderScope(
    overrides: [
      firebaseAuthProvider.overrideWithValue(
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com')),
      ),
      ...overrides,
    ],
    child: const MaterialApp(home: CommunityFeedScreen()),
  );
}

void main() {
  final originalHttpOverrides = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  tearDownAll(() => HttpOverrides.global = originalHttpOverrides);

  testWidgets('renders live collection data and opens the live detail screen on tap', (tester) async {
    await tester.pumpWidget(_app([
      communityFeedProvider.overrideWith((ref) => Stream.value([_collectionPost('post1', 'owner_1')])),
      followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
      sharedCollectionProvider('owner_1').overrideWith((ref) => Stream.value({
            'name': 'Halloween Marathon',
            'description': 'spooky picks',
            'movies': [
              {'tmdbId': 1, 'isTv': false, 'title': 'Scream', 'posterPath': null, 'rankingOrder': 1},
            ],
          })),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('işte cadılar bayramı listem'), findsOneWidget);
    expect(find.text('Halloween Marathon · 1 film/dizi'), findsOneWidget);

    await tester.tap(find.text('işte cadılar bayramı listem'));
    await tester.pumpAndSettle();

    expect(find.byType(SharedCollectionDetailScreen), findsOneWidget);
  });

  testWidgets('shows a graceful notice when the collection is no longer shared', (tester) async {
    await tester.pumpWidget(_app([
      communityFeedProvider.overrideWith((ref) => Stream.value([_collectionPost('post1', 'owner_1')])),
      followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
      sharedCollectionProvider('owner_1').overrideWith((ref) => Stream.value(null)),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Bu koleksiyon artık paylaşılmıyor'), findsOneWidget);
  });
}
