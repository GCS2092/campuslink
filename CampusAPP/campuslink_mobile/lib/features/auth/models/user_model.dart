import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    String? firstName,
    String? lastName,
    @Default('student') String role,
    String? phoneNumber,
    @Default(false) bool phoneVerified,
    @Default(false) bool isActive,
    @Default(false) bool isVerified,
    @Default('pending') String verificationStatus,
    String? lastActivity,
    String? dateJoined,
    String? lastLogin,
    @Default(false) bool isBanned,
    String? profilePicture,
    Profile? profile,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    String? id,
    String? university,
    String? universityId,
    String? campus,
    String? campusId,
    String? department,
    String? departmentId,
    String? fieldOfStudy,
    String? academicYear,
    String? academicYearId,
    String? bio,
    String? profilePicture,
    String? coverPicture,
    String? dateOfBirth,
    List<String>? interests,
    String? website,
    String? facebook,
    String? instagram,
    String? twitter,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int friendsCount,
    String? universityEmail,
    @Default(false) bool emailVerified,
    String? studentId,
    String? verificationMethod,
    @Default(0) int reputationScore,
    String? createdAt,
    String? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

@freezed
abstract class University with _$University {
  const factory University({
    required String id,
    required String name,
    String? slug,
    String? shortName,
    List<String>? emailDomains,
    String? logo,
    String? coverImage,
    String? description,
    String? website,
    String? address,
    String? phone,
    @Default(true) bool isActive,
    String? createdAt,
    String? updatedAt,
    @Default(0) int studentsCount,
    @Default(0) int groupsCount,
    Map<String, dynamic>? admin,
    Map<String, dynamic>? settings,
  }) = _University;

  factory University.fromJson(Map<String, dynamic> json) =>
      _$UniversityFromJson(json);
}

@freezed
abstract class Campus with _$Campus {
  const factory Campus({
    required String id,
    required String name,
    String? slug,
    String? universityId,
    String? universityName,
    String? address,
    String? city,
    String? country,
    String? phone,
    String? email,
    String? image,
    @Default(false) bool isMain,
    @Default(true) bool isActive,
    double? latitude,
    double? longitude,
    String? createdAt,
    String? updatedAt,
  }) = _Campus;

  factory Campus.fromJson(Map<String, dynamic> json) => _$CampusFromJson(json);
}

@freezed
abstract class Department with _$Department {
  const factory Department({
    required String id,
    required String name,
    String? slug,
    String? universityId,
    String? code,
    String? description,
    @Default(true) bool isActive,
    String? createdAt,
    String? updatedAt,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);
}

@freezed
abstract class Friendship with _$Friendship {
  const factory Friendship({
    required String id,
    required String fromUserId,
    required String toUserId,
    User? fromUser,
    User? toUser,
    @Default('pending') String status,
    String? createdAt,
    String? updatedAt,
  }) = _Friendship;

  factory Friendship.fromJson(Map<String, dynamic> json) =>
      _$FriendshipFromJson(json);
}

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String access,
    required String refresh,
    String? userId,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? role,
    bool? isStaff,
    bool? isSuperuser,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
