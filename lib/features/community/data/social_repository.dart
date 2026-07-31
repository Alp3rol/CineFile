import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/auth_controller.dart';
import '../models/community_post_model.dart';
import '../presentation/comments_provider.dart';

/// Every write the Community feed makes.
///
/// These lived inline in three widgets — ShareComposeSheet, CommunityPostCard
/// and CommentsSheet — each building its own Firestore document and each
/// resolving the author's identity itself. That was survivable while the
/// server accepted any `username`; it is not now. firestore.rules requires the
/// `username` and `userAvatarUrl` stamped onto a post or comment to equal the
/// caller's profile document, so a call site that resolves identity slightly
/// differently doesn't render slightly differently — its write is rejected.
///
/// Putting the identity stamp in one place means there is exactly one answer,
/// and it is the one the rules check against.
abstract class SocialRepository {
  /// Publishes [draft]. The author fields on it are ignored and replaced with
  /// the current user's, so a caller cannot get them wrong.
  Future<void> publishPost(CommunityPost draft);

  /// Adds or removes the current user's star on [postId].
  Future<void> toggleStar({required String postId, required bool currentlyStarred});

  /// Appends a comment and moves the post's counter in the same batch.
  ///
  /// The counter and the comment must move together: `isCommentCountStep` in
  /// the rules only permits a ±1 change, so a counter that drifted out of step
  /// with the subcollection could never be corrected by the client.
  Future<CommentModel> addComment({required String postId, required String text});

  Future<void> deleteComment({required String postId, required String commentId});
}

class NotSignedInException implements Exception {
  const NotSignedInException();
  @override
  String toString() => 'NotSignedInException: this action requires a signed-in user';
}

final socialRepositoryProvider = Provider<SocialRepository>(
  (ref) => FirestoreSocialRepository(ref),
);

class FirestoreSocialRepository implements SocialRepository {
  FirestoreSocialRepository(this._ref);
  final Ref _ref;

  FirebaseFirestore get _firestore => _ref.read(firestoreProvider);

  CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');

  User _requireUser() {
    final user = _ref.currentUser;
    if (user == null) throw const NotSignedInException();
    return user;
  }

  UserIdentity _identity(User user) =>
      resolveUserIdentity(_ref.read(userModelProvider), user);

  @override
  Future<void> publishPost(CommunityPost draft) async {
    final user = _requireUser();
    final identity = _identity(user);
    await _posts.add({
      ...draft.toMap(),
      'userId': user.uid,
      'username': identity.username,
      'userAvatarUrl': identity.avatarUrl,
      // Social counters describe how other people reacted; the rules require a
      // new document to start neutral, so they are set here rather than trusted
      // from the draft.
      'starredBy': <String>[],
      'commentCount': 0,
    });
  }

  @override
  Future<void> toggleStar({required String postId, required bool currentlyStarred}) async {
    final user = _requireUser();
    await _posts.doc(postId).update({
      'starredBy': currentlyStarred
          ? FieldValue.arrayRemove([user.uid])
          : FieldValue.arrayUnion([user.uid]),
    });
  }

  @override
  Future<CommentModel> addComment({required String postId, required String text}) async {
    final user = _requireUser();
    final identity = _identity(user);

    final postRef = _posts.doc(postId);
    final commentRef = postRef.collection('comments').doc();
    final comment = CommentModel(
      id: commentRef.id,
      userId: user.uid,
      username: identity.username,
      userAvatarUrl: identity.avatarUrl,
      text: text,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(commentRef, comment.toMap());
    batch.update(postRef, {'commentCount': FieldValue.increment(1)});
    await batch.commit();

    return comment;
  }

  @override
  Future<void> deleteComment({required String postId, required String commentId}) async {
    _requireUser();
    final postRef = _posts.doc(postId);

    final batch = _firestore.batch();
    batch.delete(postRef.collection('comments').doc(commentId));
    batch.update(postRef, {'commentCount': FieldValue.increment(-1)});
    await batch.commit();
  }
}
