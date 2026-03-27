import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String recipientId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
    String? image,
    @Default(false) bool isRead,
    String? readAt,
    @Default(false) bool isActioned,
    String? actionedAt,
    String? actionType,
    String? actionUrl,
    String? senderId,
    UserBasic? sender,
    String? createdAt,
    String? updatedAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @Default(true) bool pushEnabled,
    @Default(true) bool emailEnabled,
    @Default(true) bool friendRequestsEnabled,
    @Default(true) bool messagesEnabled,
    @Default(true) bool groupUpdatesEnabled,
    @Default(true) bool eventRemindersEnabled,
    @Default(true) bool mentionsEnabled,
    @Default(false) bool marketingEnabled,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

@freezed
abstract class UserBasic with _$UserBasic {
  const factory UserBasic({
    required String id,
    required String username,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? role,
  }) = _UserBasic;

  factory UserBasic.fromJson(Map<String, dynamic> json) =>
      _$UserBasicFromJson(json);
}
