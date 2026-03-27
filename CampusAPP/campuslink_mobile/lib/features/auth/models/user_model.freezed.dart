// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get email; String get username; String? get firstName; String? get lastName; String get role; String? get phoneNumber; bool get phoneVerified; bool get isActive; bool get isVerified; String get verificationStatus; String? get lastActivity; String? get dateJoined; String? get lastLogin; bool get isBanned; String? get profilePicture; Profile? get profile;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.role, role) || other.role == role)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,firstName,lastName,role,phoneNumber,phoneVerified,isActive,isVerified,verificationStatus,lastActivity,dateJoined,lastLogin,isBanned,profilePicture,profile);

@override
String toString() {
  return 'User(id: $id, email: $email, username: $username, firstName: $firstName, lastName: $lastName, role: $role, phoneNumber: $phoneNumber, phoneVerified: $phoneVerified, isActive: $isActive, isVerified: $isVerified, verificationStatus: $verificationStatus, lastActivity: $lastActivity, dateJoined: $dateJoined, lastLogin: $lastLogin, isBanned: $isBanned, profilePicture: $profilePicture, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String username, String? firstName, String? lastName, String role, String? phoneNumber, bool phoneVerified, bool isActive, bool isVerified, String verificationStatus, String? lastActivity, String? dateJoined, String? lastLogin, bool isBanned, String? profilePicture, Profile? profile
});


$ProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? role = null,Object? phoneNumber = freezed,Object? phoneVerified = null,Object? isActive = null,Object? isVerified = null,Object? verificationStatus = null,Object? lastActivity = freezed,Object? dateJoined = freezed,Object? lastLogin = freezed,Object? isBanned = null,Object? profilePicture = freezed,Object? profile = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as String?,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as String?,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String username,  String? firstName,  String? lastName,  String role,  String? phoneNumber,  bool phoneVerified,  bool isActive,  bool isVerified,  String verificationStatus,  String? lastActivity,  String? dateJoined,  String? lastLogin,  bool isBanned,  String? profilePicture,  Profile? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.role,_that.phoneNumber,_that.phoneVerified,_that.isActive,_that.isVerified,_that.verificationStatus,_that.lastActivity,_that.dateJoined,_that.lastLogin,_that.isBanned,_that.profilePicture,_that.profile);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String username,  String? firstName,  String? lastName,  String role,  String? phoneNumber,  bool phoneVerified,  bool isActive,  bool isVerified,  String verificationStatus,  String? lastActivity,  String? dateJoined,  String? lastLogin,  bool isBanned,  String? profilePicture,  Profile? profile)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.role,_that.phoneNumber,_that.phoneVerified,_that.isActive,_that.isVerified,_that.verificationStatus,_that.lastActivity,_that.dateJoined,_that.lastLogin,_that.isBanned,_that.profilePicture,_that.profile);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String username,  String? firstName,  String? lastName,  String role,  String? phoneNumber,  bool phoneVerified,  bool isActive,  bool isVerified,  String verificationStatus,  String? lastActivity,  String? dateJoined,  String? lastLogin,  bool isBanned,  String? profilePicture,  Profile? profile)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.role,_that.phoneNumber,_that.phoneVerified,_that.isActive,_that.isVerified,_that.verificationStatus,_that.lastActivity,_that.dateJoined,_that.lastLogin,_that.isBanned,_that.profilePicture,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.email, required this.username, this.firstName, this.lastName, this.role = 'student', this.phoneNumber, this.phoneVerified = false, this.isActive = false, this.isVerified = false, this.verificationStatus = 'pending', this.lastActivity, this.dateJoined, this.lastLogin, this.isBanned = false, this.profilePicture, this.profile});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String username;
@override final  String? firstName;
@override final  String? lastName;
@override@JsonKey() final  String role;
@override final  String? phoneNumber;
@override@JsonKey() final  bool phoneVerified;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  String verificationStatus;
@override final  String? lastActivity;
@override final  String? dateJoined;
@override final  String? lastLogin;
@override@JsonKey() final  bool isBanned;
@override final  String? profilePicture;
@override final  Profile? profile;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.role, role) || other.role == role)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.dateJoined, dateJoined) || other.dateJoined == dateJoined)&&(identical(other.lastLogin, lastLogin) || other.lastLogin == lastLogin)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,firstName,lastName,role,phoneNumber,phoneVerified,isActive,isVerified,verificationStatus,lastActivity,dateJoined,lastLogin,isBanned,profilePicture,profile);

@override
String toString() {
  return 'User(id: $id, email: $email, username: $username, firstName: $firstName, lastName: $lastName, role: $role, phoneNumber: $phoneNumber, phoneVerified: $phoneVerified, isActive: $isActive, isVerified: $isVerified, verificationStatus: $verificationStatus, lastActivity: $lastActivity, dateJoined: $dateJoined, lastLogin: $lastLogin, isBanned: $isBanned, profilePicture: $profilePicture, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String username, String? firstName, String? lastName, String role, String? phoneNumber, bool phoneVerified, bool isActive, bool isVerified, String verificationStatus, String? lastActivity, String? dateJoined, String? lastLogin, bool isBanned, String? profilePicture, Profile? profile
});


