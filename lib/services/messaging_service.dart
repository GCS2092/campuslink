import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service pour gérer les messages et conversations
class MessagingService {
  final ApiService _apiService = ApiService();

  /// Récupère la liste des conversations
  Future<List<Conversation>> getConversations({
    String? type, // 'private' | 'group'
    bool? archived,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (type != null) params['type'] = type;
      if (archived != null) params['archived'] = archived.toString();

      final response = await _apiService.get(
        '/messaging/conversations/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((c) => Conversation.fromJson(c as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((c) => Conversation.fromJson(c as Map<String, dynamic>)).toList();
        }
      }
      return <Conversation>[];
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return [];
    }
  }

  /// Récupère une conversation par son ID
  Future<Conversation?> getConversation(String id) async {
    try {
      final response = await _apiService.get('/messaging/conversations/$id/');
      if (response.statusCode == 200) {
        return Conversation.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting conversation $id: $e');
      return null;
    }
  }

  /// Crée une conversation privée avec un utilisateur
  Future<Conversation?> createPrivateConversation(String userId) async {
    try {
      final response = await _apiService.post(
        '/messaging/conversations/create_private/',
        data: {'user_id': userId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Conversation.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating private conversation: $e');
      return null;
    }
  }

  /// Récupère les messages d'une conversation
  Future<List<Message>> getMessages({
    required String conversationId,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{'conversation': conversationId};
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }

      final response = await _apiService.get(
        AppConstants.messagesEndpoint,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((m) => Message.fromJson(m as Map<String, dynamic>)).toList();
        }
      }
      return <Message>[];
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  /// Envoie un message dans une conversation
  Future<Message?> sendMessage({
    required String conversationId,
    required String content,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String messageType = 'text', // 'text' | 'image' | 'file'
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.messagesEndpoint,
        data: {
          'conversation': conversationId,
          'content': content,
          'message_type': messageType,
          if (attachmentUrl != null) 'attachment_url': attachmentUrl,
          if (attachmentName != null) 'attachment_name': attachmentName,
          if (attachmentSize != null) 'attachment_size': attachmentSize,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Message.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }

  /// Marque un message comme lu
  Future<bool> markMessageRead(String messageId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.messagesEndpoint}$messageId/mark_read/',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking message as read: $e');
      return false;
    }
  }

  /// Édite un message
  Future<Message?> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final response = await _apiService.patch(
        '${AppConstants.messagesEndpoint}$messageId/',
        data: {'content': content},
      );
      if (response.statusCode == 200) {
        return Message.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error editing message: $e');
      return null;
    }
  }

  /// Supprime un message pour tous les participants
  Future<bool> deleteMessageForAll(String messageId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.messagesEndpoint}$messageId/delete_message_for_all/',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return false;
    }
  }

  /// Épingle une conversation
  Future<bool> pinConversation(String conversationId) async {
    try {
      final response = await _apiService.post(
        '/messaging/conversations/$conversationId/pin/',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error pinning conversation: $e');
      return false;
    }
  }

  /// Archive une conversation
  Future<bool> archiveConversation(String conversationId) async {
    try {
      final response = await _apiService.post(
        '/messaging/conversations/$conversationId/archive/',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error archiving conversation: $e');
      return false;
    }
  }

  /// Ajoute une réaction à un message
  Future<bool> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.messagesEndpoint}$messageId/add_reaction/',
        data: {'emoji': emoji},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error adding reaction: $e');
      return false;
    }
  }

  /// Supprime une réaction d'un message
  Future<bool> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.messagesEndpoint}$messageId/remove_reaction/',
        data: {'emoji': emoji},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error removing reaction: $e');
      return false;
    }
  }

  /// Récupère la conversation d'un groupe
  Future<Conversation?> getGroupConversation(String groupId) async {
    try {
      final response = await _apiService.get(
        '/messaging/conversations/group_conversation/',
        queryParameters: {'group_id': groupId},
      );
      if (response.statusCode == 200) {
        return Conversation.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting group conversation: $e');
      return null;
    }
  }
}

