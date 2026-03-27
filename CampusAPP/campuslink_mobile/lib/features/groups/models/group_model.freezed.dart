// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Group {

 String get id; String get name; String? get slug; String get description; String? get profileImage; String? get coverImage; String get creatorId; UserBasic? get creator; String? get universityId; String? get universityName; String? get category; bool get isPublic; bool get isVerified; int get membersCount; int get postsCount; int get eventsCount; Membership? get currentUserMembership; bool get isMember; bool get hasPendingRequest; String? get createdAt; String? get updatedAt;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&(identical(other.category, category) || other.category == category)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.membersCount, membersCount) || other.membersCount == membersCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.eventsCount, eventsCount) || other.eventsCount == eventsCount)&&(identical(other.currentUserMembership, currentUserMembership) || other.currentUserMembership == currentUserMembership)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&(identical(other.hasPendingRequest, hasPendingRequest) || other.hasPendingRequest == hasPendingRequest)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,profileImage,coverImage,creatorId,creator,universityId,universityName,category,isPublic,isVerified,membersCount,postsCount,eventsCount,currentUserMembership,isMember,hasPendingRequest,createdAt,updatedAt]);

@override
String toString() {
  return 'Group(id: $id, name: $name, slug: $slug, description: $description, profileImage: $profileImage, coverImage: $coverImage, creatorId: $creatorId, creator: $creator, universityId: $universityId, universityName: $universityName, category: $category, isPublic: $isPublic, isVerified: $isVerified, membersCount: $membersCount, postsCount: $postsCount, eventsCount: $eventsCount, currentUserMembership: $currentUserMembership, isMember: $isMember, hasPendingRequest: $hasPendingRequest, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? slug, String description, String? profileImage, String? coverImage, String creatorId, UserBasic? creator, String? universityId, String? universityName, String? category, bool isPublic, bool isVerified, int membersCount, int postsCount, int eventsCount, Membership? currentUserMembership, bool isMember, bool hasPendingRequest, String? createdAt, String? updatedAt
});


