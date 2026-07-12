// Verifies the hover/press animation on the premium film-strip preview
// shared by the "diary_snapshot" and "collection" post cards: hovering (or
// pressing, on touch) a poster scales it up; moving away/releasing reverts
// it. Exercised through a real diary_snapshot post card
// (community_feed_screen.dart's private _PosterFilmstrip isn't exported,
// so this drives it via the public CommunityFeedScreen surface instead of
// importing the widget directly).
import 'dart:io';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/gestures.dart';
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

CommunityPost _diarySnapshotPost() {
  return CommunityPost(
    id: 'post1',
    userId: 'shared_user',
    username: 'shared_user',
    userAvatarUrl: '',
    type: 'diary_snapshot',
    caption: 'bugüne kadar izlediğim filmler',
    createdAt: DateTime(2026, 1, 1),
    starredBy: const [],
    commentCount: 0,
    entries: List.generate(
      3,
      (i) => {
        'movieId': i,
        'isTv': false,
        'movieTitle': 'Movie $i',
        'moviePosterPath': '/poster$i.jpg',
        'rating': 7.0,
        'watchDate': DateTime(2026, 1, 1),
      },
    ),
  );
}

void main() {
  final originalHttpOverrides = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  tearDownAll(() => HttpOverrides.global = originalHttpOverrides);

  testWidgets('hovering a poster in the filmstrip scales it up and un-scales on exit', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com')),
        ),
        communityFeedProvider.overrideWith((ref) => Stream.value([_diarySnapshotPost()])),
        followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
      ],
      child: const MaterialApp(home: CommunityFeedScreen()),
    ));
    await tester.pumpAndSettle();

    final scaleFinder = find.byType(AnimatedScale);
    expect(scaleFinder, findsNWidgets(3)); // one per poster in the strip

    // All start unscaled.
    for (final widget in tester.widgetList<AnimatedScale>(scaleFinder)) {
      expect(widget.scale, 1.0);
    }

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    // Hover over the first poster in the strip.
    final firstPosterCenter = tester.getCenter(find.byType(AnimatedScale).first);
    await gesture.moveTo(firstPosterCenter);
    await tester.pumpAndSettle();

    final scaledWidgets = tester.widgetList<AnimatedScale>(find.byType(AnimatedScale)).toList();
    expect(scaledWidgets.where((w) => w.scale > 1.0).length, 1);

    // Moving away reverts every poster back to unscaled.
    await gesture.moveTo(const Offset(-100, -100));
    await tester.pumpAndSettle();

    for (final widget in tester.widgetList<AnimatedScale>(find.byType(AnimatedScale))) {
      expect(widget.scale, 1.0);
    }
  });

  testWidgets('pressing a poster on touch grows it too, and lifting still navigates (tap not swallowed)', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com')),
        ),
        communityFeedProvider.overrideWith((ref) => Stream.value([_diarySnapshotPost()])),
        followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
      ],
      child: const MaterialApp(home: CommunityFeedScreen()),
    ));
    await tester.pumpAndSettle();

    final posterCenter = tester.getCenter(find.byType(AnimatedScale).first);

    // Default tester.startGesture uses a touch pointer, not mouse — this is
    // the Listener-based press path, not MouseRegion hover.
    final touch = await tester.startGesture(posterCenter);
    await tester.pumpAndSettle();

    final pressedScales = tester.widgetList<AnimatedScale>(find.byType(AnimatedScale)).toList();
    expect(pressedScales.where((w) => w.scale > 1.0).length, 1);

    // Releasing completes the tap — the outer GestureDetector (navigation)
    // must still receive it; Listener doesn't consume the gesture arena.
    await touch.up();
    await tester.pumpAndSettle();

    expect(find.byType(UserPublicDiaryScreen), findsOneWidget);
  });

  testWidgets('shows a "+N" tile for entries beyond the ones with posters shown', (tester) async {
    final post = CommunityPost(
      id: 'post1',
      userId: 'shared_user',
      username: 'shared_user',
      userAvatarUrl: '',
      type: 'diary_snapshot',
      caption: 'çok kayıt var',
      createdAt: DateTime(2026, 1, 1),
      starredBy: const [],
      commentCount: 0,
      entries: List.generate(
        6,
        (i) => {
          'movieId': i,
          'isTv': false,
          'movieTitle': 'Movie $i',
          'moviePosterPath': '/poster$i.jpg',
          'rating': 7.0,
          'watchDate': DateTime(2026, 1, 1),
        },
      ),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'me', email: 'me@test.com')),
        ),
        communityFeedProvider.overrideWith((ref) => Stream.value([post])),
        followedUserIdsProvider.overrideWith((ref) => Stream.value(<String>{})),
      ],
      child: const MaterialApp(home: CommunityFeedScreen()),
    ));
    await tester.pumpAndSettle();

    // Only 4 posters are shown (previewPosters is capped), plus a "+2" tile
    // for the remaining 2 of the 6 total entries.
    expect(find.byType(AnimatedScale), findsNWidgets(4));
    expect(find.text('+2'), findsOneWidget);
  });
}