@override $ProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? role = null,Object? phoneNumber = freezed,Object? phoneVerified = null,Object? isActive = null,Object? isVerified = null,Object? verificationStatus = null,Object? lastActivity = freezed,Object? dateJoined = freezed,Object? lastLogin = freezed,Object? isBanned = null,Object? profilePicture = freezed,Object? profile = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as String?,dateJoined: freezed == dateJoined ? _self.dateJoined : dateJoined // ignore: cast_nullable_to_non_nullable
as String?,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as String?,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$Profile {

 String? get id; String? get university; String? get universityId; String? get campus; String? get campusId; String? get department; String? get departmentId; String? get fieldOfStudy; String? get academicYear; String? get academicYearId; String? get bio; String? get profilePicture; String? get coverPicture; String? get dateOfBirth; List<String>? get interests; String? get website; String? get facebook; String? get instagram; String? get twitter; int get followersCount; int get followingCount; int get friendsCount; String? get universityEmail; bool get emailVerified; String? get studentId; String? get verificationMethod; int get reputationScore; String? get createdAt; String? get updatedAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.university, university) || other.university == university)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.campus, campus) || other.campus == campus)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.department, department) || other.department == department)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.fieldOfStudy, fieldOfStudy) || other.fieldOfStudy == fieldOfStudy)&&(identical(other.academicYear, academicYear) || other.academicYear == academicYear)&&(identical(other.academicYearId, academicYearId) || other.academicYearId == academicYearId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.coverPicture, coverPicture) || other.coverPicture == coverPicture)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&const DeepCollectionEquality().equals(other.interests, interests)&&(identical(other.website, website) || other.website == website)&&(identical(other.facebook, facebook) || other.facebook == facebook)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.twitter, twitter) || other.twitter == twitter)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.friendsCount, friendsCount) || other.friendsCount == friendsCount)&&(identical(other.universityEmail, universityEmail) || other.universityEmail == universityEmail)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&(identical(other.reputationScore, reputationScore) || other.reputationScore == reputationScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,university,universityId,campus,campusId,department,departmentId,fieldOfStudy,academicYear,academicYearId,bio,profilePicture,coverPicture,dateOfBirth,const DeepCollectionEquality().hash(interests),website,facebook,instagram,twitter,followersCount,followingCount,friendsCount,universityEmail,emailVerified,studentId,verificationMethod,reputationScore,createdAt,updatedAt]);

