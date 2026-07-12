import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../journal/models/diary_log_model.dart';

final communityFeedProvider = StreamProvider<List<DiaryLogModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('logs')
      .where('isPublic', isEqualTo: true)
      .orderBy('watchDate', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => DiaryLogModel.fromMap(doc.data(), doc.id)).toList();
      });
});
