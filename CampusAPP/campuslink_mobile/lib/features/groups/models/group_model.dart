import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
abstract class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    String? slug,
    required String description,
    String? profileImage,
    String? coverImage,
    required String creatorId,
    UserBasic? creator,
    String? universityId,
    String? universityName,
    String? category,
    @Default(true) bool isPublic,
    @Default(false) bool isVerified,
    @Default(0) int membersCount,
    @Default(0) int postsCount,
    @Default(0) int eventsCount,
    Membership? currentUserMembership,
    @Default(false) bool isMember,
    @Default(false) bool hasPendingRequest,
    String? createdAt,
    String? updatedAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required String id,
    required String groupId,
    required String userId,
    UserBasic? user,
    @Default('member') String role,
    @Default('active') String status,
    String? joinedAt,
    String? leftAt,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}

@freezed
abstract class GroupPost with _$GroupPost {
  const factory GroupPost({
    required String id,
    required String groupId,
    Group? group,
    required String authorId,
    UserBasic? author,
    required String content,
    String? image,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    String? createdAt,
    String? updatedAt,
  }) = _GroupPost;

  factory GroupPost.fromJson(Map<String, dynamic> json) =>
      _$GroupPostFromJson(json);
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