@override
String toString() {
  return 'Profile(id: $id, university: $university, universityId: $universityId, campus: $campus, campusId: $campusId, department: $department, departmentId: $departmentId, fieldOfStudy: $fieldOfStudy, academicYear: $academicYear, academicYearId: $academicYearId, bio: $bio, profilePicture: $profilePicture, coverPicture: $coverPicture, dateOfBirth: $dateOfBirth, interests: $interests, website: $website, facebook: $facebook, instagram: $instagram, twitter: $twitter, followersCount: $followersCount, followingCount: $followingCount, friendsCount: $friendsCount, universityEmail: $universityEmail, emailVerified: $emailVerified, studentId: $studentId, verificationMethod: $verificationMethod, reputationScore: $reputationScore, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String? id, String? university, String? universityId, String? campus, String? campusId, String? department, String? departmentId, String? fieldOfStudy, String? academicYear, String? academicYearId, String? bio, String? profilePicture, String? coverPicture, String? dateOfBirth, List<String>? interests, String? website, String? facebook, String? instagram, String? twitter, int followersCount, int followingCount, int friendsCount, String? universityEmail, bool emailVerified, String? studentId, String? verificationMethod, int reputationScore, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? university = freezed,Object? universityId = freezed,Object? campus = freezed,Object? campusId = freezed,Object? department = freezed,Object? departmentId = freezed,Object? fieldOfStudy = freezed,Object? academicYear = freezed,Object? academicYearId = freezed,Object? bio = freezed,Object? profilePicture = freezed,Object? coverPicture = freezed,Object? dateOfBirth = freezed,Object? interests = freezed,Object? website = freezed,Object? facebook = freezed,Object? instagram = freezed,Object? twitter = freezed,Object? followersCount = null,Object? followingCount = null,Object? friendsCount = null,Object? universityEmail = freezed,Object? emailVerified = null,Object? studentId = freezed,Object? verificationMethod = freezed,Object? reputationScore = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,campus: freezed == campus ? _self.campus : campus // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,fieldOfStudy: freezed == fieldOfStudy ? _self.fieldOfStudy : fieldOfStudy // ignore: cast_nullable_to_non_nullable
as String?,academicYear: freezed == academicYear ? _self.academicYear : academicYear // ignore: cast_nullable_to_non_nullable
as String?,academicYearId: freezed == academicYearId ? _self.academicYearId : academicYearId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,coverPicture: freezed == coverPicture ? _self.coverPicture : coverPicture // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,interests: freezed == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,facebook: freezed == facebook ? _self.facebook : facebook // ignore: cast_nullable_to_non_nullable
as String?,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String?,twitter: freezed == twitter ? _self.twitter : twitter // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,friendsCount: null == friendsCount ? _self.friendsCount : friendsCount // ignore: cast_nullable_to_non_nullable
as int,universityEmail: freezed == universityEmail ? _self.universityEmail : universityEmail // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,verificationMethod: freezed == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String?,reputationScore: null == reputationScore ? _self.reputationScore : reputationScore // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? university,  String? universityId,  String? campus,  String? campusId,  String? department,  String? departmentId,  String? fieldOfStudy,  String? academicYear,  String? academicYearId,  String? bio,  String? profilePicture,  String? coverPicture,  String? dateOfBirth,  List<String>? interests,  String? website,  String? facebook,  String? instagram,  String? twitter,  int followersCount,  int followingCount,  int friendsCount,  String? universityEmail,  bool emailVerified,  String? studentId,  String? verificationMethod,  int reputationScore,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.university,_that.universityId,_that.campus,_that.campusId,_that.department,_that.departmentId,_that.fieldOfStudy,_that.academicYear,_that.academicYearId,_that.bio,_that.profilePicture,_that.coverPicture,_that.dateOfBirth,_that.interests,_that.website,_that.facebook,_that.instagram,_that.twitter,_that.followersCount,_that.followingCount,_that.friendsCount,_that.universityEmail,_that.emailVerified,_that.studentId,_that.verificationMethod,_that.reputationScore,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? university,  String? universityId,  String? campus,  String? campusId,  String? department,  String? departmentId,  String? fieldOfStudy,  String? academicYear,  String? academicYearId,  String? bio,  String? profilePicture,  String? coverPicture,  String? dateOfBirth,  List<String>? interests,  String? website,  String? facebook,  String? instagram,  String? twitter,  int followersCount,  int followingCount,  int friendsCount,  String? universityEmail,  bool emailVerified,  String? studentId,  String? verificationMethod,  int reputationScore,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.university,_that.universityId,_that.campus,_that.campusId,_that.department,_that.departmentId,_that.fieldOfStudy,_that.academicYear,_that.academicYearId,_that.bio,_that.profilePicture,_that.coverPicture,_that.dateOfBirth,_that.interests,_that.website,_that.facebook,_that.instagram,_that.twitter,_that.followersCount,_that.followingCount,_that.friendsCount,_that.universityEmail,_that.emailVerified,_that.studentId,_that.verificationMethod,_that.reputationScore,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? university,  String? universityId,  String? campus,  String? campusId,  String? department,  String? departmentId,  String? fieldOfStudy,  String? academicYear,  String? academicYearId,  String? bio,  String? profilePicture,  String? coverPicture,  String? dateOfBirth,  List<String>? interests,  String? website,  String? facebook,  String? instagram,  String? twitter,  int followersCount,  int followingCount,  int friendsCount,  String? universityEmail,  bool emailVerified,  String? studentId,  String? verificationMethod,  int reputationScore,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.university,_that.universityId,_that.campus,_that.campusId,_that.department,_that.departmentId,_that.fieldOfStudy,_that.academicYear,_that.academicYearId,_that.bio,_that.profilePicture,_that.coverPicture,_that.dateOfBirth,_that.interests,_that.website,_that.facebook,_that.instagram,_that.twitter,_that.followersCount,_that.followingCount,_that.friendsCount,_that.universityEmail,_that.emailVerified,_that.studentId,_that.verificationMethod,_that.reputationScore,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({this.id, this.university, this.universityId, this.campus, this.campusId, this.department, this.departmentId, this.fieldOfStudy, this.academicYear, this.academicYearId, this.bio, this.profilePicture, this.coverPicture, this.dateOfBirth, final  List<String>? interests, this.website, this.facebook, this.instagram, this.twitter, this.followersCount = 0, this.followingCount = 0, this.friendsCount = 0, this.universityEmail, this.emailVerified = false, this.studentId, this.verificationMethod, this.reputationScore = 0, this.createdAt, this.updatedAt}): _interests = interests;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String? id;
@override final  String? university;
@override final  String? universityId;
@override final  String? campus;
@override final  String? campusId;
@override final  String? department;
@override final  String? departmentId;
@override final  String? fieldOfStudy;
@override final  String? academicYear;
@override final  String? academicYearId;
@override final  String? bio;
@override final  String? profilePicture;
@override final  String? coverPicture;
@override final  String? dateOfBirth;
 final  List<String>? _interests;
@override List<String>? get interests {
  final value = _interests;
  if (value == null) return null;
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? website;
@override final  String? facebook;
@override final  String? instagram;
@override final  String? twitter;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followingCount;
@override@JsonKey() final  int friendsCount;
@override final  String? universityEmail;
@override@JsonKey() final  bool emailVerified;
@override final  String? studentId;
@override final  String? verificationMethod;
@override@JsonKey() final  int reputationScore;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.university, university) || other.university == university)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.campus, campus) || other.campus == campus)&&(identical(other.campusId, campusId) || other.campusId == campusId)&&(identical(other.department, department) || other.department == department)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.fieldOfStudy, fieldOfStudy) || other.fieldOfStudy == fieldOfStudy)&&(identical(other.academicYear, academicYear) || other.academicYear == academicYear)&&(identical(other.academicYearId, academicYearId) || other.academicYearId == academicYearId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.coverPicture, coverPicture) || other.coverPicture == coverPicture)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&const DeepCollectionEquality().equals(other._interests, _interests)&&(identical(other.website, website) || other.website == website)&&(identical(other.facebook, facebook) || other.facebook == facebook)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.twitter, twitter) || other.twitter == twitter)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.friendsCount, friendsCount) || other.friendsCount == friendsCount)&&(identical(other.universityEmail, universityEmail) || other.universityEmail == universityEmail)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&(identical(other.reputationScore, reputationScore) || other.reputationScore == reputationScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,university,universityId,campus,campusId,department,departmentId,fieldOfStudy,academicYear,academicYearId,bio,profilePicture,coverPicture,dateOfBirth,const DeepCollectionEquality().hash(_interests),website,facebook,instagram,twitter,followersCount,followingCount,friendsCount,universityEmail,emailVerified,studentId,verificationMethod,reputationScore,createdAt,updatedAt]);

