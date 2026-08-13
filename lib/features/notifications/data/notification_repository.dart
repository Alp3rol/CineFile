import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../community/data/social_repository.dart';
import '../domain/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepository(ref));

final appNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(notificationRepositoryProvider).watchAll(user.uid);
});

final unreadNotificationCountProvider = Provider<int>((ref) =>
    ref.watch(appNotificationsProvider).value?.where((item) => !item.isRead).length ?? 0);

class NotificationRepository {
  NotificationRepository(this._ref);
  final Ref _ref;
  FirebaseFirestore get _firestore => _ref.read(firestoreProvider);
  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  Stream<List<AppNotification>> watchAll(String userId) => _collection(userId)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(AppNotification.fromFirestore).toList(growable: false));

  Future<void> markRead(String notificationId) async {
    final user = _ref.currentUser;
    if (user == null) throw const NotSignedInException();
    await _collection(user.uid).doc(notificationId).update({'readAt': FieldValue.serverTimestamp()});
  }

  Future<void> markAllRead() async {
    final user = _ref.currentUser;
    if (user == null) throw const NotSignedInException();
    final unread = await _collection(user.uid).where('readAt', isNull: true).limit(400).get();
    if (unread.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final item in unread.docs) {
      batch.update(item.reference, {'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  Future<void> clearRead() async {
    final user = _ref.currentUser;
    if (user == null) throw const NotSignedInException();
    final read = await _collection(user.uid).where('readAt', isNull: false).limit(400).get();
    if (read.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final item in read.docs) {
      batch.delete(item.reference);
    }
    await batch.commit();
  }
}
