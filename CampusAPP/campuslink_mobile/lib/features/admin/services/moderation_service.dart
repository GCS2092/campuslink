import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/moderation_model.dart';

final moderationServiceProvider = Provider<ModerationService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ModerationService(dio);
});

class ModerationService {
  final DioClient _dio;

  ModerationService(this._dio);

  // ============ REPORTS ============
  Future<List<Report>> getReports({
    String? status,
    String? type,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.reports, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Report.fromJson(e)).toList();
  }

  Future<Report> getReport(String id) async {
    final response = await _dio.get('${ApiConstants.reports}$id/');
    return Report.fromJson(response.data);
  }

  Future<Report> createReport(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.reports, data: data);
    return Report.fromJson(response.data);
  }

  Future<void> resolveReport(String id, String action, {String? notes}) async {
    await _dio.post('${ApiConstants.reports}$id/resolve/', data: <String, dynamic>{
      'action': action,
      if (notes?.isNotEmpty ?? false) 'notes': notes,
    });
  }

  // ============ MODERATIONS ============
  Future<List<ModerationAction>> getModerations({
    String? userId,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) queryParams['user'] = userId;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.moderations, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => ModerationAction.fromJson(e)).toList();
  }

  // ============ USER VERIFICATION & BANNING ============
  Future<void> verifyUser(String userId) async {
    await _dio.post('/auth/admin/users/$userId/verify/');
  }

  Future<void> rejectUser(String userId, {String? reason}) async {
    await _dio.post('/auth/admin/users/$userId/reject/', data: <String, dynamic>{
      if (reason?.isNotEmpty ?? false) 'reason': reason,
    });
  }

  Future<void> banUser(String userId, {String? reason, int? days}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;
    if (days != null) data['days'] = days;
    await _dio.post('/auth/admin/users/$userId/ban/', data: data);
  }

  Future<void> unbanUser(String userId) async {
    await _dio.post('/auth/admin/users/$userId/unban/');
  }

  Future<List<BannedUser>> getBannedUsers() async {
    final response = await _dio.get('/auth/admin/users/banned/');
    final results = response.data as List;
    return results.map((e) => BannedUser.fromJson(e)).toList();
  }

  Future<List<PendingVerification>> getPendingVerifications() async {
    final response = await _dio.get('/auth/admin/users/pending-verifications/');
    final results = response.data as List;
    return results.map((e) => PendingVerification.fromJson(e)).toList();
  }
}
