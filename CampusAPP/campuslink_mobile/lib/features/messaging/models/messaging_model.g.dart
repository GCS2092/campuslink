// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      conversationType: json['conversationType'] as String? ?? 'private',
      name: json['name'] as String?,
      groupId: json['groupId'] as String?,
      group: json['group'] == null
          ? null
          : GroupBasic.fromJson(json['group'] as Map<String, dynamic>),
      createdById: json['createdById'] as String,
      createdBy: json['createdBy'] == null
          ? null
          : UserBasic.fromJson(json['createdBy'] as Map<String, dynamic>),
      lastMessageAt: json['lastMessageAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationType': instance.conversationType,
      'name': instance.name,
      'groupId': instance.groupId,
      'group': instance.group,
      'createdById': instance.createdById,
      'createdBy': instance.createdBy,
      'lastMessageAt': instance.lastMessageAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
    };

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  userId: json['userId'] as String,
  user: json['user'] == null
      ? null
      : UserBasic.fromJson(json['user'] as Map<String, dynamic>),
  joinedAt: json['joinedAt'] as String?,
  leftAt: json['leftAt'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  lastReadAt: json['lastReadAt'] as String?,
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  isPinned: json['isPinned'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
  isFavorite: json['isFavorite'] as bool? ?? false,
  muteNotifications: json['muteNotifications'] as bool? ?? false,
);

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'user': instance.user,
      'joinedAt': instance.joinedAt,
      'leftAt': instance.leftAt,
      'isActive': instance.isActive,
      'lastReadAt': instance.lastReadAt,
      'unreadCount': instance.unreadCount,
      'isPinned': instance.isPinned,
      'isArchived': instance.isArchived,
      'isFavorite': instance.isFavorite,
      'muteNotifications': instance.muteNotifications,
    };

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  senderId: json['senderId'] as String,
  sender: json['sender'] == null
      ? null
      : UserBasic.fromJson(json['sender'] as Map<String, dynamic>),
  content: json['content'] as String,
  messageType: json['messageType'] as String? ?? 'text',
  attachmentUrl: json['attachmentUrl'] as String?,
  attachmentName: json['attachmentName'] as String?,
  attachmentSize: (json['attachmentSize'] as num?)?.toInt(),
  isRead: json['isRead'] as bool? ?? false,
  readBy: (json['readBy'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: json['createdAt'] as String?,
  editedAt: json['editedAt'] as String?,
  deletedAt: json['deletedAt'] as String?,
  isDeletedForAll: json['isDeletedForAll'] as bool? ?? false,
  reactions: (json['reactions'] as List<dynamic>?)
      ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'sender': instance.sender,
  'content': instance.content,
  'messageType': instance.messageType,
  'attachmentUrl': instance.attachmentUrl,
  'attachmentName': instance.attachmentName,
  'attachmentSize': instance.attachmentSize,
  'isRead': instance.isRead,
  'readBy': instance.readBy,
  'createdAt': instance.createdAt,
  'editedAt': instance.editedAt,
  'deletedAt': instance.deletedAt,
  'isDeletedForAll': instance.isDeletedForAll,
  'reactions': instance.reactions,
};

_MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) =>
    _MessageReaction(
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : UserBasic.fromJson(json['user'] as Map<String, dynamic>),
      emoji: json['emoji'] as String,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$MessageReactionToJson(_MessageReaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'user': instance.user,
      'emoji': instance.emoji,
      'createdAt': instance.createdAt,
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

_GroupBasic _$GroupBasicFromJson(Map<String, dynamic> json) => _GroupBasic(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  profileImage: json['profileImage'] as String?,
);

Map<String, dynamic> _$GroupBasicToJson(_GroupBasic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'profileImage': instance.profileImage,
    };
