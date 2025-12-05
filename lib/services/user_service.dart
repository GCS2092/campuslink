import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Service pour gérer les utilisateurs, amis, profils
class UserService {
  final ApiService _apiService = ApiService();

  /// Récupère la liste des utilisateurs avec filtres
  Future<List<User>> getUsers({
    bool? verifiedOnly,
    String? university,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (verifiedOnly != null) params['verified_only'] = verifiedOnly;
      if (university != null) params['university'] = university;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
        }
      }
      return <User>[];
    } catch (e) {
      debugPrint('Error getting users: $e');
      return <User>[];
    }
  }

  /// Récupère un utilisateur par son ID
  Future<User?> getUser(String id) async {
    try {
      final response = await _apiService.get('/users/$id/');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user $id: $e');
      return null;
    }
  }

  /// Récupère les amis de l'utilisateur
  Future<List<User>> getFriends() async {
    try {
      final response = await _apiService.get('/users/friends/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
        }
      }
      return <User>[];
    } catch (e) {
      debugPrint('Error getting friends: $e');
      return <User>[];
    }
  }

  /// Envoie une demande d'ami
  Future<Map<String, dynamic>> sendFriendRequest(String toUserId) async {
    try {
      final response = await _apiService.post(
        '/users/friends/request/',
        data: {'to_user_id': toUserId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Accepte une demande d'ami
  Future<Map<String, dynamic>> acceptFriendRequest(String friendshipId) async {
    try {
      final response = await _apiService.put('/users/friends/$friendshipId/accept/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Erreur'};
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Rejette une demande d'ami
  Future<Map<String, dynamic>> rejectFriendRequest(String friendshipId) async {
    try {
      final response = await _apiService.put('/users/friends/$friendshipId/reject/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Erreur'};
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Supprime un ami
  Future<Map<String, dynamic>> removeFriend(String friendshipId) async {
    try {
      final response = await _apiService.delete('/users/friends/$friendshipId/');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {'success': false, 'error': 'Erreur'};
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les demandes d'ami
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    try {
      final response = await _apiService.get('/users/friends/requests/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((r) => r as Map<String, dynamic>).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((r) => r as Map<String, dynamic>).toList();
        }
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('Error getting friend requests: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Récupère le statut d'amitié avec un utilisateur
  Future<Map<String, dynamic>> getFriendshipStatus(String userId) async {
    try {
      final response = await _apiService.get('/users/friends/status/$userId/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {'status': 'none'};
    } catch (e) {
      debugPrint('Error getting friendship status: $e');
      return {'status': 'none'};
    }
  }

  /// Récupère les suggestions d'amis
  Future<List<User>> getFriendSuggestions({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/users/friends/suggestions/',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((u) => User.fromJson(u as Map<String, dynamic>)).toList();
        }
      }
      return <User>[];
    } catch (e) {
      debugPrint('Error getting friend suggestions: $e');
      return <User>[];
    }
  }

  /// Met à jour le profil
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put('/users/profile/', data: profileData);
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les statistiques du profil
  Future<Map<String, dynamic>?> getProfileStats() async {
    try {
      final response = await _apiService.get('/users/profile/stats/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting profile stats: $e');
      return null;
    }
  }

  /// Change le mot de passe de l'utilisateur
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/change-password/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        },
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Mot de passe modifié avec succès'};
      }
      return {
        'success': false,
        'error': response.data['error'] ?? 'Erreur lors du changement de mot de passe',
      };
    } catch (e) {
      debugPrint('Error changing password: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les préférences de notifications
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final response = await _apiService.get('/auth/notification-preferences/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      // Retourner les valeurs par défaut en cas d'erreur
      return {
        'email_notifications': true,
        'push_notifications': true,
        'event_reminders': true,
        'friend_requests': true,
        'messages': true,
        'group_updates': true,
        'event_invitations': true,
      };
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
      // Retourner les valeurs par défaut
      return {
        'email_notifications': true,
        'push_notifications': true,
        'event_reminders': true,
        'friend_requests': true,
        'messages': true,
        'group_updates': true,
        'event_invitations': true,
      };
    }
  }

  /// Met à jour les préférences de notifications
  Future<Map<String, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final response = await _apiService.put(
        '/auth/notification-preferences/',
        data: preferences,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {
        'success': false,
        'error': response.data['error'] ?? 'Erreur lors de la mise à jour des préférences',
      };
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

