import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cinefile/features/community/models/community_post_model.dart';
import 'package:cinefile/features/community/presentation/widgets/community_post_card.dart';
import 'support/localized_app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('CommunityPost spoiler model tests', () {
    test('serializes and deserializes isSpoiler correctly', () {
      final post = CommunityPost(
        id: 'post-123',
        userId: 'user-1',
        username: 'cinephile',
        userAvatarUrl: '',
        type: 'movie',
        caption: 'Huge twist at the end!',
        createdAt: DateTime(2026, 8, 18),
        starredBy: const [],
        commentCount: 0,
        movieId: 550,
        isTv: false,
        movieTitle: 'Fight Club',
        isSpoiler: true,
      );

      final map = post.toMap();
      expect(map['isSpoiler'], isTrue);

      final fromMap = CommunityPost.fromMap(map, 'post-123');
      expect(fromMap.isSpoiler, isTrue);
      expect(fromMap.caption, 'Huge twist at the end!');
    });

    test('defaults isSpoiler to false when missing from map', () {
      final map = {
        'userId': 'user-2',
        'username': 'bob',
        'type': 'movie',
        'caption': 'Great movie',
        'createdAt': Timestamp.now(),
        'starredBy': <String>[],
        'commentCount': 0,
      };

      final fromMap = CommunityPost.fromMap(map, 'post-456');
      expect(fromMap.isSpoiler, isFalse);
    });
  });

  group('CommunityPostCard spoiler widget tests', () {
    testWidgets('hides spoiler caption until revealed on tap', (tester) async {
      final spoilerPost = CommunityPost(
        id: 'post-spoiler',
        userId: 'user-1',
        username: 'alice',
        userAvatarUrl: '',
        type: 'movie',
        caption: 'He was dead the whole time!',
        createdAt: DateTime(2026, 8, 18),
        starredBy: const [],
        commentCount: 0,
        movieId: 603,
        isTv: false,
        movieTitle: 'The Sixth Sense',
        isSpoiler: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: LocalizedTestApp(
            locale: const Locale('tr'),
            home: Scaffold(
              body: CommunityPostCard(
                post: spoilerPost,
                currentUser: null,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Caption should be hidden and replaced by spoiler warning
      expect(find.text('"He was dead the whole time!"'), findsNothing);
      expect(find.text('Bu gönderi spoiler içeriyor'), findsOneWidget);
      expect(find.text('Görmek için dokunun'), findsOneWidget);
      expect(find.text('SPOILER'), findsOneWidget);

      // Tap to reveal
      await tester.tap(find.text('Bu gönderi spoiler içeriyor'));
      await tester.pumpAndSettle();

      // Caption is now visible
      expect(find.text('"He was dead the whole time!"'), findsOneWidget);
    });

    testWidgets('shows non-spoiler caption immediately', (tester) async {
      final regularPost = CommunityPost(
        id: 'post-regular',
        userId: 'user-1',
        username: 'alice',
        userAvatarUrl: '',
        type: 'movie',
        caption: 'Amazing cinematography!',
        createdAt: DateTime(2026, 8, 18),
        starredBy: const [],
        commentCount: 0,
        movieId: 603,
        isTv: false,
        movieTitle: 'The Matrix',
        isSpoiler: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: LocalizedTestApp(
            locale: const Locale('tr'),
            home: Scaffold(
              body: CommunityPostCard(
                post: regularPost,
                currentUser: null,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('"Amazing cinematography!"'), findsOneWidget);
      expect(find.text('Bu gönderi spoiler içeriyor'), findsNothing);
    });
  });
}
