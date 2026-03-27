import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/models/user_model.dart';

final friendServiceProvider = Provider<FriendService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FriendService(dio);
});

class FriendService {
  final DioClient _dio;

  FriendService(this._dio);

  Future<List<User>> getFriends({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.friends, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => User.fromJson(e)).toList();
  }

  Future<List<User>> getFriendSuggestions({int? page, int? pageSize}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.friendSuggestions, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => User.fromJson(e)).toList();
  }

  Future<List<Friendship>> getFriendRequests({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.friendRequests, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Friendship.fromJson(e)).toList();
  }

  Future<void> sendFriendRequest(String userId) async {
    await _dio.post(ApiConstants.sendFriendRequest, data: {'to_user': userId});
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await _dio.post(ApiConstants.acceptFriendRequest(friendshipId));
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    await _dio.post(ApiConstants.rejectFriendRequest(friendshipId));
  }

  Future<void> removeFriend(String friendshipId) async {
    await _dio.delete(ApiConstants.removeFriend(friendshipId));
  }

  Future<Map<String, dynamic>> getFriendshipStatus(String userId) async {
    final response = await _dio.get(ApiConstants.friendshipStatus(userId));
    return response.data;
  }
}
