import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/messaging_model.dart';
import '../services/messaging_service.dart';

// Provider for conversations list
final conversationsProvider = FutureProvider.family<List<Conversation>, ConversationFilterParams>((ref, params) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getConversations(
    type: params.type,
    isArchived: params.isArchived,
    isFavorite: params.isFavorite,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// Provider for a single conversation
final conversationProvider = FutureProvider.family<Conversation, String>((ref, id) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getConversation(id);
});

// Provider for messages in a conversation
final messagesProvider = FutureProvider.family<List<Message>, MessagesParams>((ref, params) async {
  final service = ref.watch(messagingServiceProvider);
  return service.getMessages(
    conversationId: params.conversationId,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// State notifier for conversations
class ConversationsNotifier extends Notifier<ConversationsState> {
  MessagingService get _service => ref.read(messagingServiceProvider);

  @override
  ConversationsState build() => const ConversationsState();

  Future<void> loadConversations({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, conversations: []);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newConversations = await _service.getConversations(
        type: state.type,
        isArchived: state.isArchived,
        isFavorite: state.isFavorite,
        page: state.page,
        pageSize: state.pageSize,
      );

      final allConversations = refresh
          ? newConversations
          : [...state.conversations, ...newConversations];

      state = state.copyWith(
        conversations: allConversations,
        isLoading: false,
        hasMore: newConversations.length == state.pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createConversation({
    required String conversationType,
    String? name,
    String? groupId,
    required List<String> participantIds,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final newConversation = await _service.createConversation(
        conversationType: conversationType,
        name: name,
        groupId: groupId,
        participantIds: participantIds,
      );
      state = state.copyWith(
        conversations: [newConversation, ...state.conversations],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _service.markConversationRead(conversationId);
      // Update local state
      final updatedConversations = state.conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();
      state = state.copyWith(conversations: updatedConversations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setType(String? type) {
    state = state.copyWith(type: type, page: 1);
    loadConversations(refresh: true);
  }

  void setArchived(bool? isArchived) {
    state = state.copyWith(isArchived: isArchived, page: 1);
    loadConversations(refresh: true);
  }

  void setFavorite(bool? isFavorite) {
    state = state.copyWith(isFavorite: isFavorite, page: 1);
    loadConversations(refresh: true);
  }
}

final conversationsNotifierProvider =
    NotifierProvider<ConversationsNotifier, ConversationsState>(
  ConversationsNotifier.new,
);

// State notifier for messages
class MessagesNotifier extends Notifier<MessagesState> {
  MessagingService get _service => ref.read(messagingServiceProvider);

  @override
  MessagesState build() => const MessagesState();

  void setConversationId(String conversationId) {
    state = state.copyWith(conversationId: conversationId, page: 1, messages: []);
    loadMessages(refresh: true);
  }

  Future<void> loadMessages({bool refresh = false}) async {
    if (state.conversationId == null || state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, messages: []);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newMessages = await _service.getMessages(
        conversationId: state.conversationId!,
        page: state.page,
        pageSize: state.pageSize,
      );

      final allMessages = refresh
          ? newMessages
          : [...state.messages, ...newMessages];

      state = state.copyWith(
        messages: allMessages,
        isLoading: false,
        hasMore: newMessages.length == state.pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage({
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    if (state.conversationId == null) return;

    try {
      final newMessage = await _service.sendMessage(
        conversationId: state.conversationId!,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSize: attachmentSize,
      );
      state = state.copyWith(
        messages: [...state.messages, newMessage],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    try {
      await _service.addReaction(messageId, emoji);
      // Update local state
      final updatedMessages = state.messages.map((m) {
        if (m.id == messageId) {
          final newReaction = MessageReaction(
            id: '',
            messageId: messageId,
            userId: '',
            emoji: emoji,
          );
          return m.copyWith(reactions: [...(m.reactions ?? []), newReaction]);
        }
        return m;
      }).toList();
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final messagesNotifierProvider =
    NotifierProvider<MessagesNotifier, MessagesState>(
  MessagesNotifier.new,
);

// State classes
class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? type;
  final bool? isArchived;
  final bool? isFavorite;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 20,
    this.type,
    this.isArchived,
    this.isFavorite,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? type,
    bool? isArchived,
    bool? isFavorite,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      type: type ?? this.type,
      isArchived: isArchived ?? this.isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? conversationId;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 50,
    this.conversationId,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? conversationId,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

// Filter params classes
class ConversationFilterParams {
  final String? type;
  final bool? isArchived;
  final bool? isFavorite;
  final int? page;
  final int? pageSize;

  const ConversationFilterParams({
    this.type,
    this.isArchived,
    this.isFavorite,
    this.page,
    this.pageSize,
  });
}

class MessagesParams {
  final String conversationId;
  final int? page;
  final int? pageSize;

  const MessagesParams({
    required this.conversationId,
    this.page,
    this.pageSize,
  });
}
