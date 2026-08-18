part of 'database_provider.dart';

final followedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(<String>{});
  }

  return ref
      .read(firestoreProvider)
      .collection('follows')
      .where('followerId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => doc.data()['followingId'] as String)
            .toSet();
      });
});

// Stream provider to check if a specific user is followed by the current user
final isFollowingProvider = StreamProvider.family<bool, String>((
  ref,
  targetUserId,
) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(false);
  }

  return ref
      .read(firestoreProvider)
      .collection('follows')
      .doc('${user.uid}_$targetUserId')
      .snapshots()
      .map((doc) => doc.exists);
});

// Toggles a follow relationship: creates/deletes the follows/{followerId}_{targetId}
// doc and bumps both users' followerCount/followingCount atomically. Lives here
// (next to the follow-related providers above) rather than in auth_controller.dart
// since it's the shared write counterpart to followedUserIdsProvider/isFollowingProvider.
Future<void> toggleFollow(
  WidgetRef ref, {
  required String currentUserId,
  required String targetUserId,
  required bool currentlyFollowing,
}) async {
  final firestore = ref.read(firestoreProvider);
  final followDocRef = firestore
      .collection('follows')
      .doc('${currentUserId}_$targetUserId');
  final currentUserRef = firestore.collection('users').doc(currentUserId);
  final targetUserRef = firestore.collection('users').doc(targetUserId);

  final batch = firestore.batch();

  if (currentlyFollowing) {
    batch.delete(followDocRef);
    batch.update(currentUserRef, {
      'followingCount': FieldValue.increment(-1),
      'lastFollowTargetId': targetUserId,
    });
    batch.update(targetUserRef, {'followerCount': FieldValue.increment(-1)});
  } else {
    batch.set(followDocRef, {
      'followerId': currentUserId,
      'followingId': targetUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(currentUserRef, {
      'followingCount': FieldValue.increment(1),
      'lastFollowTargetId': targetUserId,
    });
    batch.update(targetUserRef, {'followerCount': FieldValue.increment(1)});
  }

  await batch.commit();

  if (!currentlyFollowing && currentUserId != targetUserId) {
    try {
      final currentUserDoc = await currentUserRef.get();
      final username = currentUserDoc.data()?['username'] as String?;
      await ref.read(notificationRepositoryProvider).sendNotification(
        recipientUserId: targetUserId,
        type: AppNotificationType.follow,
        target: AppNotificationTarget.userProfile,
        targetId: currentUserId,
        actorId: currentUserId,
        actorName: username,
      );
    } catch (_) {
      // Notification failure should not fail follow toggle
    }
  }
}

// Stream provider to get a set of favorite movie IDs
