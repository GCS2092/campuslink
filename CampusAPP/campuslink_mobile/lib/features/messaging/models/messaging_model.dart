import 'package:freezed_annotation/freezed_annotation.dart';

part 'messaging_model.freezed.dart';
part 'messaging_model.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    @Default('private') String conversationType,
    String? name,
    String? groupId,
    GroupBasic? group,
    required String createdById,
    UserBasic? createdBy,
    String? lastMessageAt,
    String? createdAt,
    String? updatedAt,
    List<Participant>? participants,
    Message? lastMessage,
    int? unreadCount,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String conversationId,
    required String userId,
    UserBasic? user,
    String? joinedAt,
    String? leftAt,
    @Default(true) bool isActive,
    String? lastReadAt,
    @Default(0) int unreadCount,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    @Default(false) bool isFavorite,
    @Default(false) bool muteNotifications,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    UserBasic? sender,
    required String content,
    @Default('text') String messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    @Default(false) bool isRead,
    List<String>? readBy,
    String? createdAt,
    String? editedAt,
    String? deletedAt,
    @Default(false) bool isDeletedForAll,
    List<MessageReaction>? reactions,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
abstract class MessageReaction with _$MessageReaction {
  const factory MessageReaction({
    required String id,
    required String messageId,
    required String userId,
    UserBasic? user,
    required String emoji,
    String? createdAt,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);
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

@freezed
abstract class GroupBasic with _$GroupBasic {
  const factory GroupBasic({
    required String id,
    required String name,
    String? slug,
    String? profileImage,
  }) = _GroupBasic;

  factory GroupBasic.fromJson(Map<String, dynamic> json) =>
      _$GroupBasicFromJson(json);
}