$UserBasicCopyWith<$Res>? get creator;$MembershipCopyWith<$Res>? get currentUserMembership;

}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? description = null,Object? profileImage = freezed,Object? coverImage = freezed,Object? creatorId = null,Object? creator = freezed,Object? universityId = freezed,Object? universityName = freezed,Object? category = freezed,Object? isPublic = null,Object? isVerified = null,Object? membersCount = null,Object? postsCount = null,Object? eventsCount = null,Object? currentUserMembership = freezed,Object? isMember = null,Object? hasPendingRequest = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as UserBasic?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,membersCount: null == membersCount ? _self.membersCount : membersCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,eventsCount: null == eventsCount ? _self.eventsCount : eventsCount // ignore: cast_nullable_to_non_nullable
as int,currentUserMembership: freezed == currentUserMembership ? _self.currentUserMembership : currentUserMembership // ignore: cast_nullable_to_non_nullable
as Membership?,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,hasPendingRequest: null == hasPendingRequest ? _self.hasPendingRequest : hasPendingRequest // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipCopyWith<$Res>? get currentUserMembership {
    if (_self.currentUserMembership == null) {
    return null;
  }

  return $MembershipCopyWith<$Res>(_self.currentUserMembership!, (value) {
    return _then(_self.copyWith(currentUserMembership: value));
  });
}
}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String description,  String? profileImage,  String? coverImage,  String creatorId,  UserBasic? creator,  String? universityId,  String? universityName,  String? category,  bool isPublic,  bool isVerified,  int membersCount,  int postsCount,  int eventsCount,  Membership? currentUserMembership,  bool isMember,  bool hasPendingRequest,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.profileImage,_that.coverImage,_that.creatorId,_that.creator,_that.universityId,_that.universityName,_that.category,_that.isPublic,_that.isVerified,_that.membersCount,_that.postsCount,_that.eventsCount,_that.currentUserMembership,_that.isMember,_that.hasPendingRequest,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? slug,  String description,  String? profileImage,  String? coverImage,  String creatorId,  UserBasic? creator,  String? universityId,  String? universityName,  String? category,  bool isPublic,  bool isVerified,  int membersCount,  int postsCount,  int eventsCount,  Membership? currentUserMembership,  bool isMember,  bool hasPendingRequest,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.profileImage,_that.coverImage,_that.creatorId,_that.creator,_that.universityId,_that.universityName,_that.category,_that.isPublic,_that.isVerified,_that.membersCount,_that.postsCount,_that.eventsCount,_that.currentUserMembership,_that.isMember,_that.hasPendingRequest,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? slug,  String description,  String? profileImage,  String? coverImage,  String creatorId,  UserBasic? creator,  String? universityId,  String? universityName,  String? category,  bool isPublic,  bool isVerified,  int membersCount,  int postsCount,  int eventsCount,  Membership? currentUserMembership,  bool isMember,  bool hasPendingRequest,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.profileImage,_that.coverImage,_that.creatorId,_that.creator,_that.universityId,_that.universityName,_that.category,_that.isPublic,_that.isVerified,_that.membersCount,_that.postsCount,_that.eventsCount,_that.currentUserMembership,_that.isMember,_that.hasPendingRequest,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Group implements Group {
  const _Group({required this.id, required this.name, this.slug, required this.description, this.profileImage, this.coverImage, required this.creatorId, this.creator, this.universityId, this.universityName, this.category, this.isPublic = true, this.isVerified = false, this.membersCount = 0, this.postsCount = 0, this.eventsCount = 0, this.currentUserMembership, this.isMember = false, this.hasPendingRequest = false, this.createdAt, this.updatedAt});
  factory _Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? slug;
@override final  String description;
@override final  String? profileImage;
@override final  String? coverImage;
@override final  String creatorId;
@override final  UserBasic? creator;
@override final  String? universityId;
@override final  String? universityName;
@override final  String? category;
@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  int membersCount;
@override@JsonKey() final  int postsCount;
@override@JsonKey() final  int eventsCount;
@override final  Membership? currentUserMembership;
@override@JsonKey() final  bool isMember;
@override@JsonKey() final  bool hasPendingRequest;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&(identical(other.category, category) || other.category == category)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.membersCount, membersCount) || other.membersCount == membersCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.eventsCount, eventsCount) || other.eventsCount == eventsCount)&&(identical(other.currentUserMembership, currentUserMembership) || other.currentUserMembership == currentUserMembership)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&(identical(other.hasPendingRequest, hasPendingRequest) || other.hasPendingRequest == hasPendingRequest)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,profileImage,coverImage,creatorId,creator,universityId,universityName,category,isPublic,isVerified,membersCount,postsCount,eventsCount,currentUserMembership,isMember,hasPendingRequest,createdAt,updatedAt]);

@override
String toString() {
  return 'Group(id: $id, name: $name, slug: $slug, description: $description, profileImage: $profileImage, coverImage: $coverImage, creatorId: $creatorId, creator: $creator, universityId: $universityId, universityName: $universityName, category: $category, isPublic: $isPublic, isVerified: $isVerified, membersCount: $membersCount, postsCount: $postsCount, eventsCount: $eventsCount, currentUserMembership: $currentUserMembership, isMember: $isMember, hasPendingRequest: $hasPendingRequest, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? slug, String description, String? profileImage, String? coverImage, String creatorId, UserBasic? creator, String? universityId, String? universityName, String? category, bool isPublic, bool isVerified, int membersCount, int postsCount, int eventsCount, Membership? currentUserMembership, bool isMember, bool hasPendingRequest, String? createdAt, String? updatedAt
});


