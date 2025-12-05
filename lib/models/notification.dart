/// Modèle Notification
class Notification {
  final String id;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedObjectType;
  final String? relatedObjectId;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedObjectType,
    this.relatedObjectId,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id']?.toString() ?? '',
      notificationType: json['notification_type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      relatedObjectType: json['related_object_type'],
      relatedObjectId: json['related_object_id']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'title': title,
      'message': message,
      'is_read': isRead,
      'related_object_type': relatedObjectType,
      'related_object_id': relatedObjectId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

