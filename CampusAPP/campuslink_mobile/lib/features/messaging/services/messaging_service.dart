import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/messaging_model.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return MessagingService(dio);
});

class MessagingService {
  final DioClient _dio;

  MessagingService(this._dio);

  Future<List<Conversation>> getConversations({
    String? type,
    bool? isArchived,
    bool? isFavorite,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type?.isNotEmpty ?? false) queryParams['type'] = type;
    if (isArchived != null) queryParams['is_archived'] = isArchived.toString();
    if (isFavorite != null) queryParams['is_favorite'] = isFavorite.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.conversations, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Conversation.fromJson(e)).toList();
  }

  Future<Conversation> getConversation(String id) async {
    final response = await _dio.get(ApiConstants.conversationDetail(id));
    return Conversation.fromJson(response.data);
  }

  Future<Conversation> createConversation({
    required String conversationType,
    String? name,
    String? groupId,
    required List<String> participantIds,
  }) async {
    final data = <String, dynamic>{
      'conversation_type': conversationType,
      if (name?.isNotEmpty ?? false) 'name': name,
      if (groupId?.isNotEmpty ?? false) 'group': groupId,
      'participants': participantIds,
    };
    final response = await _dio.post(ApiConstants.conversations, data: data);
    return Conversation.fromJson(response.data);
  }

  Future<void> deleteConversation(String id) async {
    await _dio.delete(ApiConstants.conversationDetail(id));
  }

  Future<void> markConversationRead(String id) async {
    await _dio.post(ApiConstants.markConversationRead(id));
  }

  Future<List<Message>> getMessages({
    required String conversationId,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{'conversation': conversationId};
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.messages, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Message.fromJson(e)).toList();
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    final data = <String, dynamic>{
      'conversation': conversationId,
      'content': content,
      'message_type': messageType,
      if (attachmentUrl?.isNotEmpty ?? false) 'attachment_url': attachmentUrl,
      if (attachmentName?.isNotEmpty ?? false) 'attachment_name': attachmentName,
      ...?((attachmentSize == null) ? null : <String, dynamic>{'attachment_size': attachmentSize}),
    };
    final response = await _dio.post(ApiConstants.messages, data: data);
    return Message.fromJson(response.data);
  }

  Future<void> deleteMessage(String id) async {
    await _dio.delete(ApiConstants.messageDetail(id));
  }

  Future<void> addReaction(String messageId, String emoji) async {
    await _dio.post('${ApiConstants.messageDetail(messageId)}react/', data: {'emoji': emoji});
  }

  Future<void> removeReaction(String messageId, String emoji) async {
    await _dio.delete('${ApiConstants.messageDetail(messageId)}react/', data: {'emoji': emoji});
  }
}
