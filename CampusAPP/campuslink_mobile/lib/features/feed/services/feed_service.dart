import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/feed_model.dart';

final feedServiceProvider = Provider<FeedService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FeedService(dio);
});

class FeedService {
  final DioClient _dio;

  FeedService(this._dio);

  Future<List<FeedItem>> getFeed({
    String? type,
    String? university,
    String? visibility,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;
    if (university != null) queryParams['university'] = university;
    if (visibility != null) queryParams['visibility'] = visibility;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.feedItems, queryParameters: queryParams);
    // Backend may return either a list directly or a paginated response with 'results'
    final data = response.data;
    if (data is List) {
      return data.map((e) => FeedItem.fromJson(e)).toList();
    } else if (data is Map && data.containsKey('results')) {
      final results = data['results'] as List;
      return results.map((e) => FeedItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<FeedItem> getFeedItem(String id) async {
    final response = await _dio.get(ApiConstants.feedItemDetail(id));
    return FeedItem.fromJson(response.data);
  }

  Future<FeedItem> createFeedItem(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.feedItems, data: data);
    return FeedItem.fromJson(response.data);
  }

  Future<FeedItem> updateFeedItem(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.feedItemDetail(id), data: data);
    return FeedItem.fromJson(response.data);
  }

  Future<void> deleteFeedItem(String id) async {
    await _dio.delete(ApiConstants.feedItemDetail(id));
  }

  Future<List<SocialPost>> getPosts({
    String? author,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (author != null) queryParams['author'] = author;
    if (search != null) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.posts, queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => SocialPost.fromJson(e)).toList();
  }

  Future<SocialPost> getPost(String id) async {
    final response = await _dio.get(ApiConstants.postDetail(id));
    return SocialPost.fromJson(response.data);
  }

  Future<SocialPost> createPost(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.posts, data: data);
    return SocialPost.fromJson(response.data);
  }

  Future<SocialPost> updatePost(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.postDetail(id), data: data);
    return SocialPost.fromJson(response.data);
  }

  Future<void> deletePost(String id) async {
    await _dio.delete(ApiConstants.postDetail(id));
  }

  Future<void> likePost(String id) async {
    await _dio.post(ApiConstants.postLike(id));
  }

  Future<List<Comment>> getComments(String postId, {int? page, int? pageSize}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final response = await _dio.get(ApiConstants.postComments(postId), queryParameters: queryParams);
    final results = response.data['results'] as List;
    return results.map((e) => Comment.fromJson(e)).toList();
  }

  Future<Comment> addComment(String postId, String content, {String? parentId}) async {
    final data = {'content': content};
    if (parentId != null) data['parent'] = parentId;

    final response = await _dio.post(ApiConstants.postComments(postId), data: data);
    return Comment.fromJson(response.data);
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _dio.delete('${ApiConstants.postComments(postId)}$commentId/');
  }
}
