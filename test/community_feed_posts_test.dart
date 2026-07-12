// Verifies CommunityFeedScreen renders each post type correctly and that
// posts are always independent (no more grouping by user — the bug this
// replaced: a fresh "Film Paylaş" post used to get silently folded into an
// older "Günlüğünü Paylaş" aggregate). A 'diary_snapshot' post's entries are
// the frozen list embedded in the post itself; tapping it opens
// UserPublicDiaryScreen fed directly from that list, not a live query — see
// user_public_diary_screen_frozen_test.dart for the actual "doesn't change
// later" regression coverage.
import 'dart:io';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmdizi/features/auth/controllers/auth_controller.dart';
import 'package:filmdizi/features/community/models/community_post_model.dart';
import 'package:filmdizi/features/community/presentation/community_feed_provider.dart';
import 'package:filmdizi/features/community/presentation/community_feed_screen.dart';
import 'package:filmdizi/features/community/presentation/user_public_diary_screen.dart';
import 'package:filmdizi/core/database/database_provider.dart';
import 'support/network_image_mock.dart';

CommunityPost _moviePost(String id, String userId, String caption, DateTime createdAt) {
  return CommunityPost(
    id: id,
    userId: userId,
    username: 'shared_user',
    userAvatarUrl: '',
    type: 'movie',
    caption: caption,
    createdAt: createdAt,
    starredBy: const [],
    commentCount: 0,
    movieId: 1,
    isTv: false,
    movieTitle: 'A Great Movie',
    moviePosterPath: null,
    releaseYear: 2020,
    rating: 9.0,
    mood: '🔥',
    watchDate: createdAt,
  );
}

CommunityPost _diarySnapshotPost(String id, String userId, String caption, DateTime createdAt, int entryCount) {
  return CommunityPost(
    id: id,
    userId: userId,
    username: 'shared_user',
    userAvatarUrl: '',
    type: 'diary_snapshot',
    caption: caption,
    createdAt: createdAt,
    starredBy: const [],
    commentCount: 0,
    entries: List.generate(
      entryCount,
      (i) => {
        'movieId': i,
        'isTv': false,
        'movieTitle': 'Snapshot Movie $i',
        'moviePosterPath': null,
        'rating': 7.0,
        'watchDate': createdAt,
      },
    ),
  );
}

void main() {
  final originalHttpOverrides = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  tearDownAll(() => HttpOverrides.global = originalHttpOverrides);

  Widget app(List<Override> overrides) {
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

  testWidgets('a movie post renders the rich card with its caption', (tester) async {
    await tester.pumpWidget(app([
      communityFeedProvider.overrideWith(
        (ref) => Stream.value([_moviePost('post1', 'shared_user', 'çok güzel filmdi bitirdim', DateTime(2026, 1, 1))]),
      ),
      followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('A Great Movie'), findsOneWidget);
    expect(find.text('"çok güzel filmdi bitirdim"'), findsOneWidget);
    expect(find.text('9.0'), findsOneWidget);
  });

  testWidgets('a diary_snapshot post renders its own compact card and opens the frozen diary on tap', (tester) async {
    await tester.pumpWidget(app([
      communityFeedProvider.overrideWith(
        (ref) => Stream.value([_diarySnapshotPost('post2', 'shared_user', 'bugüne kadar izlediğim filmler', DateTime(2026, 1, 2), 3)]),
      ),
      followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('bugüne kadar izlediğim filmler'), findsOneWidget);
    expect(find.text('3 film/dizi · Günlüğü gör'), findsOneWidget);

    await tester.tap(find.text('bugüne kadar izlediğim filmler'));
    await tester.pumpAndSettle();

    expect(find.byType(UserPublicDiaryScreen), findsOneWidget);
  });

  testWidgets('a movie post and a diary_snapshot post from the same user both appear as separate posts', (tester) async {
    await tester.pumpWidget(app([
      communityFeedProvider.overrideWith(
        (ref) => Stream.value([
          _moviePost('post1', 'shared_user', 'ilk post', DateTime(2026, 1, 2)),
          _diarySnapshotPost('post2', 'shared_user', 'ikinci post', DateTime(2026, 1, 1), 2),
        ]),
      ),
      followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
    ]));
    await tester.pumpAndSettle();

    // Both posts show up independently — no more collapsing into one card
    // per user (the bug the user reported: a fresh movie share used to be
    // swallowed into an earlier diary aggregate).
    expect(find.text('"ilk post"'), findsOneWidget);
    expect(find.text('ikinci post'), findsOneWidget);
  });
}
