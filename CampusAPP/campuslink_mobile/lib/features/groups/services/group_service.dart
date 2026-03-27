import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/group_model.dart';

final groupServiceProvider = Provider<GroupService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return GroupService(dio);
});

class GroupService {
  final DioClient _dio;

  GroupService(this._dio);

  Future<List<Group>> getGroups({
    String? search,
    String? university,
    String? category,
    bool? isPublic,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null) queryParams['search'] = search;
    if (university != null) queryParams['university'] = university;
    if (category != null) queryParams['category'] = category;
    if (isPublic != null) queryParams['is_public'] = isPublic.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.groups, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Group.fromJson(e)).toList();
  }

  Future<Group> getGroup(String id) async {
    final response = await _dio.get(ApiConstants.groupDetail(id));
    return Group.fromJson(response.data);
  }

  Future<Group> createGroup(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.groups, data: data);
    return Group.fromJson(response.data);
  }

  Future<Group> updateGroup(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.groupDetail(id), data: data);
    return Group.fromJson(response.data);
  }

  Future<void> deleteGroup(String id) async {
    await _dio.delete(ApiConstants.groupDetail(id));
  }

  Future<void> joinGroup(String id) async {
    await _dio.post(ApiConstants.groupJoin(id));
  }

  Future<void> leaveGroup(String id) async {
    await _dio.post(ApiConstants.groupLeave(id));
  }

  Future<List<Membership>> getGroupMembers(String id, {int? page, int? pageSize}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.groupMembers(id), queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Membership.fromJson(e)).toList();
  }

  Future<List<GroupPost>> getGroupPosts({
    String? groupId,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (groupId != null) queryParams['group'] = groupId;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.groupPosts, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => GroupPost.fromJson(e)).toList();
  }

  Future<GroupPost> createGroupPost(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.groupPosts, data: data);
    return GroupPost.fromJson(response.data);
  }

  Future<GroupPost> updateGroupPost(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('${ApiConstants.groupPosts}$id/', data: data);
    return GroupPost.fromJson(response.data);
  }

  Future<void> deleteGroupPost(String id) async {
    await _dio.delete('${ApiConstants.groupPosts}$id/');
  }
}