@override $UserBasicCopyWith<$Res>? get creator;@override $MembershipCopyWith<$Res>? get currentUserMembership;

}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? description = null,Object? profileImage = freezed,Object? coverImage = freezed,Object? creatorId = null,Object? creator = freezed,Object? universityId = freezed,Object? universityName = freezed,Object? category = freezed,Object? isPublic = null,Object? isVerified = null,Object? membersCount = null,Object? postsCount = null,Object? eventsCount = null,Object? currentUserMembership = freezed,Object? isMember = null,Object? hasPendingRequest = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,profileImage: freezed == profileImage ? _self.profileImage : profileImage // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as UserBasic?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as String?,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,membersCount: null == membersCount ? _self.membersCount : membersCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,eventsCount: null == eventsCount ? _self.eventsCount : eventsCount // ignore: cast_nullable_to_non_nullable
as int,currentUserMembership: freezed == currentUserMembership ? _self.currentUserMembership : currentUserMembership // ignore: cast_nullable_to_non_nullable
as Membership?,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,hasPendingRequest: null == hasPendingRequest ? _self.hasPendingRequest : hasPendingRequest // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipCopyWith<$Res>? get currentUserMembership {
    if (_self.currentUserMembership == null) {
    return null;
  }

  return $MembershipCopyWith<$Res>(_self.currentUserMembership!, (value) {
    return _then(_self.copyWith(currentUserMembership: value));
  });
}
}


/// @nodoc
mixin _$Membership {

 String get id; String get groupId; String get userId; UserBasic? get user; String get role; String get status; String? get joinedAt; String? get leftAt;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);

  /// Serializes this Membership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,userId,user,role,status,joinedAt,leftAt);

@override
String toString() {
  return 'Membership(id: $id, groupId: $groupId, userId: $userId, user: $user, role: $role, status: $status, joinedAt: $joinedAt, leftAt: $leftAt)';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, String userId, UserBasic? user, String role, String status, String? joinedAt, String? leftAt
});


$UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? userId = null,Object? user = freezed,Object? role = null,Object? status = null,Object? joinedAt = freezed,Object? leftAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  String userId,  UserBasic? user,  String role,  String status,  String? joinedAt,  String? leftAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.groupId,_that.userId,_that.user,_that.role,_that.status,_that.joinedAt,_that.leftAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  String userId,  UserBasic? user,  String role,  String status,  String? joinedAt,  String? leftAt)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.id,_that.groupId,_that.userId,_that.user,_that.role,_that.status,_that.joinedAt,_that.leftAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  String userId,  UserBasic? user,  String role,  String status,  String? joinedAt,  String? leftAt)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.groupId,_that.userId,_that.user,_that.role,_that.status,_that.joinedAt,_that.leftAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Membership implements Membership {
  const _Membership({required this.id, required this.groupId, required this.userId, this.user, this.role = 'member', this.status = 'active', this.joinedAt, this.leftAt});
  factory _Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  String userId;
@override final  UserBasic? user;
@override@JsonKey() final  String role;
@override@JsonKey() final  String status;
@override final  String? joinedAt;
@override final  String? leftAt;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,userId,user,role,status,joinedAt,leftAt);

@override
String toString() {
  return 'Membership(id: $id, groupId: $groupId, userId: $userId, user: $user, role: $role, status: $status, joinedAt: $joinedAt, leftAt: $leftAt)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, String userId, UserBasic? user, String role, String status, String? joinedAt, String? leftAt
});


