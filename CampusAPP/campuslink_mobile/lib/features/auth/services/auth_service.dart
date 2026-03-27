import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthService(dio);
});

class AuthService {
  final DioClient _dio;

  AuthService(this._dio);

  Future<AuthTokens> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return AuthTokens.fromJson(response.data);
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? universityId,
    String? campusId,
    String? departmentId,
    String? fieldOfStudy,
    String? academicYear,
  }) async {
    final data = <String, dynamic>{
      'email': email,
      'password': password,
      'username': username,
      if (firstName?.isNotEmpty ?? false) 'first_name': firstName,
      if (lastName?.isNotEmpty ?? false) 'last_name': lastName,
      if (phoneNumber?.isNotEmpty ?? false) 'phone_number': phoneNumber,
      if (universityId?.isNotEmpty ?? false) 'university': universityId,
      if (campusId?.isNotEmpty ?? false) 'campus': campusId,
      if (departmentId?.isNotEmpty ?? false) 'department': departmentId,
      if (fieldOfStudy?.isNotEmpty ?? false) 'field_of_study': fieldOfStudy,
      if (academicYear?.isNotEmpty ?? false) 'academic_year': academicYear,
    };
    await _dio.post(ApiConstants.register, data: data);
  }

  Future<AuthTokens> verifyPhone(String email, String otp) async {
    final response = await _dio.post(
      ApiConstants.verifyPhone,
      data: {'email': email, 'otp': otp},
    );
    return AuthTokens.fromJson(response.data);
  }

  Future<void> resendOtp(String email) async {
    await _dio.post(ApiConstants.resendOtp, data: {'email': email});
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.tokenRefresh,
      data: {'refresh': refreshToken},
    );
    return response.data;
  }

  Future<User> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return User.fromJson(response.data);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.profile, data: data);
    return User.fromJson(response.data);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.post(ApiConstants.changePassword, data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    final response = await _dio.get(ApiConstants.profileStats);
    return response.data;
  }

  Future<Map<String, dynamic>> getProfileStatsDetailed() async {
    final response = await _dio.get(ApiConstants.profileStatsDetailed);
    return response.data;
  }

  Future<Map<String, dynamic>> getVerificationStatus() async {
    final response = await _dio.get(ApiConstants.verificationStatus);
    return response.data;
  }
}
