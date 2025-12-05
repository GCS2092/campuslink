import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Service pour gérer les notifications
class NotificationService {
  final ApiService _apiService = ApiService();

  /// Récupère la liste des notifications
  Future<List<Notification>> getNotifications({
    bool? isRead,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (isRead != null) params['is_read'] = isRead;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        AppConstants.notificationsEndpoint,
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((n) => Notification.fromJson(n as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((n) => Notification.fromJson(n as Map<String, dynamic>)).toList();
        }
      }
      return <Notification>[];
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return <Notification>[];
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('${AppConstants.notificationsEndpoint}unread_count/');
      if (response.statusCode == 200) {
        return response.data['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Marque une notification comme lue
  Future<bool> markAsRead(String id) async {
    try {
      final response = await _apiService.put('${AppConstants.notificationsEndpoint}$id/read/');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Marque toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.put('${AppConstants.notificationsEndpoint}read_all/');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Supprime une notification
  Future<bool> deleteNotification(String id) async {
    try {
      final response = await _apiService.delete('${AppConstants.notificationsEndpoint}$id/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }
}

