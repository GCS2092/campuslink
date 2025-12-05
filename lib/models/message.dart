/// Modèle Message représentant un message dans une conversation
class Message {
  final String id;
  final String conversationId;
  final MessageSender sender;
  final String content;
  final String messageType; // 'text' | 'image' | 'file'
  final String? attachmentUrl;
  final String? attachmentName;
  final int? attachmentSize;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeletedForAll;
  final DateTime? deletedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    required this.isRead,
    required this.createdAt,
    this.editedAt,
    required this.isDeletedForAll,
    this.deletedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation']?.toString() ?? '',
      sender: MessageSender.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'text',
      attachmentUrl: json['attachment_url'],
      attachmentName: json['attachment_name'],
      attachmentSize: json['attachment_size'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,
      isDeletedForAll: json['is_deleted_for_all'] ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation': conversationId,
      'sender': sender.toJson(),
      'content': content,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'attachment_size': attachmentSize,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted_for_all': isDeletedForAll,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  bool get isEdited => editedAt != null;
  bool get isDeleted => isDeletedForAll || deletedAt != null;
}

class MessageSender {
  final String id;
  final String username;
  final String email;

  MessageSender({
    required this.id,
    required this.username,
    required this.email,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}

/// Modèle Conversation représentant une conversation
class Conversation {
  final String id;
  final String conversationType; // 'private' | 'group'
  final String? name;
  final GroupInfo? group;
  final ConversationCreator createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final List<ConversationParticipant>? participants;
  final Message? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isArchived;
  final bool isFavorite;
  final bool muteNotifications;

  Conversation({
    required this.id,
    required this.conversationType,
    this.name,
    this.group,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.isPinned,
    required this.isArchived,
    required this.isFavorite,
    required this.muteNotifications,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      conversationType: json['conversation_type'] ?? 'private',
      name: json['name'],
      group: json['group'] != null
          ? GroupInfo.fromJson(json['group'])
          : null,
      createdBy: ConversationCreator.fromJson(json['created_by'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => ConversationParticipant.fromJson(p))
              .toList()
          : null,
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      isArchived: json['is_archived'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      muteNotifications: json['mute_notifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_type': conversationType,
      'name': name,
      'group': group?.toJson(),
      'created_by': createdBy.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'participants': participants?.map((p) => p.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'is_favorite': isFavorite,
      'mute_notifications': muteNotifications,
    };
  }

  bool get isPrivate => conversationType == 'private';
  bool get isGroup => conversationType == 'group';
  bool get hasUnreadMessages => unreadCount > 0;
}

class GroupInfo {
  final String id;
  final String name;
  final String slug;
  final String? profileImage;

  GroupInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.profileImage,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'profile_image': profileImage,
    };
  }
}

class ConversationCreator {
  final String id;
  final String username;
  final String email;

  ConversationCreator({
    required this.id,
    required this.username,
    required this.email,
  });

  factory ConversationCreator.fromJson(Map<String, dynamic> json) {
    return ConversationCreator(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}

class ConversationParticipant {
  final String id;
  final ConversationParticipantUser user;
  final DateTime joinedAt;
  final bool isActive;
  final int unreadCount;
  final bool isPinned;
  final bool isArchived;
  final bool isFavorite;
  final bool muteNotifications;

  ConversationParticipant({
    required this.id,
    required this.user,
    required this.joinedAt,
    required this.isActive,
    required this.unreadCount,
    required this.isPinned,
    required this.isArchived,
    required this.isFavorite,
    required this.muteNotifications,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id']?.toString() ?? '',
      user: ConversationParticipantUser.fromJson(json['user'] ?? {}),
      joinedAt: DateTime.parse(json['joined_at']),
      isActive: json['is_active'] ?? true,
      unreadCount: json['unread_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      isArchived: json['is_archived'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      muteNotifications: json['mute_notifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'joined_at': joinedAt.toIso8601String(),
      'is_active': isActive,
      'unread_count': unreadCount,
      'is_pinned': isPinned,
      'is_archived': isArchived,
      'is_favorite': isFavorite,
      'mute_notifications': muteNotifications,
    };
  }
}

class ConversationParticipantUser {
  final String id;
  final String username;
  final String email;

  ConversationParticipantUser({
    required this.id,
    required this.username,
    required this.email,
  });

  factory ConversationParticipantUser.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}

