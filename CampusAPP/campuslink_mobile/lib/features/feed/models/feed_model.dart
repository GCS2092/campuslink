import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_model.freezed.dart';
part 'feed_model.g.dart';

@freezed
abstract class FeedItem with _$FeedItem {
  const factory FeedItem({
    required String id,
    required String authorId,
    UserBasic? author,
    @Default('post') String type,
    String? title,
    required String content,
    String? image,
    @Default('public') String visibility,
    String? university,
    @Default(true) bool isPublished,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    String? createdAt,
    String? updatedAt,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);
}

@freezed
abstract class SocialPost with _$SocialPost {
  const factory SocialPost({
    required String id,
    required String authorId,
    UserBasic? author,
    required String content,
    String? image,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(0) int sharesCount,
    @Default(false) bool isLiked,
    List<Comment>? comments,
    String? createdAt,
    String? updatedAt,
  }) = _SocialPost;

  factory SocialPost.fromJson(Map<String, dynamic> json) =>
      _$SocialPostFromJson(json);
}

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required String authorId,
    UserBasic? author,
    required String content,
    @Default(0) int likesCount,
    @Default(false) bool isLiked,
    String? parentId,
    List<Comment>? replies,
    String? createdAt,
    String? updatedAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}

@freezed
abstract class UserBasic with _$UserBasic {
  const factory UserBasic({
    required String id,
    required String username,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? role,
  }) = _UserBasic;

  factory UserBasic.fromJson(Map<String, dynamic> json) =>
      _$UserBasicFromJson(json);
}
