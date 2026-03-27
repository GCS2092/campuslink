// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Group _$GroupFromJson(Map<String, dynamic> json) => _Group(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  description: json['description'] as String,
  profileImage: json['profileImage'] as String?,
  coverImage: json['coverImage'] as String?,
  creatorId: json['creatorId'] as String,
  creator: json['creator'] == null
      ? null
      : UserBasic.fromJson(json['creator'] as Map<String, dynamic>),
  universityId: json['universityId'] as String?,
  universityName: json['universityName'] as String?,
  category: json['category'] as String?,
  isPublic: json['isPublic'] as bool? ?? true,
  isVerified: json['isVerified'] as bool? ?? false,
  membersCount: (json['membersCount'] as num?)?.toInt() ?? 0,
  postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
  eventsCount: (json['eventsCount'] as num?)?.toInt() ?? 0,
  currentUserMembership: json['currentUserMembership'] == null
      ? null
      : Membership.fromJson(
          json['currentUserMembership'] as Map<String, dynamic>,
        ),
  isMember: json['isMember'] as bool? ?? false,
  hasPendingRequest: json['hasPendingRequest'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$GroupToJson(_Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'profileImage': instance.profileImage,
  'coverImage': instance.coverImage,
  'creatorId': instance.creatorId,
  'creator': instance.creator,
  'universityId': instance.universityId,
  'universityName': instance.universityName,
  'category': instance.category,
  'isPublic': instance.isPublic,
  'isVerified': instance.isVerified,
  'membersCount': instance.membersCount,
  'postsCount': instance.postsCount,
  'eventsCount': instance.eventsCount,
  'currentUserMembership': instance.currentUserMembership,
  'isMember': instance.isMember,
  'hasPendingRequest': instance.hasPendingRequest,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  userId: json['userId'] as String,
  user: json['user'] == null
      ? null
      : UserBasic.fromJson(json['user'] as Map<String, dynamic>),
  role: json['role'] as String? ?? 'member',
  status: json['status'] as String? ?? 'active',
  joinedAt: json['joinedAt'] as String?,
  leftAt: json['leftAt'] as String?,
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'user': instance.user,
      'role': instance.role,
      'status': instance.status,
      'joinedAt': instance.joinedAt,
      'leftAt': instance.leftAt,
    };

_GroupPost _$GroupPostFromJson(Map<String, dynamic> json) => _GroupPost(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  group: json['group'] == null
      ? null
      : Group.fromJson(json['group'] as Map<String, dynamic>),
  authorId: json['authorId'] as String,
  author: json['author'] == null
      ? null
      : UserBasic.fromJson(json['author'] as Map<String, dynamic>),
  content: json['content'] as String,
  image: json['image'] as String?,
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$GroupPostToJson(_GroupPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'group': instance.group,
      'authorId': instance.authorId,
      'author': instance.author,
      'content': instance.content,
      'image': instance.image,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'isLiked': instance.isLiked,
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