@override $UserBasicCopyWith<$Res>? get user;

}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? userId = null,Object? user = freezed,Object? role = null,Object? status = null,Object? joinedAt = freezed,Object? leftAt = freezed,}) {
  return _then(_Membership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserBasic?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as String?,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$GroupPost {

 String get id; String get groupId; Group? get group; String get authorId; UserBasic? get author; String get content; String? get image; int get likesCount; int get commentsCount; bool get isLiked; String? get createdAt; String? get updatedAt;
/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupPostCopyWith<GroupPost> get copyWith => _$GroupPostCopyWithImpl<GroupPost>(this as GroupPost, _$identity);

  /// Serializes this GroupPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupPost&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.group, group) || other.group == group)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.image, image) || other.image == image)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,group,authorId,author,content,image,likesCount,commentsCount,isLiked,createdAt,updatedAt);

@override
String toString() {
  return 'GroupPost(id: $id, groupId: $groupId, group: $group, authorId: $authorId, author: $author, content: $content, image: $image, likesCount: $likesCount, commentsCount: $commentsCount, isLiked: $isLiked, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GroupPostCopyWith<$Res>  {
  factory $GroupPostCopyWith(GroupPost value, $Res Function(GroupPost) _then) = _$GroupPostCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, Group? group, String authorId, UserBasic? author, String content, String? image, int likesCount, int commentsCount, bool isLiked, String? createdAt, String? updatedAt
});


$GroupCopyWith<$Res>? get group;$UserBasicCopyWith<$Res>? get author;

}
/// @nodoc
class _$GroupPostCopyWithImpl<$Res>
    implements $GroupPostCopyWith<$Res> {
  _$GroupPostCopyWithImpl(this._self, this._then);

  final GroupPost _self;
  final $Res Function(GroupPost) _then;

/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? group = freezed,Object? authorId = null,Object? author = freezed,Object? content = null,Object? image = freezed,Object? likesCount = null,Object? commentsCount = null,Object? isLiked = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserBasic?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res>? get group {
    if (_self.group == null) {
    return null;
  }

  return $GroupCopyWith<$Res>(_self.group!, (value) {
    return _then(_self.copyWith(group: value));
  });
}/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupPost].
extension GroupPostPatterns on GroupPost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupPost value)  $default,){
final _that = this;
switch (_that) {
case _GroupPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupPost value)?  $default,){
final _that = this;
switch (_that) {
case _GroupPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  Group? group,  String authorId,  UserBasic? author,  String content,  String? image,  int likesCount,  int commentsCount,  bool isLiked,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupPost() when $default != null:
return $default(_that.id,_that.groupId,_that.group,_that.authorId,_that.author,_that.content,_that.image,_that.likesCount,_that.commentsCount,_that.isLiked,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  Group? group,  String authorId,  UserBasic? author,  String content,  String? image,  int likesCount,  int commentsCount,  bool isLiked,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GroupPost():
return $default(_that.id,_that.groupId,_that.group,_that.authorId,_that.author,_that.content,_that.image,_that.likesCount,_that.commentsCount,_that.isLiked,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  Group? group,  String authorId,  UserBasic? author,  String content,  String? image,  int likesCount,  int commentsCount,  bool isLiked,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GroupPost() when $default != null:
return $default(_that.id,_that.groupId,_that.group,_that.authorId,_that.author,_that.content,_that.image,_that.likesCount,_that.commentsCount,_that.isLiked,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupPost implements GroupPost {
  const _GroupPost({required this.id, required this.groupId, this.group, required this.authorId, this.author, required this.content, this.image, this.likesCount = 0, this.commentsCount = 0, this.isLiked = false, this.createdAt, this.updatedAt});
  factory _GroupPost.fromJson(Map<String, dynamic> json) => _$GroupPostFromJson(json);

@override final  String id;
@override final  String groupId;
@override final  Group? group;
@override final  String authorId;
@override final  UserBasic? author;
@override final  String content;
@override final  String? image;
@override@JsonKey() final  int likesCount;
@override@JsonKey() final  int commentsCount;
@override@JsonKey() final  bool isLiked;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupPostCopyWith<_GroupPost> get copyWith => __$GroupPostCopyWithImpl<_GroupPost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupPostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupPost&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.group, group) || other.group == group)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.image, image) || other.image == image)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,group,authorId,author,content,image,likesCount,commentsCount,isLiked,createdAt,updatedAt);

@override
String toString() {
  return 'GroupPost(id: $id, groupId: $groupId, group: $group, authorId: $authorId, author: $author, content: $content, image: $image, likesCount: $likesCount, commentsCount: $commentsCount, isLiked: $isLiked, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GroupPostCopyWith<$Res> implements $GroupPostCopyWith<$Res> {
  factory _$GroupPostCopyWith(_GroupPost value, $Res Function(_GroupPost) _then) = __$GroupPostCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, Group? group, String authorId, UserBasic? author, String content, String? image, int likesCount, int commentsCount, bool isLiked, String? createdAt, String? updatedAt
});


