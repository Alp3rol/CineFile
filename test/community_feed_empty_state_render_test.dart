// Verifies the three empty-state variants in CommunityFeedScreen: no posts
// anywhere ("Tümü"), following nobody ("Takip Ettiklerim", with a CTA into
// UserSearchScreen), and following people who haven't posted yet (no CTA).
import 'dart:io';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/community/models/community_post_model.dart';
import 'package:filmdizi/features/community/presentation/community_feed_provider.dart';
import 'package:filmdizi/features/community/presentation/community_feed_screen.dart';
import 'package:filmdizi/features/community/presentation/user_search_screen.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'support/network_image_mock.dart';

CommunityPost _moviePost(String id, String userId) {
  return CommunityPost(
    id: id,
    userId: userId,
    username: 'other_user',
    userAvatarUrl: '',
    type: 'movie',
    caption: 'harika bir filmdi',
    createdAt: DateTime(2026, 1, 1),
    starredBy: const [],
    commentCount: 0,
    movieId: 1,
    isTv: false,
    movieTitle: 'Some Movie',
    releaseYear: 2020,
    rating: 8,
    mood: '🍿',
    watchDate: DateTime(2026, 1, 1),
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

  testWidgets('shows a content-gap empty state on "Tümü" when nobody has posted', (tester) async {
    await tester.pumpWidget(_app([
      communityFeedProvider.overrideWith((ref) => Stream.value(const [])),
      followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
    ]));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Henüz bir gönderi yok'), findsOneWidget);
    expect(find.text('Paylaşım kutusunu kullanarak ilk gönderini oluştur!'), findsOneWidget);
    // Content gap, not a discovery gap — no CTA button here.
    expect(find.text('Kullanıcı Ara'), findsNothing);
  });

  testWidgets('following nobody shows a CTA into UserSearchScreen, and tapping it navigates there', (tester) async {
    await tester.pumpWidget(_app([
      communityFeedProvider.overrideWith((ref) => Stream.value([_moviePost('post1', 'someoneElse')])),
      followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
    ]));
    await tester.pumpAndSettle();

    // Switch to "Takip Ettiklerim". (Not asserting takeException() here: the
    // "Tümü" tab's post renders a NetworkImage avatar, which — like the
    // avatarUrl case in widget_test.dart — has no real network in tests and
    // logs an unrelated, expected NetworkImageLoadException.)
    await tester.tap(find.text('Takip Ettiklerim'));
    await tester.pumpAndSettle();

    expect(find.text('Henüz kimseyi takip etmiyorsunuz'), findsOneWidget);
    expect(find.text('Kullanıcı Ara'), findsOneWidget);

    await tester.tap(find.text('Kullanıcı Ara'));
    await tester.pumpAndSettle();

    expect(find.byType(UserSearchScreen), findsOneWidget);
  });

  testWidgets('following people with no posts yet shows a waiting message, no CTA', (tester) async {
    await tester.pumpWidget(_app([
      communityFeedProvider.overrideWith((ref) => Stream.value([_moviePost('post1', 'someoneElse')])),
      followedUserIdsProvider.overrideWith((ref) => Stream.value({'aFollowedUserWhoHasNotPosted'})),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Takip Ettiklerim'));
    await tester.pumpAndSettle();

    expect(find.text('Takip ettikleriniz henüz paylaşım yapmadı'), findsOneWidget);
    expect(find.text('Kullanıcı Ara'), findsNothing);
  });
}
