import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Service pour gérer les fonctionnalités spécifiques aux responsables de classe
class ClassLeaderService {
  final ApiService _apiService = ApiService();

  /// Récupère les statistiques du dashboard pour un responsable de classe
  /// Les stats sont filtrées par l'université ET la classe du responsable
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _apiService.get('/users/class-leader/dashboard-stats/');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting class leader dashboard stats: $e');
      return null;
    }
  }

  /// Récupère les événements de la classe du responsable (pour modération)
  Future<List<Map<String, dynamic>>> getClassEvents({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/events/',
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
      debugPrint('Error getting class events: $e');
      return [];
    }
  }

  /// Récupère les groupes de la classe du responsable (pour modération)
  Future<List<Map<String, dynamic>>> getClassGroups({
    String? search,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null) params['search'] = search;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/groups/',
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
      debugPrint('Error getting class groups: $e');
      return [];
    }
  }

  /// Récupère les étudiants de la classe du responsable
  Future<List<Map<String, dynamic>>> getClassStudents({
    String? search,
    int? page,
    int? pageSize,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null) params['search'] = search;
      if (page != null) params['page'] = page;
      if (pageSize != null) params['page_size'] = pageSize;

      final response = await _apiService.get(
        '/users/students/',
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
      debugPrint('Error getting class students: $e');
      return [];
    }
  }
}

