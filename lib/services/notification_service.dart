import '../models/notification.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:flutter/foundation.dart';

/// Service pour gérer les notifications in-app de l'application
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();

  /// Récupère la liste des notifications
  /// [isRead] : filtre par statut de lecture (null = toutes)
  Future<List<Notification>> getNotifications({bool? isRead}) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (isRead != null) {
        queryParams['is_read'] = isRead.toString();
      }

      final response = await _apiService.get(
        AppConstants.notificationsEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Gérer la pagination si nécessaire
        final List<dynamic> notificationsList = data is List
            ? data
            : (data['results'] as List? ?? []);
        
        return notificationsList
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      rethrow;
    }
  }

  /// Récupère une notification spécifique
  Future<Notification> getNotification(String id) async {
    try {
      final response = await _apiService.get('${AppConstants.notificationsEndpoint}$id/');

      if (response.statusCode == 200) {
        return Notification.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération de la notification');
      }
    } catch (e) {
      debugPrint('Error getting notification: $e');
      rethrow;
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('${AppConstants.notificationsEndpoint}unread_count/');

      if (response.statusCode == 200) {
        return (response.data as Map<String, dynamic>)['unread_count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String id) async {
    try {
      await _apiService.put('${AppConstants.notificationsEndpoint}$id/read/');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put('${AppConstants.notificationsEndpoint}read_all/');
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Supprime une notification
  Future<bool> deleteNotification(String id) async {
    try {
      // Utiliser l'action delete personnalisée (supporte DELETE et POST)
      final response = await _apiService.delete('${AppConstants.notificationsEndpoint}$id/delete/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      // Si DELETE échoue, essayer avec POST (pour compatibilité avec l'action Django)
      try {
        final response = await _apiService.post('${AppConstants.notificationsEndpoint}$id/delete/');
        return response.statusCode == 204 || response.statusCode == 200;
      } catch (e2) {
        debugPrint('Error deleting notification: $e2');
        return false;
      }
    }
  }
}

