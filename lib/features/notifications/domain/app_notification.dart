import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType { comment, star, follow, newEpisode }
enum AppNotificationTarget { communityPost, userProfile, tvShow }

class AppNotification {
  const AppNotification({required this.id, required this.type, required this.target, required this.targetId, required this.createdAt, this.actorId, this.actorName, this.readAt});
  final String id;
  final AppNotificationType type;
  final AppNotificationTarget target;
  final String targetId;
  final DateTime createdAt;
  final String? actorId;
  final String? actorName;
  final DateTime? readAt;
  bool get isRead => readAt != null;

  factory AppNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    return AppNotification(
      id: document.id,
      type: AppNotificationType.values.byName(data['type'] as String),
      target: AppNotificationTarget.values.byName(data['target'] as String),
      targetId: data['targetId'] as String,
      createdAt: _date(data['createdAt']),
      actorId: data['actorId'] as String?,
      actorName: data['actorName'] as String?,
      readAt: data['readAt'] == null ? null : _date(data['readAt']),
    );
  }

  static DateTime _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw const FormatException('Notification date is missing or invalid');
  }
}
