import 'package:flutter/foundation.dart';
import '../models/group.dart';
import 'api_service.dart';

/// Service pour gérer les groupes
class GroupService {
  final ApiService _apiService = ApiService();

  /// Récupère la liste des groupes
  Future<List<Group>> getGroups({
    String? university,
    String? category,
    bool? isPublic,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (university != null) params['university'] = university;
      if (category != null) params['category'] = category;
      if (isPublic != null) params['is_public'] = isPublic;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/groups/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((g) => Group.fromJson(g as Map<String, dynamic>)).toList();
        } else if (data is Map<String, dynamic> && data['results'] != null) {
          return (data['results'] as List).map((g) => Group.fromJson(g as Map<String, dynamic>)).toList();
        }
      }
      return <Group>[];
    } catch (e) {
      debugPrint('Error getting groups: $e');
      return <Group>[];
    }
  }

  /// Récupère un groupe par son ID
  Future<Group?> getGroup(String id) async {
    try {
      final response = await _apiService.get('/groups/$id/');
      if (response.statusCode == 200) {
        return Group.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting group $id: $e');
      return null;
    }
  }

  /// Crée un nouveau groupe
  Future<Group?> createGroup(Map<String, dynamic> groupData) async {
    try {
      final response = await _apiService.post('/groups/', data: groupData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Group.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating group: $e');
      return null;
    }
  }

  /// Rejoint un groupe
  Future<Map<String, dynamic>> joinGroup(String id) async {
    try {
      final response = await _apiService.post('/groups/$id/join/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error joining group: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Quitte un groupe
  Future<Map<String, dynamic>> leaveGroup(String id) async {
    try {
      final response = await _apiService.post('/groups/$id/leave/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Erreur'};
    } catch (e) {
      debugPrint('Error leaving group: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Invite des utilisateurs à un groupe
  Future<Map<String, dynamic>> inviteUsers(String groupId, List<String> userIds) async {
    try {
      final response = await _apiService.post(
        '/groups/$groupId/invite/',
        data: {'user_ids': userIds},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error inviting users: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Accepte une invitation de groupe
  Future<Map<String, dynamic>> acceptInvitation(String groupId) async {
    try {
      final response = await _apiService.post('/groups/$groupId/accept_invitation/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Rejette une invitation de groupe
  Future<Map<String, dynamic>> rejectInvitation(String groupId) async {
    try {
      final response = await _apiService.post('/groups/$groupId/reject_invitation/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error rejecting invitation: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les invitations de groupe
  Future<List<Map<String, dynamic>>> getMyInvitations() async {
    try {
      final response = await _apiService.get('/groups/my_invitations/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((i) => i as Map<String, dynamic>).toList();
        }
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('Error getting invitations: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Récupère les membres d'un groupe
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final response = await _apiService.get('/groups/$groupId/members/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((m) => m as Map<String, dynamic>).toList();
        }
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('Error getting group members: $e');
      return <Map<String, dynamic>>[];
    }
  }

  /// Modère un groupe (approve/reject) - Admin ou Class Leader uniquement
  Future<Map<String, dynamic>> moderateGroup(String groupId, String action) async {
    try {
      final response = await _apiService.post(
        '/groups/$groupId/moderate/',
        data: {'action': action},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error moderating group: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

