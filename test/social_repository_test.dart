// The community writes used to live inline in three widgets, each resolving
// the author's identity itself. Testing them meant mounting a widget; getting
// the identity wrong meant a rejected write, because firestore.rules requires
// the stamped username/avatar to equal the caller's profile.
//
// These pin the properties the rules depend on, at the layer that decides them.
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:cinefile/features/auth/models/user_model.dart';
import 'package:cinefile/features/community/data/social_repository.dart';
import 'package:cinefile/features/community/models/community_post_model.dart';

const _uid = 'alice-uid';

CommunityPost _draft({
  String userId = _uid,
  String username = 'Alice',
  String avatar = 'https://api.dicebear.com/7.x/bottts/png?seed=alice',
  List<String> starredBy = const [],
  int commentCount = 0,
}) =>
    CommunityPost(
      id: '',
      userId: userId,
      username: username,
      userAvatarUrl: avatar,
      type: 'movie',
      caption: 'harika film',
      createdAt: DateTime(2025, 6, 1),
      starredBy: starredBy,
      commentCount: commentCount,
      movieId: 27205,
      isTv: false,
      movieTitle: 'Inception',
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;
  late SocialRepository repo;

  ProviderContainer build({bool signedIn = true, UserModel? profile}) {
    return ProviderContainer(overrides: [
      firestoreProvider.overrideWithValue(firestore),
      firebaseAuthProvider.overrideWithValue(
        MockFirebaseAuth(
          signedIn: signedIn,
          mockUser: MockUser(uid: _uid, email: 'alice@example.com'),
        ),
      ),
    ]);
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    container = build();
    container.read(userModelProvider.notifier).state = UserModel(
      id: _uid,
      username: 'Alice',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=alice',
    );
    repo = container.read(socialRepositoryProvider);
  });

  tearDown(() => container.dispose());

  group('publishPost', () {
    test('stamps the caller identity over whatever the draft carried', () async {
      // A draft claiming to be Bob must not be publishable as Bob — and under
      // the current rules such a write would be rejected server-side anyway, so
      // silently correcting it here is what keeps the client working.
      await repo.publishPost(_draft(userId: 'bob-uid', username: 'Bob', avatar: 'https://evil.example/x.png'));

      final doc = (await firestore.collection('posts').get()).docs.single.data();
      expect(doc['userId'], _uid);
      expect(doc['username'], 'Alice');
      expect(doc['userAvatarUrl'], 'https://api.dicebear.com/7.x/bottts/png?seed=alice');
    });

    test('forces social counters to start neutral', () async {
      await repo.publishPost(_draft(starredBy: ['bob', 'carol'], commentCount: 99));

      final doc = (await firestore.collection('posts').get()).docs.single.data();
      expect(doc['starredBy'], isEmpty);
      expect(doc['commentCount'], 0);
    });

    test('keeps the payload the draft is actually for', () async {
      await repo.publishPost(_draft());

      final doc = (await firestore.collection('posts').get()).docs.single.data();
      expect(doc['caption'], 'harika film');
      expect(doc['movieTitle'], 'Inception');
      expect(doc['movieId'], 27205);
    });

    test('refuses when signed out', () async {
      final signedOut = build(signedIn: false);
      addTearDown(signedOut.dispose);
      await expectLater(
        signedOut.read(socialRepositoryProvider).publishPost(_draft()),
        throwsA(isA<NotSignedInException>()),
      );
    });
  });

  group('toggleStar', () {
    test('adds and removes only the caller uid', () async {
      await firestore.collection('posts').doc('p1').set(_draft().toMap());

      await repo.toggleStar(postId: 'p1', currentlyStarred: false);
      expect((await firestore.doc('posts/p1').get()).data()!['starredBy'], [_uid]);

      await repo.toggleStar(postId: 'p1', currentlyStarred: true);
      expect((await firestore.doc('posts/p1').get()).data()!['starredBy'], isEmpty);
    });

    test('leaves other users stars untouched', () async {
      await firestore
          .collection('posts')
          .doc('p1')
          .set(_draft(starredBy: ['bob-uid']).toMap());

      await repo.toggleStar(postId: 'p1', currentlyStarred: false);

      expect(
        (await firestore.doc('posts/p1').get()).data()!['starredBy'],
        containsAll(<String>['bob-uid', _uid]),
      );
    });
  });

  group('comments', () {
    test('adding a comment stamps identity and steps the counter by one', () async {
      await firestore.collection('posts').doc('p1').set(_draft().toMap());

      final comment = await repo.addComment(postId: 'p1', text: 'katılıyorum');

      final stored =
          (await firestore.collection('posts/p1/comments').get()).docs.single.data();
      expect(stored['userId'], _uid);
      expect(stored['username'], 'Alice');
      expect(stored['text'], 'katılıyorum');
      expect(comment.id, isNotEmpty);

      // ±1 is the only change isCommentCountStep permits, so the counter and the
      // subcollection must never drift apart.
      expect((await firestore.doc('posts/p1').get()).data()!['commentCount'], 1);
    });

    test('deleting a comment steps the counter back', () async {
      await firestore.collection('posts').doc('p1').set(_draft().toMap());
      final comment = await repo.addComment(postId: 'p1', text: 'silinecek');

      await repo.deleteComment(postId: 'p1', commentId: comment.id);

      expect((await firestore.collection('posts/p1/comments').get()).docs, isEmpty);
      expect((await firestore.doc('posts/p1').get()).data()!['commentCount'], 0);
    });

    test('refuses to comment when signed out', () async {
      final signedOut = build(signedIn: false);
      addTearDown(signedOut.dispose);
      await expectLater(
        signedOut.read(socialRepositoryProvider).addComment(postId: 'p1', text: 'x'),
        throwsA(isA<NotSignedInException>()),
      );
    });
  });
}
