import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_post_model.dart';

// Every doc in `posts` is, by construction, something a user explicitly
// chose to publish (see ShareComposeSheet) — unlike `logs` there is no
// isPublic filter here, a post existing IS the publication.
final communityFeedProvider = StreamProvider<List<CommunityPost>>((ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => CommunityPost.fromMap(doc.data(), doc.id)).toList();
      });
});
