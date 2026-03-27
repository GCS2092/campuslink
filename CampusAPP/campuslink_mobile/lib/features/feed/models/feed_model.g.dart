// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedItem _$FeedItemFromJson(Map<String, dynamic> json) => _FeedItem(
  id: json['id'] as String,
  authorId: json['authorId'] as String,
  author: json['author'] == null
      ? null
      : UserBasic.fromJson(json['author'] as Map<String, dynamic>),
  type: json['type'] as String? ?? 'post',
  title: json['title'] as String?,
  content: json['content'] as String,
  image: json['image'] as String?,
  visibility: json['visibility'] as String? ?? 'public',
  university: json['university'] as String?,
  isPublished: json['isPublished'] as bool? ?? true,
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$FeedItemToJson(_FeedItem instance) => <String, dynamic>{
  'id': instance.id,
  'authorId': instance.authorId,
  'author': instance.author,
  'type': instance.type,
  'title': instance.title,
  'content': instance.content,
  'image': instance.image,
  'visibility': instance.visibility,
  'university': instance.university,
  'isPublished': instance.isPublished,
  'likesCount': instance.likesCount,
  'commentsCount': instance.commentsCount,
  'isLiked': instance.isLiked,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_SocialPost _$SocialPostFromJson(Map<String, dynamic> json) => _SocialPost(
  id: json['id'] as String,
  authorId: json['authorId'] as String,
  author: json['author'] == null
      ? null
      : UserBasic.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String,
  image: json['image'] as String?,
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  comments: (json['comments'] as List<dynamic>?)
      ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$SocialPostToJson(_SocialPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'author': instance.author,
      'content': instance.content,
      'image': instance.image,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
      'isLiked': instance.isLiked,
      'comments': instance.comments,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  postId: json['postId'] as String,
  authorId: json['authorId'] as String,
  author: json['author'] == null
      ? null
      : UserBasic.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String,
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  parentId: json['parentId'] as String?,
  replies: (json['replies'] as List<dynamic>?)
      ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'authorId': instance.authorId,
  'author': instance.author,
  'content': instance.content,
  'likesCount': instance.likesCount,
  'isLiked': instance.isLiked,
  'parentId': instance.parentId,
  'replies': instance.replies,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_UserBasic _$UserBasicFromJson(Map<String, dynamic> json) => _UserBasic(
  id: json['id'] as String,
  username: json['username'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  profilePicture: json['profilePicture'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$UserBasicToJson(_UserBasic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePicture': instance.profilePicture,
      'role': instance.role,
    };
