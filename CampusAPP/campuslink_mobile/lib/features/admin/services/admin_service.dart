import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/admin_model.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AdminService(dio);
});

class AdminService {
  final DioClient _dio;

  AdminService(this._dio);

  // ============ DASHBOARD STATS ============
  Future<AdminDashboardStats> getAdminDashboardStats() async {
    final response = await _dio.get(ApiConstants.adminDashboardStats);
    return AdminDashboardStats.fromJson(response.data);
  }

  Future<UniversityAdminDashboardStats> getUniversityAdminDashboardStats() async {
    final response = await _dio.get(ApiConstants.universityAdminDashboardStats);
    return UniversityAdminDashboardStats.fromJson(response.data);
  }

  Future<ClassLeaderDashboardStats> getClassLeaderDashboardStats() async {
    final response = await _dio.get(ApiConstants.classLeaderDashboardStats);
    return ClassLeaderDashboardStats.fromJson(response.data);
  }

  // ============ PENDING STUDENTS ============
  Future<List<PendingStudent>> getPendingStudents() async {
    final response = await _dio.get(ApiConstants.pendingStudents);
    final results = response.data as List;
    return results.map((e) => PendingStudent.fromJson(e)).toList();
  }

  Future<void> activateStudent(String id) async {
    await _dio.post(ApiConstants.activateStudent(id));
  }

  Future<void> deactivateStudent(String id) async {
    await _dio.post(ApiConstants.deactivateStudent(id));
  }

  // ============ CLASS LEADERS ============
  Future<List<ClassLeader>> getClassLeaders() async {
    final response = await _dio.get(ApiConstants.classLeaders);
    final results = response.data as List;
    return results.map((e) => ClassLeader.fromJson(e)).toList();
  }

  Future<List<ClassLeader>> getClassLeadersByUniversity() async {
    final response = await _dio.get(ApiConstants.classLeadersByUniversity);
    final results = response.data as List;
    return results.map((e) => ClassLeader.fromJson(e)).toList();
  }

  Future<void> assignClassLeader(String userId) async {
    await _dio.post(ApiConstants.assignClassLeader(userId));
  }

  Future<void> revokeClassLeader(String userId) async {
    await _dio.post(ApiConstants.revokeClassLeader(userId));
  }

  // ============ USER MANAGEMENT (University Admin) ============
  Future<void> createStudent(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.createStudent, data: data);
  }
}