@override
String toString() {
  return 'Profile(id: $id, university: $university, universityId: $universityId, campus: $campus, campusId: $campusId, department: $department, departmentId: $departmentId, fieldOfStudy: $fieldOfStudy, academicYear: $academicYear, academicYearId: $academicYearId, bio: $bio, profilePicture: $profilePicture, coverPicture: $coverPicture, dateOfBirth: $dateOfBirth, interests: $interests, website: $website, facebook: $facebook, instagram: $instagram, twitter: $twitter, followersCount: $followersCount, followingCount: $followingCount, friendsCount: $friendsCount, universityEmail: $universityEmail, emailVerified: $emailVerified, studentId: $studentId, verificationMethod: $verificationMethod, reputationScore: $reputationScore, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? university, String? universityId, String? campus, String? campusId, String? department, String? departmentId, String? fieldOfStudy, String? academicYear, String? academicYearId, String? bio, String? profilePicture, String? coverPicture, String? dateOfBirth, List<String>? interests, String? website, String? facebook, String? instagram, String? twitter, int followersCount, int followingCount, int friendsCount, String? universityEmail, bool emailVerified, String? studentId, String? verificationMethod, int reputationScore, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? university = freezed,Object? universityId = freezed,Object? campus = freezed,Object? campusId = freezed,Object? department = freezed,Object? departmentId = freezed,Object? fieldOfStudy = freezed,Object? academicYear = freezed,Object? academicYearId = freezed,Object? bio = freezed,Object? profilePicture = freezed,Object? coverPicture = freezed,Object? dateOfBirth = freezed,Object? interests = freezed,Object? website = freezed,Object? facebook = freezed,Object? instagram = freezed,Object? twitter = freezed,Object? followersCount = null,Object? followingCount = null,Object? friendsCount = null,Object? universityEmail = freezed,Object? emailVerified = null,Object? studentId = freezed,Object? verificationMethod = freezed,Object? reputationScore = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Profile(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,campus: freezed == campus ? _self.campus : campus // ignore: cast_nullable_to_non_nullable
as String?,campusId: freezed == campusId ? _self.campusId : campusId // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as String?,fieldOfStudy: freezed == fieldOfStudy ? _self.fieldOfStudy : fieldOfStudy // ignore: cast_nullable_to_non_nullable
as String?,academicYear: freezed == academicYear ? _self.academicYear : academicYear // ignore: cast_nullable_to_non_nullable
as String?,academicYearId: freezed == academicYearId ? _self.academicYearId : academicYearId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,coverPicture: freezed == coverPicture ? _self.coverPicture : coverPicture // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,interests: freezed == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,facebook: freezed == facebook ? _self.facebook : facebook // ignore: cast_nullable_to_non_nullable
as String?,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String?,twitter: freezed == twitter ? _self.twitter : twitter // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,friendsCount: null == friendsCount ? _self.friendsCount : friendsCount // ignore: cast_nullable_to_non_nullable
as int,universityEmail: freezed == universityEmail ? _self.universityEmail : universityEmail // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,verificationMethod: freezed == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String?,reputationScore: null == reputationScore ? _self.reputationScore : reputationScore // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$University {

 String get id; String get name; String? get slug; String? get shortName; List<String>? get emailDomains; String? get logo; String? get coverImage; String? get description; String? get website; String? get address; String? get phone; bool get isActive; String? get createdAt; String? get updatedAt; int get studentsCount; int get groupsCount; Map<String, dynamic>? get admin; Map<String, dynamic>? get settings;
/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UniversityCopyWith<University> get copyWith => _$UniversityCopyWithImpl<University>(this as University, _$identity);

  /// Serializes this University to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is University&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&const DeepCollectionEquality().equals(other.emailDomains, emailDomains)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.description, description) || other.description == description)&&(identical(other.website, website) || other.website == website)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.studentsCount, studentsCount) || other.studentsCount == studentsCount)&&(identical(other.groupsCount, groupsCount) || other.groupsCount == groupsCount)&&const DeepCollectionEquality().equals(other.admin, admin)&&const DeepCollectionEquality().equals(other.settings, settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,shortName,const DeepCollectionEquality().hash(emailDomains),logo,coverImage,description,website,address,phone,isActive,createdAt,updatedAt,studentsCount,groupsCount,const DeepCollectionEquality().hash(admin),const DeepCollectionEquality().hash(settings));

@override
String toString() {
  return 'University(id: $id, name: $name, slug: $slug, shortName: $shortName, emailDomains: $emailDomains, logo: $logo, coverImage: $coverImage, description: $description, website: $website, address: $address, phone: $phone, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, studentsCount: $studentsCount, groupsCount: $groupsCount, admin: $admin, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $UniversityCopyWith<$Res>  {
  factory $UniversityCopyWith(University value, $Res Function(University) _then) = _$UniversityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? slug, String? shortName, List<String>? emailDomains, String? logo, String? coverImage, String? description, String? website, String? address, String? phone, bool isActive, String? createdAt, String? updatedAt, int studentsCount, int groupsCount, Map<String, dynamic>? admin, Map<String, dynamic>? settings
});




}
/// @nodoc
class _$UniversityCopyWithImpl<$Res>
    implements $UniversityCopyWith<$Res> {
  _$UniversityCopyWithImpl(this._self, this._then);

  final University _self;
  final $Res Function(University) _then;

/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? shortName = freezed,Object? emailDomains = freezed,Object? logo = freezed,Object? coverImage = freezed,Object? description = freezed,Object? website = freezed,Object? address = freezed,Object? phone = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? studentsCount = null,Object? groupsCount = null,Object? admin = freezed,Object? settings = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,emailDomains: freezed == emailDomains ? _self.emailDomains : emailDomains // ignore: cast_nullable_to_non_nullable
as List<String>?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,studentsCount: null == studentsCount ? _self.studentsCount : studentsCount // ignore: cast_nullable_to_non_nullable
as int,groupsCount: null == groupsCount ? _self.groupsCount : groupsCount // ignore: cast_nullable_to_non_nullable
as int,admin: freezed == admin ? _self.admin : admin // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [University].
extension UniversityPatterns on University {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _University value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _University() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _University value)  $default,){
final _that = this;
switch (_that) {
case _University():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _University value)?  $default,){
final _that = this;
switch (_that) {
case _University() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? shortName,  List<String>? emailDomains,  String? logo,  String? coverImage,  String? description,  String? website,  String? address,  String? phone,  bool isActive,  String? createdAt,  String? updatedAt,  int studentsCount,  int groupsCount,  Map<String, dynamic>? admin,  Map<String, dynamic>? settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _University() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.shortName,_that.emailDomains,_that.logo,_that.coverImage,_that.description,_that.website,_that.address,_that.phone,_that.isActive,_that.createdAt,_that.updatedAt,_that.studentsCount,_that.groupsCount,_that.admin,_that.settings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? shortName,  List<String>? emailDomains,  String? logo,  String? coverImage,  String? description,  String? website,  String? address,  String? phone,  bool isActive,  String? createdAt,  String? updatedAt,  int studentsCount,  int groupsCount,  Map<String, dynamic>? admin,  Map<String, dynamic>? settings)  $default,) {final _that = this;
switch (_that) {
case _University():
return $default(_that.id,_that.name,_that.slug,_that.shortName,_that.emailDomains,_that.logo,_that.coverImage,_that.description,_that.website,_that.address,_that.phone,_that.isActive,_that.createdAt,_that.updatedAt,_that.studentsCount,_that.groupsCount,_that.admin,_that.settings);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? slug,  String? shortName,  List<String>? emailDomains,  String? logo,  String? coverImage,  String? description,  String? website,  String? address,  String? phone,  bool isActive,  String? createdAt,  String? updatedAt,  int studentsCount,  int groupsCount,  Map<String, dynamic>? admin,  Map<String, dynamic>? settings)?  $default,) {final _that = this;
switch (_that) {
case _University() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.shortName,_that.emailDomains,_that.logo,_that.coverImage,_that.description,_that.website,_that.address,_that.phone,_that.isActive,_that.createdAt,_that.updatedAt,_that.studentsCount,_that.groupsCount,_that.admin,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _University implements University {
  const _University({required this.id, required this.name, this.slug, this.shortName, final  List<String>? emailDomains, this.logo, this.coverImage, this.description, this.website, this.address, this.phone, this.isActive = true, this.createdAt, this.updatedAt, this.studentsCount = 0, this.groupsCount = 0, final  Map<String, dynamic>? admin, final  Map<String, dynamic>? settings}): _emailDomains = emailDomains,_admin = admin,_settings = settings;
  factory _University.fromJson(Map<String, dynamic> json) => _$UniversityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? slug;
@override final  String? shortName;
 final  List<String>? _emailDomains;
@override List<String>? get emailDomains {
  final value = _emailDomains;
  if (value == null) return null;
  if (_emailDomains is EqualUnmodifiableListView) return _emailDomains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? logo;
@override final  String? coverImage;
@override final  String? description;
@override final  String? website;
@override final  String? address;
@override final  String? phone;
@override@JsonKey() final  bool isActive;
@override final  String? createdAt;
@override final  String? updatedAt;
@override@JsonKey() final  int studentsCount;
@override@JsonKey() final  int groupsCount;
 final  Map<String, dynamic>? _admin;
@override Map<String, dynamic>? get admin {
  final value = _admin;
  if (value == null) return null;
  if (_admin is EqualUnmodifiableMapView) return _admin;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _settings;
@override Map<String, dynamic>? get settings {
  final value = _settings;
  if (value == null) return null;
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UniversityCopyWith<_University> get copyWith => __$UniversityCopyWithImpl<_University>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UniversityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _University&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&const DeepCollectionEquality().equals(other._emailDomains, _emailDomains)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.description, description) || other.description == description)&&(identical(other.website, website) || other.website == website)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.studentsCount, studentsCount) || other.studentsCount == studentsCount)&&(identical(other.groupsCount, groupsCount) || other.groupsCount == groupsCount)&&const DeepCollectionEquality().equals(other._admin, _admin)&&const DeepCollectionEquality().equals(other._settings, _settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,shortName,const DeepCollectionEquality().hash(_emailDomains),logo,coverImage,description,website,address,phone,isActive,createdAt,updatedAt,studentsCount,groupsCount,const DeepCollectionEquality().hash(_admin),const DeepCollectionEquality().hash(_settings));

@override
String toString() {
  return 'University(id: $id, name: $name, slug: $slug, shortName: $shortName, emailDomains: $emailDomains, logo: $logo, coverImage: $coverImage, description: $description, website: $website, address: $address, phone: $phone, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, studentsCount: $studentsCount, groupsCount: $groupsCount, admin: $admin, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$UniversityCopyWith<$Res> implements $UniversityCopyWith<$Res> {
  factory _$UniversityCopyWith(_University value, $Res Function(_University) _then) = __$UniversityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? slug, String? shortName, List<String>? emailDomains, String? logo, String? coverImage, String? description, String? website, String? address, String? phone, bool isActive, String? createdAt, String? updatedAt, int studentsCount, int groupsCount, Map<String, dynamic>? admin, Map<String, dynamic>? settings
});




}
/// @nodoc
class __$UniversityCopyWithImpl<$Res>
    implements _$UniversityCopyWith<$Res> {
  __$UniversityCopyWithImpl(this._self, this._then);

  final _University _self;
  final $Res Function(_University) _then;

/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? shortName = freezed,Object? emailDomains = freezed,Object? logo = freezed,Object? coverImage = freezed,Object? description = freezed,Object? website = freezed,Object? address = freezed,Object? phone = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? studentsCount = null,Object? groupsCount = null,Object? admin = freezed,Object? settings = freezed,}) {
  return _then(_University(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,emailDomains: freezed == emailDomains ? _self._emailDomains : emailDomains // ignore: cast_nullable_to_non_nullable
as List<String>?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,studentsCount: null == studentsCount ? _self.studentsCount : studentsCount // ignore: cast_nullable_to_non_nullable
as int,groupsCount: null == groupsCount ? _self.groupsCount : groupsCount // ignore: cast_nullable_to_non_nullable
as int,admin: freezed == admin ? _self._admin : admin // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,settings: freezed == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$Campus {

 String get id; String get name; String? get slug; String? get universityId; String? get universityName; String? get address; String? get city; String? get country; String? get phone; String? get email; String? get image; bool get isMain; bool get isActive; double? get latitude; double? get longitude; String? get createdAt; String? get updatedAt;
/// Create a copy of Campus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampusCopyWith<Campus> get copyWith => _$CampusCopyWithImpl<Campus>(this as Campus, _$identity);

  /// Serializes this Campus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Campus&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.image, image) || other.image == image)&&(identical(other.isMain, isMain) || other.isMain == isMain)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,universityId,universityName,address,city,country,phone,email,image,isMain,isActive,latitude,longitude,createdAt,updatedAt);

@override
String toString() {
  return 'Campus(id: $id, name: $name, slug: $slug, universityId: $universityId, universityName: $universityName, address: $address, city: $city, country: $country, phone: $phone, email: $email, image: $image, isMain: $isMain, isActive: $isActive, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CampusCopyWith<$Res>  {
  factory $CampusCopyWith(Campus value, $Res Function(Campus) _then) = _$CampusCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? slug, String? universityId, String? universityName, String? address, String? city, String? country, String? phone, String? email, String? image, bool isMain, bool isActive, double? latitude, double? longitude, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$CampusCopyWithImpl<$Res>
    implements $CampusCopyWith<$Res> {
  _$CampusCopyWithImpl(this._self, this._then);

  final Campus _self;
  final $Res Function(Campus) _then;

/// Create a copy of Campus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? universityId = freezed,Object? universityName = freezed,Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? phone = freezed,Object? email = freezed,Object? image = freezed,Object? isMain = null,Object? isActive = null,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,isMain: null == isMain ? _self.isMain : isMain // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Campus].
extension CampusPatterns on Campus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Campus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Campus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Campus value)  $default,){
final _that = this;
switch (_that) {
case _Campus():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Campus value)?  $default,){
final _that = this;
switch (_that) {
case _Campus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? universityId,  String? universityName,  String? address,  String? city,  String? country,  String? phone,  String? email,  String? image,  bool isMain,  bool isActive,  double? latitude,  double? longitude,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Campus() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.universityId,_that.universityName,_that.address,_that.city,_that.country,_that.phone,_that.email,_that.image,_that.isMain,_that.isActive,_that.latitude,_that.longitude,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? universityId,  String? universityName,  String? address,  String? city,  String? country,  String? phone,  String? email,  String? image,  bool isMain,  bool isActive,  double? latitude,  double? longitude,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Campus():
return $default(_that.id,_that.name,_that.slug,_that.universityId,_that.universityName,_that.address,_that.city,_that.country,_that.phone,_that.email,_that.image,_that.isMain,_that.isActive,_that.latitude,_that.longitude,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? slug,  String? universityId,  String? universityName,  String? address,  String? city,  String? country,  String? phone,  String? email,  String? image,  bool isMain,  bool isActive,  double? latitude,  double? longitude,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Campus() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.universityId,_that.universityName,_that.address,_that.city,_that.country,_that.phone,_that.email,_that.image,_that.isMain,_that.isActive,_that.latitude,_that.longitude,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Campus implements Campus {
  const _Campus({required this.id, required this.name, this.slug, this.universityId, this.universityName, this.address, this.city, this.country, this.phone, this.email, this.image, this.isMain = false, this.isActive = true, this.latitude, this.longitude, this.createdAt, this.updatedAt});
  factory _Campus.fromJson(Map<String, dynamic> json) => _$CampusFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? slug;
@override final  String? universityId;
@override final  String? universityName;
@override final  String? address;
@override final  String? city;
@override final  String? country;
@override final  String? phone;
@override final  String? email;
@override final  String? image;
@override@JsonKey() final  bool isMain;
@override@JsonKey() final  bool isActive;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Campus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampusCopyWith<_Campus> get copyWith => __$CampusCopyWithImpl<_Campus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Campus&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.image, image) || other.image == image)&&(identical(other.isMain, isMain) || other.isMain == isMain)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,universityId,universityName,address,city,country,phone,email,image,isMain,isActive,latitude,longitude,createdAt,updatedAt);

@override
String toString() {
  return 'Campus(id: $id, name: $name, slug: $slug, universityId: $universityId, universityName: $universityName, address: $address, city: $city, country: $country, phone: $phone, email: $email, image: $image, isMain: $isMain, isActive: $isActive, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CampusCopyWith<$Res> implements $CampusCopyWith<$Res> {
  factory _$CampusCopyWith(_Campus value, $Res Function(_Campus) _then) = __$CampusCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? slug, String? universityId, String? universityName, String? address, String? city, String? country, String? phone, String? email, String? image, bool isMain, bool isActive, double? latitude, double? longitude, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$CampusCopyWithImpl<$Res>
    implements _$CampusCopyWith<$Res> {
  __$CampusCopyWithImpl(this._self, this._then);

  final _Campus _self;
  final $Res Function(_Campus) _then;

/// Create a copy of Campus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? universityId = freezed,Object? universityName = freezed,Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? phone = freezed,Object? email = freezed,Object? image = freezed,Object? isMain = null,Object? isActive = null,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Campus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,isMain: null == isMain ? _self.isMain : isMain // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Department {

 String get id; String get name; String? get slug; String? get universityId; String? get code; String? get description; bool get isActive; String? get createdAt; String? get updatedAt;
/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepartmentCopyWith<Department> get copyWith => _$DepartmentCopyWithImpl<Department>(this as Department, _$identity);

  /// Serializes this Department to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Department&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,universityId,code,description,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Department(id: $id, name: $name, slug: $slug, universityId: $universityId, code: $code, description: $description, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DepartmentCopyWith<$Res>  {
  factory $DepartmentCopyWith(Department value, $Res Function(Department) _then) = _$DepartmentCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? slug, String? universityId, String? code, String? description, bool isActive, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$DepartmentCopyWithImpl<$Res>
    implements $DepartmentCopyWith<$Res> {
  _$DepartmentCopyWithImpl(this._self, this._then);

  final Department _self;
  final $Res Function(Department) _then;

/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? universityId = freezed,Object? code = freezed,Object? description = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Department].
extension DepartmentPatterns on Department {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Department value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Department() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Department value)  $default,){
final _that = this;
switch (_that) {
case _Department():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Department value)?  $default,){
final _that = this;
switch (_that) {
case _Department() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? universityId,  String? code,  String? description,  bool isActive,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Department() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.universityId,_that.code,_that.description,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String? universityId,  String? code,  String? description,  bool isActive,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Department():
return $default(_that.id,_that.name,_that.slug,_that.universityId,_that.code,_that.description,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? slug,  String? universityId,  String? code,  String? description,  bool isActive,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Department() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.universityId,_that.code,_that.description,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Department implements Department {
  const _Department({required this.id, required this.name, this.slug, this.universityId, this.code, this.description, this.isActive = true, this.createdAt, this.updatedAt});
  factory _Department.fromJson(Map<String, dynamic> json) => _$DepartmentFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? slug;
@override final  String? universityId;
@override final  String? code;
@override final  String? description;
@override@JsonKey() final  bool isActive;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepartmentCopyWith<_Department> get copyWith => __$DepartmentCopyWithImpl<_Department>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepartmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Department&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,universityId,code,description,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Department(id: $id, name: $name, slug: $slug, universityId: $universityId, code: $code, description: $description, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DepartmentCopyWith<$Res> implements $DepartmentCopyWith<$Res> {
  factory _$DepartmentCopyWith(_Department value, $Res Function(_Department) _then) = __$DepartmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? slug, String? universityId, String? code, String? description, bool isActive, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$DepartmentCopyWithImpl<$Res>
    implements _$DepartmentCopyWith<$Res> {
  __$DepartmentCopyWithImpl(this._self, this._then);

  final _Department _self;
  final $Res Function(_Department) _then;

/// Create a copy of Department
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? universityId = freezed,Object? code = freezed,Object? description = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Department(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Friendship {

 String get id; String get fromUserId; String get toUserId; User? get fromUser; User? get toUser; String get status; String? get createdAt; String? get updatedAt;
/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendshipCopyWith<Friendship> get copyWith => _$FriendshipCopyWithImpl<Friendship>(this as Friendship, _$identity);

  /// Serializes this Friendship to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Friendship&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.fromUser, fromUser) || other.fromUser == fromUser)&&(identical(other.toUser, toUser) || other.toUser == toUser)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,fromUser,toUser,status,createdAt,updatedAt);

@override
String toString() {
  return 'Friendship(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, fromUser: $fromUser, toUser: $toUser, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FriendshipCopyWith<$Res>  {
  factory $FriendshipCopyWith(Friendship value, $Res Function(Friendship) _then) = _$FriendshipCopyWithImpl;
@useResult
$Res call({
 String id, String fromUserId, String toUserId, User? fromUser, User? toUser, String status, String? createdAt, String? updatedAt
});


$UserCopyWith<$Res>? get fromUser;$UserCopyWith<$Res>? get toUser;

}
/// @nodoc
class _$FriendshipCopyWithImpl<$Res>
    implements $FriendshipCopyWith<$Res> {
  _$FriendshipCopyWithImpl(this._self, this._then);

  final Friendship _self;
  final $Res Function(Friendship) _then;

/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? fromUser = freezed,Object? toUser = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,fromUser: freezed == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as User?,toUser: freezed == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as User?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get fromUser {
    if (_self.fromUser == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.fromUser!, (value) {
    return _then(_self.copyWith(fromUser: value));
  });
}/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get toUser {
    if (_self.toUser == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.toUser!, (value) {
    return _then(_self.copyWith(toUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [Friendship].
extension FriendshipPatterns on Friendship {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Friendship value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Friendship value)  $default,){
final _that = this;
switch (_that) {
case _Friendship():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Friendship value)?  $default,){
final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String toUserId,  User? fromUser,  User? toUser,  String status,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.fromUser,_that.toUser,_that.status,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fromUserId,  String toUserId,  User? fromUser,  User? toUser,  String status,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Friendship():
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.fromUser,_that.toUser,_that.status,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fromUserId,  String toUserId,  User? fromUser,  User? toUser,  String status,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Friendship() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.fromUser,_that.toUser,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Friendship implements Friendship {
  const _Friendship({required this.id, required this.fromUserId, required this.toUserId, this.fromUser, this.toUser, this.status = 'pending', this.createdAt, this.updatedAt});
  factory _Friendship.fromJson(Map<String, dynamic> json) => _$FriendshipFromJson(json);

@override final  String id;
@override final  String fromUserId;
@override final  String toUserId;
@override final  User? fromUser;
@override final  User? toUser;
@override@JsonKey() final  String status;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendshipCopyWith<_Friendship> get copyWith => __$FriendshipCopyWithImpl<_Friendship>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendshipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Friendship&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.fromUser, fromUser) || other.fromUser == fromUser)&&(identical(other.toUser, toUser) || other.toUser == toUser)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,fromUser,toUser,status,createdAt,updatedAt);

@override
String toString() {
  return 'Friendship(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, fromUser: $fromUser, toUser: $toUser, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FriendshipCopyWith<$Res> implements $FriendshipCopyWith<$Res> {
  factory _$FriendshipCopyWith(_Friendship value, $Res Function(_Friendship) _then) = __$FriendshipCopyWithImpl;
@override @useResult
$Res call({
 String id, String fromUserId, String toUserId, User? fromUser, User? toUser, String status, String? createdAt, String? updatedAt
});


@override $UserCopyWith<$Res>? get fromUser;@override $UserCopyWith<$Res>? get toUser;

}
/// @nodoc
class __$FriendshipCopyWithImpl<$Res>
    implements _$FriendshipCopyWith<$Res> {
  __$FriendshipCopyWithImpl(this._self, this._then);

  final _Friendship _self;
  final $Res Function(_Friendship) _then;

/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? fromUser = freezed,Object? toUser = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Friendship(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,fromUser: freezed == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as User?,toUser: freezed == toUser ? _self.toUser : toUser // ignore: cast_nullable_to_non_nullable
as User?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get fromUser {
    if (_self.fromUser == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.fromUser!, (value) {
    return _then(_self.copyWith(fromUser: value));
  });
}/// Create a copy of Friendship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get toUser {
    if (_self.toUser == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.toUser!, (value) {
    return _then(_self.copyWith(toUser: value));
  });
}
}


/// @nodoc
mixin _$AuthTokens {

 String get access; String get refresh; String? get userId; String? get email; String? get username; String? get firstName; String? get lastName; String? get role; bool? get isStaff; bool? get isSuperuser;
/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<AuthTokens> get copyWith => _$AuthTokensCopyWithImpl<AuthTokens>(this as AuthTokens, _$identity);

  /// Serializes this AuthTokens to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthTokens&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.role, role) || other.role == role)&&(identical(other.isStaff, isStaff) || other.isStaff == isStaff)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh,userId,email,username,firstName,lastName,role,isStaff,isSuperuser);

@override
String toString() {
  return 'AuthTokens(access: $access, refresh: $refresh, userId: $userId, email: $email, username: $username, firstName: $firstName, lastName: $lastName, role: $role, isStaff: $isStaff, isSuperuser: $isSuperuser)';
}


}

/// @nodoc
abstract mixin class $AuthTokensCopyWith<$Res>  {
  factory $AuthTokensCopyWith(AuthTokens value, $Res Function(AuthTokens) _then) = _$AuthTokensCopyWithImpl;
@useResult
$Res call({
 String access, String refresh, String? userId, String? email, String? username, String? firstName, String? lastName, String? role, bool? isStaff, bool? isSuperuser
});




}
/// @nodoc
class _$AuthTokensCopyWithImpl<$Res>
    implements $AuthTokensCopyWith<$Res> {
  _$AuthTokensCopyWithImpl(this._self, this._then);

  final AuthTokens _self;
  final $Res Function(AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? access = null,Object? refresh = null,Object? userId = freezed,Object? email = freezed,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? role = freezed,Object? isStaff = freezed,Object? isSuperuser = freezed,}) {
  return _then(_self.copyWith(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isStaff: freezed == isStaff ? _self.isStaff : isStaff // ignore: cast_nullable_to_non_nullable
as bool?,isSuperuser: freezed == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthTokens].
extension AuthTokensPatterns on AuthTokens {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthTokens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthTokens value)  $default,){
final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthTokens value)?  $default,){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String access,  String refresh,  String? userId,  String? email,  String? username,  String? firstName,  String? lastName,  String? role,  bool? isStaff,  bool? isSuperuser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.access,_that.refresh,_that.userId,_that.email,_that.username,_that.firstName,_that.lastName,_that.role,_that.isStaff,_that.isSuperuser);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String access,  String refresh,  String? userId,  String? email,  String? username,  String? firstName,  String? lastName,  String? role,  bool? isStaff,  bool? isSuperuser)  $default,) {final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that.access,_that.refresh,_that.userId,_that.email,_that.username,_that.firstName,_that.lastName,_that.role,_that.isStaff,_that.isSuperuser);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String access,  String refresh,  String? userId,  String? email,  String? username,  String? firstName,  String? lastName,  String? role,  bool? isStaff,  bool? isSuperuser)?  $default,) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.access,_that.refresh,_that.userId,_that.email,_that.username,_that.firstName,_that.lastName,_that.role,_that.isStaff,_that.isSuperuser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthTokens implements AuthTokens {
  const _AuthTokens({required this.access, required this.refresh, this.userId, this.email, this.username, this.firstName, this.lastName, this.role, this.isStaff, this.isSuperuser});
  factory _AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);

@override final  String access;
@override final  String refresh;
@override final  String? userId;
@override final  String? email;
@override final  String? username;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? role;
@override final  bool? isStaff;
@override final  bool? isSuperuser;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthTokensCopyWith<_AuthTokens> get copyWith => __$AuthTokensCopyWithImpl<_AuthTokens>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthTokensToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthTokens&&(identical(other.access, access) || other.access == access)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.role, role) || other.role == role)&&(identical(other.isStaff, isStaff) || other.isStaff == isStaff)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,access,refresh,userId,email,username,firstName,lastName,role,isStaff,isSuperuser);

@override
String toString() {
  return 'AuthTokens(access: $access, refresh: $refresh, userId: $userId, email: $email, username: $username, firstName: $firstName, lastName: $lastName, role: $role, isStaff: $isStaff, isSuperuser: $isSuperuser)';
}


}

/// @nodoc
abstract mixin class _$AuthTokensCopyWith<$Res> implements $AuthTokensCopyWith<$Res> {
  factory _$AuthTokensCopyWith(_AuthTokens value, $Res Function(_AuthTokens) _then) = __$AuthTokensCopyWithImpl;
@override @useResult
$Res call({
 String access, String refresh, String? userId, String? email, String? username, String? firstName, String? lastName, String? role, bool? isStaff, bool? isSuperuser
});




}
/// @nodoc
class __$AuthTokensCopyWithImpl<$Res>
    implements _$AuthTokensCopyWith<$Res> {
  __$AuthTokensCopyWithImpl(this._self, this._then);

  final _AuthTokens _self;
  final $Res Function(_AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? access = null,Object? refresh = null,Object? userId = freezed,Object? email = freezed,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? role = freezed,Object? isStaff = freezed,Object? isSuperuser = freezed,}) {
  return _then(_AuthTokens(
access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as String,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isStaff: freezed == isStaff ? _self.isStaff : isStaff // ignore: cast_nullable_to_non_nullable
as bool?,isSuperuser: freezed == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