@override $GroupCopyWith<$Res>? get group;@override $UserBasicCopyWith<$Res>? get author;

}
/// @nodoc
class __$GroupPostCopyWithImpl<$Res>
    implements _$GroupPostCopyWith<$Res> {
  __$GroupPostCopyWithImpl(this._self, this._then);

  final _GroupPost _self;
  final $Res Function(_GroupPost) _then;

/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? group = freezed,Object? authorId = null,Object? author = freezed,Object? content = null,Object? image = freezed,Object? likesCount = null,Object? commentsCount = null,Object? isLiked = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_GroupPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group?,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserBasic?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res>? get group {
    if (_self.group == null) {
    return null;
  }

  return $GroupCopyWith<$Res>(_self.group!, (value) {
    return _then(_self.copyWith(group: value));
  });
}/// Create a copy of GroupPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserBasicCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserBasicCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// @nodoc
mixin _$UserBasic {

 String get id; String get username; String? get firstName; String? get lastName; String? get profilePicture; String? get role;
/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserBasicCopyWith<UserBasic> get copyWith => _$UserBasicCopyWithImpl<UserBasic>(this as UserBasic, _$identity);

  /// Serializes this UserBasic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserBasic&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,firstName,lastName,profilePicture,role);

@override
String toString() {
  return 'UserBasic(id: $id, username: $username, firstName: $firstName, lastName: $lastName, profilePicture: $profilePicture, role: $role)';
}


}

/// @nodoc
abstract mixin class $UserBasicCopyWith<$Res>  {
  factory $UserBasicCopyWith(UserBasic value, $Res Function(UserBasic) _then) = _$UserBasicCopyWithImpl;
@useResult
$Res call({
 String id, String username, String? firstName, String? lastName, String? profilePicture, String? role
});




}
/// @nodoc
class _$UserBasicCopyWithImpl<$Res>
    implements $UserBasicCopyWith<$Res> {
  _$UserBasicCopyWithImpl(this._self, this._then);

  final UserBasic _self;
  final $Res Function(UserBasic) _then;

/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? profilePicture = freezed,Object? role = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserBasic].
extension UserBasicPatterns on UserBasic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserBasic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserBasic value)  $default,){
final _that = this;
switch (_that) {
case _UserBasic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserBasic value)?  $default,){
final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String? firstName,  String? lastName,  String? profilePicture,  String? role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.profilePicture,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String? firstName,  String? lastName,  String? profilePicture,  String? role)  $default,) {final _that = this;
switch (_that) {
case _UserBasic():
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.profilePicture,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String? firstName,  String? lastName,  String? profilePicture,  String? role)?  $default,) {final _that = this;
switch (_that) {
case _UserBasic() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.profilePicture,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserBasic implements UserBasic {
  const _UserBasic({required this.id, required this.username, this.firstName, this.lastName, this.profilePicture, this.role});
  factory _UserBasic.fromJson(Map<String, dynamic> json) => _$UserBasicFromJson(json);

@override final  String id;
@override final  String username;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? profilePicture;
@override final  String? role;

/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserBasicCopyWith<_UserBasic> get copyWith => __$UserBasicCopyWithImpl<_UserBasic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserBasicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserBasic&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,firstName,lastName,profilePicture,role);

@override
String toString() {
  return 'UserBasic(id: $id, username: $username, firstName: $firstName, lastName: $lastName, profilePicture: $profilePicture, role: $role)';
}


}

/// @nodoc
abstract mixin class _$UserBasicCopyWith<$Res> implements $UserBasicCopyWith<$Res> {
  factory _$UserBasicCopyWith(_UserBasic value, $Res Function(_UserBasic) _then) = __$UserBasicCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String? firstName, String? lastName, String? profilePicture, String? role
});




}
/// @nodoc
class __$UserBasicCopyWithImpl<$Res>
    implements _$UserBasicCopyWith<$Res> {
  __$UserBasicCopyWithImpl(this._self, this._then);

  final _UserBasic _self;
  final $Res Function(_UserBasic) _then;

/// Create a copy of UserBasic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? profilePicture = freezed,Object? role = freezed,}) {
  return _then(_UserBasic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
