import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return NotificationService(dio);
});

class NotificationService {
  final DioClient _dio;

  NotificationService(this._dio);

  Future<List<Notification>> getNotifications({
    bool? isRead,
    String? type,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (isRead != null) queryParams['is_read'] = isRead.toString();
    if (type != null) queryParams['type'] = type;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.notifications, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Notification.fromJson(e)).toList();
  }

  Future<Notification> getNotification(String id) async {
    final response = await _dio.get(ApiConstants.notificationDetail(id));
    return Notification.fromJson(response.data);
  }

  Future<void> markAsRead(String id) async {
    await _dio.put(ApiConstants.notificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _dio.put(ApiConstants.notificationsReadAll);
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete(ApiConstants.notificationDetail(id));
  }

  Future<NotificationPreferences> getPreferences() async {
    final response = await _dio.get(ApiConstants.notificationPreferences);
    return NotificationPreferences.fromJson(response.data);
  }

  Future<NotificationPreferences> updatePreferences(NotificationPreferences preferences) async {
    final response = await _dio.put(
      ApiConstants.notificationPreferences,
      data: preferences.toJson(),
    );
    return NotificationPreferences.fromJson(response.data);
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('${ApiConstants.notifications}unread-count/');
    return response.data['count'] as int;
  }
}
