import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/community_post_model.dart';

/// How many posts the feed holds at once. Raised in [communityFeedLimitProvider]
/// steps by the feed screen when the user scrolls to the bottom.
const int kCommunityFeedPageSize = 20;

/// The current feed window size. Bumping it re-subscribes the snapshot listener
/// with a larger `limit`, which is the simplest correct paging model for a
/// live-updating feed: a cursor-based `startAfter` chain would need every page
/// to be its own listener and would drop rows when a post above the cursor is
/// deleted.
final communityFeedLimitProvider = StateProvider<int>((ref) => kCommunityFeedPageSize);

// Every doc in `posts` is, by construction, something a user explicitly
// chose to publish (see ShareComposeSheet) — unlike `logs` there is no
// isPublic filter here, a post existing IS the publication.
final communityFeedProvider = StreamProvider<List<CommunityPost>>((ref) {
  final limit = ref.watch(communityFeedLimitProvider);
  return ref
      .watch(firestoreProvider)
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => CommunityPost.fromMap(doc.data(), doc.id)).toList();
      });
});
