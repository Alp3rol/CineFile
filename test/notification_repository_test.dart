import 'package:cinefile/features/auth/controllers/auth_controller.dart';
import 'package:cinefile/features/community/data/social_repository.dart';
import 'package:cinefile/features/notifications/data/notification_repository.dart';
import 'package:cinefile/features/notifications/domain/app_notification.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const uid = 'alice-uid';
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;
  late NotificationRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(overrides: [
      firestoreProvider.overrideWithValue(firestore),
      firebaseAuthProvider.overrideWithValue(MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: uid))),
    ]);
    repository = container.read(notificationRepositoryProvider);
  });
  tearDown(() => container.dispose());

  Future<void> seed(String id, {DateTime? readAt}) => firestore.collection('users/$uid/notifications').doc(id).set({
    'type': 'comment', 'target': 'communityPost', 'targetId': 'post-1',
    'actorId': 'bob-uid', 'actorName': 'Bob', 'createdAt': DateTime(2026, 8, 13), 'readAt': readAt,
  });

  test('maps a safe target and unread state', () async {
    await seed('n1');
    final item = await repository.watchAll(uid).first.then((items) => items.single);
    expect(item.type, AppNotificationType.comment);
    expect(item.target, AppNotificationTarget.communityPost);
    expect(item.targetId, 'post-1');
    expect(item.isRead, isFalse);
  });

  test('marks one or all unread notifications as read', () async {
    await seed('n1'); await seed('n2');
    await repository.markRead('n1'); await repository.markAllRead();
    final docs = await firestore.collection('users/$uid/notifications').get();
    expect(docs.docs.every((doc) => doc.data()['readAt'] != null), isTrue);
  });

  test('clears only read notifications', () async {
    await seed('read', readAt: DateTime(2026, 8, 13)); await seed('unread');
    await repository.clearRead();
    expect((await firestore.doc('users/$uid/notifications/read').get()).exists, isFalse);
    expect((await firestore.doc('users/$uid/notifications/unread').get()).exists, isTrue);
  });

  test('refuses mutations while signed out', () async {
    final signedOut = ProviderContainer(overrides: [
      firestoreProvider.overrideWithValue(firestore),
      firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
    ]);
    addTearDown(signedOut.dispose);
    expect(() => signedOut.read(notificationRepositoryProvider).markAllRead(), throwsA(isA<NotSignedInException>()));
  });

  test('sendNotification creates a notification for recipient', () async {
    await repository.sendNotification(
      recipientUserId: 'charlie-uid',
      type: AppNotificationType.star,
      target: AppNotificationTarget.communityPost,
      targetId: 'post-99',
      actorId: uid,
      actorName: 'Alice',
    );
    final docs = await firestore.collection('users/charlie-uid/notifications').get();
    expect(docs.docs.length, 1);
    expect(docs.docs.first.data()['type'], 'star');
    expect(docs.docs.first.data()['targetId'], 'post-99');
    expect(docs.docs.first.data()['actorName'], 'Alice');
  });

  test('sendNotification does not create self-notification', () async {
    await repository.sendNotification(
      recipientUserId: uid,
      type: AppNotificationType.star,
      target: AppNotificationTarget.communityPost,
      targetId: 'post-99',
      actorId: uid,
      actorName: 'Alice',
    );
    final docs = await firestore.collection('users/$uid/notifications').get();
    expect(docs.docs.isEmpty, isTrue);
  });
}
