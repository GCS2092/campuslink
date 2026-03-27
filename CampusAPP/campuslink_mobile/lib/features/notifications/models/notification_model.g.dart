// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    _Notification(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      image: json['image'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] as String?,
      isActioned: json['isActioned'] as bool? ?? false,
      actionedAt: json['actionedAt'] as String?,
      actionType: json['actionType'] as String?,
      actionUrl: json['actionUrl'] as String?,
      senderId: json['senderId'] as String?,
      sender: json['sender'] == null
          ? null
          : UserBasic.fromJson(json['sender'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$NotificationToJson(_Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'data': instance.data,
      'image': instance.image,
      'isRead': instance.isRead,
      'readAt': instance.readAt,
      'isActioned': instance.isActioned,
      'actionedAt': instance.actionedAt,
      'actionType': instance.actionType,
      'actionUrl': instance.actionUrl,
      'senderId': instance.senderId,
      'sender': instance.sender,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  pushEnabled: json['pushEnabled'] as bool? ?? true,
  emailEnabled: json['emailEnabled'] as bool? ?? true,
  friendRequestsEnabled: json['friendRequestsEnabled'] as bool? ?? true,
  messagesEnabled: json['messagesEnabled'] as bool? ?? true,
  groupUpdatesEnabled: json['groupUpdatesEnabled'] as bool? ?? true,
  eventRemindersEnabled: json['eventRemindersEnabled'] as bool? ?? true,
  mentionsEnabled: json['mentionsEnabled'] as bool? ?? true,
  marketingEnabled: json['marketingEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'pushEnabled': instance.pushEnabled,
  'emailEnabled': instance.emailEnabled,
  'friendRequestsEnabled': instance.friendRequestsEnabled,
  'messagesEnabled': instance.messagesEnabled,
  'groupUpdatesEnabled': instance.groupUpdatesEnabled,
  'eventRemindersEnabled': instance.eventRemindersEnabled,
  'mentionsEnabled': instance.mentionsEnabled,
  'marketingEnabled': instance.marketingEnabled,
};

_UserBasic _$UserBasicFromJson(Map<String, dynamic> json) => _UserBasic(
  id: json['id'] as String,
  username: json['username'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  profilePicture: json['profilePicture'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$UserBasicToJson(_UserBasic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePicture': instance.profilePicture,
      'role': instance.role,
    };
