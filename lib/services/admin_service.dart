import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Service pour gérer les fonctionnalités spécifiques aux administrateurs globaux
class AdminService {
  final ApiService _apiService = ApiService();

  /// Récupère les statistiques du dashboard pour un administrateur global
  /// Les stats incluent toutes les universités
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _apiService.get('/users/admin/dashboard-stats/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting admin dashboard stats: $e');
      return null;
    }
  }

  /// Récupère tous les étudiants (toutes universités)
  Future<List<Map<String, dynamic>>> getAllStudents({
    String? university,
    String? search,
    String? verificationStatus,
    String? isActive,
    String? academicYear,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (university != null) params['university'] = university;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (verificationStatus != null) params['verification_status'] = verificationStatus;
      if (isActive != null) params['is_active'] = isActive;
      if (academicYear != null) params['academic_year'] = academicYear;
      if (ordering != null) params['ordering'] = ordering;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/admin/pending-students/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting all students: $e');
      return [];
    }
  }

  /// Active un étudiant
  Future<Map<String, dynamic>> activateStudent(String userId) async {
    try {
      final response = await _apiService.put('/users/admin/students/$userId/activate/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error activating student: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Désactive un étudiant
  Future<Map<String, dynamic>> deactivateStudent(String userId) async {
    try {
      final response = await _apiService.put('/users/admin/students/$userId/deactivate/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error deactivating student: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Vérifie un utilisateur
  Future<Map<String, dynamic>> verifyUser(String userId) async {
    try {
      final response = await _apiService.post('/users/admin/users/$userId/verify/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error verifying user: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Rejette un utilisateur
  Future<Map<String, dynamic>> rejectUser(String userId) async {
    try {
      final response = await _apiService.post('/users/admin/users/$userId/reject/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error rejecting user: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Bannit un utilisateur
  Future<Map<String, dynamic>> banUser(String userId, {String? reason}) async {
    try {
      final response = await _apiService.post(
        '/users/admin/users/$userId/ban/',
        data: reason != null ? {'reason': reason} : null,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error banning user: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Débannit un utilisateur
  Future<Map<String, dynamic>> unbanUser(String userId) async {
    try {
      final response = await _apiService.post('/users/admin/users/$userId/unban/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error unbanning user: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les vérifications en attente
  Future<List<Map<String, dynamic>>> getPendingVerifications({
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/admin/users/pending-verifications/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting pending verifications: $e');
      return [];
    }
  }

  /// Récupère les utilisateurs bannis
  Future<List<Map<String, dynamic>>> getBannedUsers({
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/admin/users/banned/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting banned users: $e');
      return [];
    }
  }

  /// Récupère les responsables de classe (toutes universités)
  Future<List<Map<String, dynamic>>> getClassLeaders({
    String? university,
    String? search,
    bool? isActive,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (university != null) params['university'] = university;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (isActive != null) params['is_active'] = isActive;
      if (ordering != null) params['ordering'] = ordering;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/admin/class-leaders/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting class leaders: $e');
      return [];
    }
  }

  /// Récupère les responsables de classe par université
  Future<List<Map<String, dynamic>>> getClassLeadersByUniversity() async {
    try {
      final response = await _apiService.get('/users/admin/class-leaders/by-university/');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting class leaders by university: $e');
      return [];
    }
  }

  /// Assigne un responsable de classe
  Future<Map<String, dynamic>> assignClassLeader(String userId) async {
    try {
      final response = await _apiService.put('/users/admin/class-leaders/$userId/assign/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error assigning class leader: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Révoque un responsable de classe
  Future<Map<String, dynamic>> revokeClassLeader(String userId) async {
    try {
      final response = await _apiService.put('/users/admin/class-leaders/$userId/revoke/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error revoking class leader: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère toutes les universités
  Future<List<Map<String, dynamic>>> getUniversities({
    String? search,
    bool? isActive,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (isActive != null) params['is_active'] = isActive;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/universities/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting universities: $e');
      return [];
    }
  }

  /// Récupère une université par ID
  Future<Map<String, dynamic>?> getUniversity(String universityId) async {
    try {
      final response = await _apiService.get('/users/universities/$universityId/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting university: $e');
      return null;
    }
  }

  /// Crée une université
  Future<Map<String, dynamic>> createUniversity(Map<String, dynamic> universityData) async {
    try {
      final response = await _apiService.post('/users/universities/', data: universityData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error creating university: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Met à jour une université
  Future<Map<String, dynamic>> updateUniversity(String universityId, Map<String, dynamic> universityData) async {
    try {
      final response = await _apiService.put('/users/universities/$universityId/', data: universityData);
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error updating university: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Supprime une université
  Future<Map<String, dynamic>> deleteUniversity(String universityId) async {
    try {
      final response = await _apiService.delete('/users/universities/$universityId/');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error deleting university: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Assigne un admin d'université
  Future<Map<String, dynamic>> assignUniversityAdmin(String universityId, String userId) async {
    try {
      final response = await _apiService.post(
        '/users/universities/$universityId/assign_admin/',
        data: {'user_id': userId},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error assigning university admin: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Retire un admin d'université
  Future<Map<String, dynamic>> removeUniversityAdmin(String universityId, String userId) async {
    try {
      final response = await _apiService.delete(
        '/users/universities/$universityId/remove_admin/',
        data: {'user_id': userId},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error removing university admin: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère tous les campus (toutes universités)
  Future<List<Map<String, dynamic>>> getAllCampuses({
    String? university,
    String? search,
    bool? isActive,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (university != null) params['university'] = university;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (isActive != null) params['is_active'] = isActive;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/campuses/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting all campuses: $e');
      return [];
    }
  }

  /// Crée un campus
  Future<Map<String, dynamic>> createCampus(Map<String, dynamic> campusData) async {
    try {
      final response = await _apiService.post('/users/campuses/', data: campusData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error creating campus: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Met à jour un campus
  Future<Map<String, dynamic>> updateCampus(String campusId, Map<String, dynamic> campusData) async {
    try {
      final response = await _apiService.put('/users/campuses/$campusId/', data: campusData);
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error updating campus: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Supprime un campus
  Future<Map<String, dynamic>> deleteCampus(String campusId) async {
    try {
      final response = await _apiService.delete('/users/campuses/$campusId/');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error deleting campus: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère tous les départements (toutes universités)
  Future<List<Map<String, dynamic>>> getAllDepartments({
    String? university,
    String? search,
    bool? isActive,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (university != null) params['university'] = university;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (isActive != null) params['is_active'] = isActive;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/departments/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting all departments: $e');
      return [];
    }
  }

  /// Crée un département
  Future<Map<String, dynamic>> createDepartment(Map<String, dynamic> departmentData) async {
    try {
      final response = await _apiService.post('/users/departments/', data: departmentData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error creating department: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Met à jour un département
  Future<Map<String, dynamic>> updateDepartment(String departmentId, Map<String, dynamic> departmentData) async {
    try {
      final response = await _apiService.put('/users/departments/$departmentId/', data: departmentData);
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error updating department: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Supprime un département
  Future<Map<String, dynamic>> deleteDepartment(String departmentId) async {
    try {
      final response = await _apiService.delete('/users/departments/$departmentId/');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error deleting department: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les rapports de modération (toutes universités)
  Future<List<Map<String, dynamic>>> getModerationReports({
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/moderation/admin/reports/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting moderation reports: $e');
      return [];
    }
  }

  /// Résout un rapport
  Future<Map<String, dynamic>> resolveReport(String reportId) async {
    try {
      final response = await _apiService.post('/moderation/admin/reports/$reportId/resolve/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error resolving report: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Rejette un rapport
  Future<Map<String, dynamic>> rejectReport(String reportId) async {
    try {
      final response = await _apiService.post('/moderation/admin/reports/$reportId/reject/');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error rejecting report: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les logs d'audit (toutes universités)
  Future<List<Map<String, dynamic>>> getAuditLogs({
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/moderation/admin/audit-log/',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['results'] != null) {
          return (data['results'] as List).cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting audit logs: $e');
      return [];
    }
  }

  /// Modère un post
  Future<Map<String, dynamic>> moderatePost(String postId, String action) async {
    try {
      final response = await _apiService.post(
        '/moderation/admin/moderate/post/$postId/',
        data: {'action': action},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error moderating post: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Modère une actualité
  Future<Map<String, dynamic>> moderateFeedItem(String feedItemId, String action) async {
    try {
      final response = await _apiService.post(
        '/moderation/admin/moderate/feed-item/$feedItemId/',
        data: {'action': action},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error moderating feed item: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Modère un commentaire
  Future<Map<String, dynamic>> moderateComment(String commentId, String action) async {
    try {
      final response = await _apiService.post(
        '/moderation/admin/moderate/comment/$commentId/',
        data: {'action': action},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Erreur'};
    } catch (e) {
      debugPrint('Error moderating comment: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

