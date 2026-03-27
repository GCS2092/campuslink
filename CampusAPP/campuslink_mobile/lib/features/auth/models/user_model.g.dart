// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  role: json['role'] as String? ?? 'student',
  phoneNumber: json['phoneNumber'] as String?,
  phoneVerified: json['phoneVerified'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? false,
  isVerified: json['isVerified'] as bool? ?? false,
  verificationStatus: json['verificationStatus'] as String? ?? 'pending',
  lastActivity: json['lastActivity'] as String?,
  dateJoined: json['dateJoined'] as String?,
  lastLogin: json['lastLogin'] as String?,
  isBanned: json['isBanned'] as bool? ?? false,
  profilePicture: json['profilePicture'] as String?,
  profile: json['profile'] == null
      ? null
      : Profile.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'role': instance.role,
  'phoneNumber': instance.phoneNumber,
  'phoneVerified': instance.phoneVerified,
  'isActive': instance.isActive,
  'isVerified': instance.isVerified,
  'verificationStatus': instance.verificationStatus,
  'lastActivity': instance.lastActivity,
  'dateJoined': instance.dateJoined,
  'lastLogin': instance.lastLogin,
  'isBanned': instance.isBanned,
  'profilePicture': instance.profilePicture,
  'profile': instance.profile,
};

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String?,
  university: json['university'] as String?,
  universityId: json['universityId'] as String?,
  campus: json['campus'] as String?,
  campusId: json['campusId'] as String?,
  department: json['department'] as String?,
  departmentId: json['departmentId'] as String?,
  fieldOfStudy: json['fieldOfStudy'] as String?,
  academicYear: json['academicYear'] as String?,
  academicYearId: json['academicYearId'] as String?,
  bio: json['bio'] as String?,
  profilePicture: json['profilePicture'] as String?,
  coverPicture: json['coverPicture'] as String?,
  dateOfBirth: json['dateOfBirth'] as String?,
  interests: (json['interests'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  website: json['website'] as String?,
  facebook: json['facebook'] as String?,
  instagram: json['instagram'] as String?,
  twitter: json['twitter'] as String?,
  followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
  followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
  friendsCount: (json['friendsCount'] as num?)?.toInt() ?? 0,
  universityEmail: json['universityEmail'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  studentId: json['studentId'] as String?,
  verificationMethod: json['verificationMethod'] as String?,
  reputationScore: (json['reputationScore'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'university': instance.university,
  'universityId': instance.universityId,
  'campus': instance.campus,
  'campusId': instance.campusId,
  'department': instance.department,
  'departmentId': instance.departmentId,
  'fieldOfStudy': instance.fieldOfStudy,
  'academicYear': instance.academicYear,
  'academicYearId': instance.academicYearId,
  'bio': instance.bio,
  'profilePicture': instance.profilePicture,
  'coverPicture': instance.coverPicture,
  'dateOfBirth': instance.dateOfBirth,
  'interests': instance.interests,
  'website': instance.website,
  'facebook': instance.facebook,
  'instagram': instance.instagram,
  'twitter': instance.twitter,
  'followersCount': instance.followersCount,
  'followingCount': instance.followingCount,
  'friendsCount': instance.friendsCount,
  'universityEmail': instance.universityEmail,
  'emailVerified': instance.emailVerified,
  'studentId': instance.studentId,
  'verificationMethod': instance.verificationMethod,
  'reputationScore': instance.reputationScore,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_University _$UniversityFromJson(Map<String, dynamic> json) => _University(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  shortName: json['shortName'] as String?,
  emailDomains: (json['emailDomains'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  logo: json['logo'] as String?,
  coverImage: json['coverImage'] as String?,
  description: json['description'] as String?,
  website: json['website'] as String?,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  studentsCount: (json['studentsCount'] as num?)?.toInt() ?? 0,
  groupsCount: (json['groupsCount'] as num?)?.toInt() ?? 0,
  admin: json['admin'] as Map<String, dynamic>?,
  settings: json['settings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UniversityToJson(_University instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'shortName': instance.shortName,
      'emailDomains': instance.emailDomains,
      'logo': instance.logo,
      'coverImage': instance.coverImage,
      'description': instance.description,
      'website': instance.website,
      'address': instance.address,
      'phone': instance.phone,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'studentsCount': instance.studentsCount,
      'groupsCount': instance.groupsCount,
      'admin': instance.admin,
      'settings': instance.settings,
    };

_Campus _$CampusFromJson(Map<String, dynamic> json) => _Campus(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  universityId: json['universityId'] as String?,
  universityName: json['universityName'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  image: json['image'] as String?,
  isMain: json['isMain'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$CampusToJson(_Campus instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'universityId': instance.universityId,
  'universityName': instance.universityName,
  'address': instance.address,
  'city': instance.city,
  'country': instance.country,
  'phone': instance.phone,
  'email': instance.email,
  'image': instance.image,
  'isMain': instance.isMain,
  'isActive': instance.isActive,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_Department _$DepartmentFromJson(Map<String, dynamic> json) => _Department(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  universityId: json['universityId'] as String?,
  code: json['code'] as String?,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$DepartmentToJson(_Department instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'universityId': instance.universityId,
      'code': instance.code,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_Friendship _$FriendshipFromJson(Map<String, dynamic> json) => _Friendship(
  id: json['id'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  fromUser: json['fromUser'] == null
      ? null
      : User.fromJson(json['fromUser'] as Map<String, dynamic>),
  toUser: json['toUser'] == null
      ? null
      : User.fromJson(json['toUser'] as Map<String, dynamic>),
  status: json['status'] as String? ?? 'pending',
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$FriendshipToJson(_Friendship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'fromUser': instance.fromUser,
      'toUser': instance.toUser,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  access: json['access'] as String,
  refresh: json['refresh'] as String,
  userId: json['userId'] as String?,
  email: json['email'] as String?,
  username: json['username'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  role: json['role'] as String?,
  isStaff: json['isStaff'] as bool?,
  isSuperuser: json['isSuperuser'] as bool?,
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'userId': instance.userId,
      'email': instance.email,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'isStaff': instance.isStaff,
      'isSuperuser': instance.isSuperuser,
    };
