import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/auth_controller.dart';
import '../data/recommendation_model.dart';

final eveningFeedbackServiceProvider = Provider<EveningFeedbackService>(
  EveningFeedbackService.new,
);

class EveningFeedbackService {
  EveningFeedbackService(this._ref);
  final Ref _ref;

  Future<void> save(
    RecommendationItem item, {
    required bool isInterested,
  }) async {
    final user = _ref.currentUser;
    if (user == null) throw StateError('Sign-in is required');
    final key = (tmdbId: item.tmdbId, isTv: item.isTv);
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .collection('movie_settings')
        .doc('${key.tmdbId}_${key.isTv}')
        .set({
          'movieId': key.tmdbId,
          'isTv': key.isTv,
          'swipeDecision': isInterested ? 'interested' : 'passed',
          'swipeGenreIds': item.genreIds,
          'swipeSkipReason': isInterested ? null : 'notForMe',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
