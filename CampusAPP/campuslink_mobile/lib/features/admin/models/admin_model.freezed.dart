// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminDashboardStats {

 int get totalUsers; int get activeUsers; int get pendingUsers; int get bannedUsers; int get totalEvents; int get totalGroups; int get totalPosts; int get reportsToday; Map<String, dynamic>? get userGrowth; Map<String, dynamic>? get activityStats;
/// Create a copy of AdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminDashboardStatsCopyWith<AdminDashboardStats> get copyWith => _$AdminDashboardStatsCopyWithImpl<AdminDashboardStats>(this as AdminDashboardStats, _$identity);

  /// Serializes this AdminDashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminDashboardStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.pendingUsers, pendingUsers) || other.pendingUsers == pendingUsers)&&(identical(other.bannedUsers, bannedUsers) || other.bannedUsers == bannedUsers)&&(identical(other.totalEvents, totalEvents) || other.totalEvents == totalEvents)&&(identical(other.totalGroups, totalGroups) || other.totalGroups == totalGroups)&&(identical(other.totalPosts, totalPosts) || other.totalPosts == totalPosts)&&(identical(other.reportsToday, reportsToday) || other.reportsToday == reportsToday)&&const DeepCollectionEquality().equals(other.userGrowth, userGrowth)&&const DeepCollectionEquality().equals(other.activityStats, activityStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeUsers,pendingUsers,bannedUsers,totalEvents,totalGroups,totalPosts,reportsToday,const DeepCollectionEquality().hash(userGrowth),const DeepCollectionEquality().hash(activityStats));

@override
String toString() {
  return 'AdminDashboardStats(totalUsers: $totalUsers, activeUsers: $activeUsers, pendingUsers: $pendingUsers, bannedUsers: $bannedUsers, totalEvents: $totalEvents, totalGroups: $totalGroups, totalPosts: $totalPosts, reportsToday: $reportsToday, userGrowth: $userGrowth, activityStats: $activityStats)';
}


}

/// @nodoc
abstract mixin class $AdminDashboardStatsCopyWith<$Res>  {
  factory $AdminDashboardStatsCopyWith(AdminDashboardStats value, $Res Function(AdminDashboardStats) _then) = _$AdminDashboardStatsCopyWithImpl;
@useResult
$Res call({
 int totalUsers, int activeUsers, int pendingUsers, int bannedUsers, int totalEvents, int totalGroups, int totalPosts, int reportsToday, Map<String, dynamic>? userGrowth, Map<String, dynamic>? activityStats
});




}
/// @nodoc
class _$AdminDashboardStatsCopyWithImpl<$Res>
    implements $AdminDashboardStatsCopyWith<$Res> {
  _$AdminDashboardStatsCopyWithImpl(this._self, this._then);

  final AdminDashboardStats _self;
  final $Res Function(AdminDashboardStats) _then;

/// Create a copy of AdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUsers = null,Object? activeUsers = null,Object? pendingUsers = null,Object? bannedUsers = null,Object? totalEvents = null,Object? totalGroups = null,Object? totalPosts = null,Object? reportsToday = null,Object? userGrowth = freezed,Object? activityStats = freezed,}) {
  return _then(_self.copyWith(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,activeUsers: null == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int,pendingUsers: null == pendingUsers ? _self.pendingUsers : pendingUsers // ignore: cast_nullable_to_non_nullable
as int,bannedUsers: null == bannedUsers ? _self.bannedUsers : bannedUsers // ignore: cast_nullable_to_non_nullable
as int,totalEvents: null == totalEvents ? _self.totalEvents : totalEvents // ignore: cast_nullable_to_non_nullable
as int,totalGroups: null == totalGroups ? _self.totalGroups : totalGroups // ignore: cast_nullable_to_non_nullable
as int,totalPosts: null == totalPosts ? _self.totalPosts : totalPosts // ignore: cast_nullable_to_non_nullable
as int,reportsToday: null == reportsToday ? _self.reportsToday : reportsToday // ignore: cast_nullable_to_non_nullable
as int,userGrowth: freezed == userGrowth ? _self.userGrowth : userGrowth // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,activityStats: freezed == activityStats ? _self.activityStats : activityStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminDashboardStats].
extension AdminDashboardStatsPatterns on AdminDashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminDashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminDashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminDashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _AdminDashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminDashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _AdminDashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalUsers,  int activeUsers,  int pendingUsers,  int bannedUsers,  int totalEvents,  int totalGroups,  int totalPosts,  int reportsToday,  Map<String, dynamic>? userGrowth,  Map<String, dynamic>? activityStats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminDashboardStats() when $default != null:
return $default(_that.totalUsers,_that.activeUsers,_that.pendingUsers,_that.bannedUsers,_that.totalEvents,_that.totalGroups,_that.totalPosts,_that.reportsToday,_that.userGrowth,_that.activityStats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalUsers,  int activeUsers,  int pendingUsers,  int bannedUsers,  int totalEvents,  int totalGroups,  int totalPosts,  int reportsToday,  Map<String, dynamic>? userGrowth,  Map<String, dynamic>? activityStats)  $default,) {final _that = this;
switch (_that) {
case _AdminDashboardStats():
return $default(_that.totalUsers,_that.activeUsers,_that.pendingUsers,_that.bannedUsers,_that.totalEvents,_that.totalGroups,_that.totalPosts,_that.reportsToday,_that.userGrowth,_that.activityStats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalUsers,  int activeUsers,  int pendingUsers,  int bannedUsers,  int totalEvents,  int totalGroups,  int totalPosts,  int reportsToday,  Map<String, dynamic>? userGrowth,  Map<String, dynamic>? activityStats)?  $default,) {final _that = this;
switch (_that) {
case _AdminDashboardStats() when $default != null:
return $default(_that.totalUsers,_that.activeUsers,_that.pendingUsers,_that.bannedUsers,_that.totalEvents,_that.totalGroups,_that.totalPosts,_that.reportsToday,_that.userGrowth,_that.activityStats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminDashboardStats implements AdminDashboardStats {
  const _AdminDashboardStats({this.totalUsers = 0, this.activeUsers = 0, this.pendingUsers = 0, this.bannedUsers = 0, this.totalEvents = 0, this.totalGroups = 0, this.totalPosts = 0, this.reportsToday = 0, final  Map<String, dynamic>? userGrowth, final  Map<String, dynamic>? activityStats}): _userGrowth = userGrowth,_activityStats = activityStats;
  factory _AdminDashboardStats.fromJson(Map<String, dynamic> json) => _$AdminDashboardStatsFromJson(json);

@override@JsonKey() final  int totalUsers;
@override@JsonKey() final  int activeUsers;
@override@JsonKey() final  int pendingUsers;
@override@JsonKey() final  int bannedUsers;
@override@JsonKey() final  int totalEvents;
@override@JsonKey() final  int totalGroups;
@override@JsonKey() final  int totalPosts;
@override@JsonKey() final  int reportsToday;
 final  Map<String, dynamic>? _userGrowth;
@override Map<String, dynamic>? get userGrowth {
  final value = _userGrowth;
  if (value == null) return null;
  if (_userGrowth is EqualUnmodifiableMapView) return _userGrowth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _activityStats;
@override Map<String, dynamic>? get activityStats {
  final value = _activityStats;
  if (value == null) return null;
  if (_activityStats is EqualUnmodifiableMapView) return _activityStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminDashboardStatsCopyWith<_AdminDashboardStats> get copyWith => __$AdminDashboardStatsCopyWithImpl<_AdminDashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminDashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminDashboardStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.pendingUsers, pendingUsers) || other.pendingUsers == pendingUsers)&&(identical(other.bannedUsers, bannedUsers) || other.bannedUsers == bannedUsers)&&(identical(other.totalEvents, totalEvents) || other.totalEvents == totalEvents)&&(identical(other.totalGroups, totalGroups) || other.totalGroups == totalGroups)&&(identical(other.totalPosts, totalPosts) || other.totalPosts == totalPosts)&&(identical(other.reportsToday, reportsToday) || other.reportsToday == reportsToday)&&const DeepCollectionEquality().equals(other._userGrowth, _userGrowth)&&const DeepCollectionEquality().equals(other._activityStats, _activityStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeUsers,pendingUsers,bannedUsers,totalEvents,totalGroups,totalPosts,reportsToday,const DeepCollectionEquality().hash(_userGrowth),const DeepCollectionEquality().hash(_activityStats));

@override
String toString() {
  return 'AdminDashboardStats(totalUsers: $totalUsers, activeUsers: $activeUsers, pendingUsers: $pendingUsers, bannedUsers: $bannedUsers, totalEvents: $totalEvents, totalGroups: $totalGroups, totalPosts: $totalPosts, reportsToday: $reportsToday, userGrowth: $userGrowth, activityStats: $activityStats)';
}


}

/// @nodoc
abstract mixin class _$AdminDashboardStatsCopyWith<$Res> implements $AdminDashboardStatsCopyWith<$Res> {
  factory _$AdminDashboardStatsCopyWith(_AdminDashboardStats value, $Res Function(_AdminDashboardStats) _then) = __$AdminDashboardStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalUsers, int activeUsers, int pendingUsers, int bannedUsers, int totalEvents, int totalGroups, int totalPosts, int reportsToday, Map<String, dynamic>? userGrowth, Map<String, dynamic>? activityStats
});




}
/// @nodoc
class __$AdminDashboardStatsCopyWithImpl<$Res>
    implements _$AdminDashboardStatsCopyWith<$Res> {
  __$AdminDashboardStatsCopyWithImpl(this._self, this._then);

  final _AdminDashboardStats _self;
  final $Res Function(_AdminDashboardStats) _then;

/// Create a copy of AdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUsers = null,Object? activeUsers = null,Object? pendingUsers = null,Object? bannedUsers = null,Object? totalEvents = null,Object? totalGroups = null,Object? totalPosts = null,Object? reportsToday = null,Object? userGrowth = freezed,Object? activityStats = freezed,}) {
  return _then(_AdminDashboardStats(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,activeUsers: null == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int,pendingUsers: null == pendingUsers ? _self.pendingUsers : pendingUsers // ignore: cast_nullable_to_non_nullable
as int,bannedUsers: null == bannedUsers ? _self.bannedUsers : bannedUsers // ignore: cast_nullable_to_non_nullable
as int,totalEvents: null == totalEvents ? _self.totalEvents : totalEvents // ignore: cast_nullable_to_non_nullable
as int,totalGroups: null == totalGroups ? _self.totalGroups : totalGroups // ignore: cast_nullable_to_non_nullable
as int,totalPosts: null == totalPosts ? _self.totalPosts : totalPosts // ignore: cast_nullable_to_non_nullable
as int,reportsToday: null == reportsToday ? _self.reportsToday : reportsToday // ignore: cast_nullable_to_non_nullable
as int,userGrowth: freezed == userGrowth ? _self._userGrowth : userGrowth // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,activityStats: freezed == activityStats ? _self._activityStats : activityStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$UniversityAdminDashboardStats {

 int get totalStudents; int get activeStudents; int get pendingStudents; int get classLeaders; int get totalGroups; int get totalEvents; String? get universityName; Map<String, dynamic>? get departmentStats; Map<String, dynamic>? get recentActivity;
/// Create a copy of UniversityAdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UniversityAdminDashboardStatsCopyWith<UniversityAdminDashboardStats> get copyWith => _$UniversityAdminDashboardStatsCopyWithImpl<UniversityAdminDashboardStats>(this as UniversityAdminDashboardStats, _$identity);

  /// Serializes this UniversityAdminDashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UniversityAdminDashboardStats&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingStudents, pendingStudents) || other.pendingStudents == pendingStudents)&&(identical(other.classLeaders, classLeaders) || other.classLeaders == classLeaders)&&(identical(other.totalGroups, totalGroups) || other.totalGroups == totalGroups)&&(identical(other.totalEvents, totalEvents) || other.totalEvents == totalEvents)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&const DeepCollectionEquality().equals(other.departmentStats, departmentStats)&&const DeepCollectionEquality().equals(other.recentActivity, recentActivity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalStudents,activeStudents,pendingStudents,classLeaders,totalGroups,totalEvents,universityName,const DeepCollectionEquality().hash(departmentStats),const DeepCollectionEquality().hash(recentActivity));

@override
String toString() {
  return 'UniversityAdminDashboardStats(totalStudents: $totalStudents, activeStudents: $activeStudents, pendingStudents: $pendingStudents, classLeaders: $classLeaders, totalGroups: $totalGroups, totalEvents: $totalEvents, universityName: $universityName, departmentStats: $departmentStats, recentActivity: $recentActivity)';
}


}

/// @nodoc
abstract mixin class $UniversityAdminDashboardStatsCopyWith<$Res>  {
  factory $UniversityAdminDashboardStatsCopyWith(UniversityAdminDashboardStats value, $Res Function(UniversityAdminDashboardStats) _then) = _$UniversityAdminDashboardStatsCopyWithImpl;
@useResult
$Res call({
 int totalStudents, int activeStudents, int pendingStudents, int classLeaders, int totalGroups, int totalEvents, String? universityName, Map<String, dynamic>? departmentStats, Map<String, dynamic>? recentActivity
});




}
/// @nodoc
class _$UniversityAdminDashboardStatsCopyWithImpl<$Res>
    implements $UniversityAdminDashboardStatsCopyWith<$Res> {
  _$UniversityAdminDashboardStatsCopyWithImpl(this._self, this._then);

  final UniversityAdminDashboardStats _self;
  final $Res Function(UniversityAdminDashboardStats) _then;

/// Create a copy of UniversityAdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalStudents = null,Object? activeStudents = null,Object? pendingStudents = null,Object? classLeaders = null,Object? totalGroups = null,Object? totalEvents = null,Object? universityName = freezed,Object? departmentStats = freezed,Object? recentActivity = freezed,}) {
  return _then(_self.copyWith(
totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingStudents: null == pendingStudents ? _self.pendingStudents : pendingStudents // ignore: cast_nullable_to_non_nullable
as int,classLeaders: null == classLeaders ? _self.classLeaders : classLeaders // ignore: cast_nullable_to_non_nullable
as int,totalGroups: null == totalGroups ? _self.totalGroups : totalGroups // ignore: cast_nullable_to_non_nullable
as int,totalEvents: null == totalEvents ? _self.totalEvents : totalEvents // ignore: cast_nullable_to_non_nullable
as int,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,departmentStats: freezed == departmentStats ? _self.departmentStats : departmentStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,recentActivity: freezed == recentActivity ? _self.recentActivity : recentActivity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UniversityAdminDashboardStats].
extension UniversityAdminDashboardStatsPatterns on UniversityAdminDashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UniversityAdminDashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UniversityAdminDashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UniversityAdminDashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _UniversityAdminDashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UniversityAdminDashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _UniversityAdminDashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalStudents,  int activeStudents,  int pendingStudents,  int classLeaders,  int totalGroups,  int totalEvents,  String? universityName,  Map<String, dynamic>? departmentStats,  Map<String, dynamic>? recentActivity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UniversityAdminDashboardStats() when $default != null:
return $default(_that.totalStudents,_that.activeStudents,_that.pendingStudents,_that.classLeaders,_that.totalGroups,_that.totalEvents,_that.universityName,_that.departmentStats,_that.recentActivity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalStudents,  int activeStudents,  int pendingStudents,  int classLeaders,  int totalGroups,  int totalEvents,  String? universityName,  Map<String, dynamic>? departmentStats,  Map<String, dynamic>? recentActivity)  $default,) {final _that = this;
switch (_that) {
case _UniversityAdminDashboardStats():
return $default(_that.totalStudents,_that.activeStudents,_that.pendingStudents,_that.classLeaders,_that.totalGroups,_that.totalEvents,_that.universityName,_that.departmentStats,_that.recentActivity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalStudents,  int activeStudents,  int pendingStudents,  int classLeaders,  int totalGroups,  int totalEvents,  String? universityName,  Map<String, dynamic>? departmentStats,  Map<String, dynamic>? recentActivity)?  $default,) {final _that = this;
switch (_that) {
case _UniversityAdminDashboardStats() when $default != null:
return $default(_that.totalStudents,_that.activeStudents,_that.pendingStudents,_that.classLeaders,_that.totalGroups,_that.totalEvents,_that.universityName,_that.departmentStats,_that.recentActivity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UniversityAdminDashboardStats implements UniversityAdminDashboardStats {
  const _UniversityAdminDashboardStats({this.totalStudents = 0, this.activeStudents = 0, this.pendingStudents = 0, this.classLeaders = 0, this.totalGroups = 0, this.totalEvents = 0, this.universityName, final  Map<String, dynamic>? departmentStats, final  Map<String, dynamic>? recentActivity}): _departmentStats = departmentStats,_recentActivity = recentActivity;
  factory _UniversityAdminDashboardStats.fromJson(Map<String, dynamic> json) => _$UniversityAdminDashboardStatsFromJson(json);

@override@JsonKey() final  int totalStudents;
@override@JsonKey() final  int activeStudents;
@override@JsonKey() final  int pendingStudents;
@override@JsonKey() final  int classLeaders;
@override@JsonKey() final  int totalGroups;
@override@JsonKey() final  int totalEvents;
@override final  String? universityName;
 final  Map<String, dynamic>? _departmentStats;
@override Map<String, dynamic>? get departmentStats {
  final value = _departmentStats;
  if (value == null) return null;
  if (_departmentStats is EqualUnmodifiableMapView) return _departmentStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _recentActivity;
@override Map<String, dynamic>? get recentActivity {
  final value = _recentActivity;
  if (value == null) return null;
  if (_recentActivity is EqualUnmodifiableMapView) return _recentActivity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of UniversityAdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UniversityAdminDashboardStatsCopyWith<_UniversityAdminDashboardStats> get copyWith => __$UniversityAdminDashboardStatsCopyWithImpl<_UniversityAdminDashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UniversityAdminDashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UniversityAdminDashboardStats&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingStudents, pendingStudents) || other.pendingStudents == pendingStudents)&&(identical(other.classLeaders, classLeaders) || other.classLeaders == classLeaders)&&(identical(other.totalGroups, totalGroups) || other.totalGroups == totalGroups)&&(identical(other.totalEvents, totalEvents) || other.totalEvents == totalEvents)&&(identical(other.universityName, universityName) || other.universityName == universityName)&&const DeepCollectionEquality().equals(other._departmentStats, _departmentStats)&&const DeepCollectionEquality().equals(other._recentActivity, _recentActivity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalStudents,activeStudents,pendingStudents,classLeaders,totalGroups,totalEvents,universityName,const DeepCollectionEquality().hash(_departmentStats),const DeepCollectionEquality().hash(_recentActivity));

@override
String toString() {
  return 'UniversityAdminDashboardStats(totalStudents: $totalStudents, activeStudents: $activeStudents, pendingStudents: $pendingStudents, classLeaders: $classLeaders, totalGroups: $totalGroups, totalEvents: $totalEvents, universityName: $universityName, departmentStats: $departmentStats, recentActivity: $recentActivity)';
}


}

/// @nodoc
abstract mixin class _$UniversityAdminDashboardStatsCopyWith<$Res> implements $UniversityAdminDashboardStatsCopyWith<$Res> {
  factory _$UniversityAdminDashboardStatsCopyWith(_UniversityAdminDashboardStats value, $Res Function(_UniversityAdminDashboardStats) _then) = __$UniversityAdminDashboardStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalStudents, int activeStudents, int pendingStudents, int classLeaders, int totalGroups, int totalEvents, String? universityName, Map<String, dynamic>? departmentStats, Map<String, dynamic>? recentActivity
});




}
/// @nodoc
class __$UniversityAdminDashboardStatsCopyWithImpl<$Res>
    implements _$UniversityAdminDashboardStatsCopyWith<$Res> {
  __$UniversityAdminDashboardStatsCopyWithImpl(this._self, this._then);

  final _UniversityAdminDashboardStats _self;
  final $Res Function(_UniversityAdminDashboardStats) _then;

/// Create a copy of UniversityAdminDashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalStudents = null,Object? activeStudents = null,Object? pendingStudents = null,Object? classLeaders = null,Object? totalGroups = null,Object? totalEvents = null,Object? universityName = freezed,Object? departmentStats = freezed,Object? recentActivity = freezed,}) {
  return _then(_UniversityAdminDashboardStats(
totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingStudents: null == pendingStudents ? _self.pendingStudents : pendingStudents // ignore: cast_nullable_to_non_nullable
as int,classLeaders: null == classLeaders ? _self.classLeaders : classLeaders // ignore: cast_nullable_to_non_nullable
as int,totalGroups: null == totalGroups ? _self.totalGroups : totalGroups // ignore: cast_nullable_to_non_nullable
as int,totalEvents: null == totalEvents ? _self.totalEvents : totalEvents // ignore: cast_nullable_to_non_nullable
as int,universityName: freezed == universityName ? _self.universityName : universityName // ignore: cast_nullable_to_non_nullable
as String?,departmentStats: freezed == departmentStats ? _self._departmentStats : departmentStats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,recentActivity: freezed == recentActivity ? _self._recentActivity : recentActivity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ClassLeaderDashboardStats {

 int get classSize; int get activeStudents; int get pendingStudents; int get classEvents; int get classGroups; String? get className; String? get departmentName; List<StudentActivity>? get recentActivities;
/// Create a copy of ClassLeaderDashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassLeaderDashboardStatsCopyWith<ClassLeaderDashboardStats> get copyWith => _$ClassLeaderDashboardStatsCopyWithImpl<ClassLeaderDashboardStats>(this as ClassLeaderDashboardStats, _$identity);

  /// Serializes this ClassLeaderDashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassLeaderDashboardStats&&(identical(other.classSize, classSize) || other.classSize == classSize)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingStudents, pendingStudents) || other.pendingStudents == pendingStudents)&&(identical(other.classEvents, classEvents) || other.classEvents == classEvents)&&(identical(other.classGroups, classGroups) || other.classGroups == classGroups)&&(identical(other.className, className) || other.className == className)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&const DeepCollectionEquality().equals(other.recentActivities, recentActivities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classSize,activeStudents,pendingStudents,classEvents,classGroups,className,departmentName,const DeepCollectionEquality().hash(recentActivities));

@override
String toString() {
  return 'ClassLeaderDashboardStats(classSize: $classSize, activeStudents: $activeStudents, pendingStudents: $pendingStudents, classEvents: $classEvents, classGroups: $classGroups, className: $className, departmentName: $departmentName, recentActivities: $recentActivities)';
}


}

/// @nodoc
abstract mixin class $ClassLeaderDashboardStatsCopyWith<$Res>  {
  factory $ClassLeaderDashboardStatsCopyWith(ClassLeaderDashboardStats value, $Res Function(ClassLeaderDashboardStats) _then) = _$ClassLeaderDashboardStatsCopyWithImpl;
@useResult
$Res call({
 int classSize, int activeStudents, int pendingStudents, int classEvents, int classGroups, String? className, String? departmentName, List<StudentActivity>? recentActivities
});




}
/// @nodoc
class _$ClassLeaderDashboardStatsCopyWithImpl<$Res>
    implements $ClassLeaderDashboardStatsCopyWith<$Res> {
  _$ClassLeaderDashboardStatsCopyWithImpl(this._self, this._then);

  final ClassLeaderDashboardStats _self;
  final $Res Function(ClassLeaderDashboardStats) _then;

/// Create a copy of ClassLeaderDashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? classSize = null,Object? activeStudents = null,Object? pendingStudents = null,Object? classEvents = null,Object? classGroups = null,Object? className = freezed,Object? departmentName = freezed,Object? recentActivities = freezed,}) {
  return _then(_self.copyWith(
classSize: null == classSize ? _self.classSize : classSize // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingStudents: null == pendingStudents ? _self.pendingStudents : pendingStudents // ignore: cast_nullable_to_non_nullable
as int,classEvents: null == classEvents ? _self.classEvents : classEvents // ignore: cast_nullable_to_non_nullable
as int,classGroups: null == classGroups ? _self.classGroups : classGroups // ignore: cast_nullable_to_non_nullable
as int,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,departmentName: freezed == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String?,recentActivities: freezed == recentActivities ? _self.recentActivities : recentActivities // ignore: cast_nullable_to_non_nullable
as List<StudentActivity>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassLeaderDashboardStats].
extension ClassLeaderDashboardStatsPatterns on ClassLeaderDashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassLeaderDashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassLeaderDashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassLeaderDashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _ClassLeaderDashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassLeaderDashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _ClassLeaderDashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int classSize,  int activeStudents,  int pendingStudents,  int classEvents,  int classGroups,  String? className,  String? departmentName,  List<StudentActivity>? recentActivities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassLeaderDashboardStats() when $default != null:
return $default(_that.classSize,_that.activeStudents,_that.pendingStudents,_that.classEvents,_that.classGroups,_that.className,_that.departmentName,_that.recentActivities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int classSize,  int activeStudents,  int pendingStudents,  int classEvents,  int classGroups,  String? className,  String? departmentName,  List<StudentActivity>? recentActivities)  $default,) {final _that = this;
switch (_that) {
case _ClassLeaderDashboardStats():
return $default(_that.classSize,_that.activeStudents,_that.pendingStudents,_that.classEvents,_that.classGroups,_that.className,_that.departmentName,_that.recentActivities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int classSize,  int activeStudents,  int pendingStudents,  int classEvents,  int classGroups,  String? className,  String? departmentName,  List<StudentActivity>? recentActivities)?  $default,) {final _that = this;
switch (_that) {
case _ClassLeaderDashboardStats() when $default != null:
return $default(_that.classSize,_that.activeStudents,_that.pendingStudents,_that.classEvents,_that.classGroups,_that.className,_that.departmentName,_that.recentActivities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassLeaderDashboardStats implements ClassLeaderDashboardStats {
  const _ClassLeaderDashboardStats({this.classSize = 0, this.activeStudents = 0, this.pendingStudents = 0, this.classEvents = 0, this.classGroups = 0, this.className, this.departmentName, final  List<StudentActivity>? recentActivities}): _recentActivities = recentActivities;
  factory _ClassLeaderDashboardStats.fromJson(Map<String, dynamic> json) => _$ClassLeaderDashboardStatsFromJson(json);

@override@JsonKey() final  int classSize;
@override@JsonKey() final  int activeStudents;
@override@JsonKey() final  int pendingStudents;
@override@JsonKey() final  int classEvents;
@override@JsonKey() final  int classGroups;
@override final  String? className;
@override final  String? departmentName;
 final  List<StudentActivity>? _recentActivities;
@override List<StudentActivity>? get recentActivities {
  final value = _recentActivities;
  if (value == null) return null;
  if (_recentActivities is EqualUnmodifiableListView) return _recentActivities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ClassLeaderDashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassLeaderDashboardStatsCopyWith<_ClassLeaderDashboardStats> get copyWith => __$ClassLeaderDashboardStatsCopyWithImpl<_ClassLeaderDashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassLeaderDashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassLeaderDashboardStats&&(identical(other.classSize, classSize) || other.classSize == classSize)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingStudents, pendingStudents) || other.pendingStudents == pendingStudents)&&(identical(other.classEvents, classEvents) || other.classEvents == classEvents)&&(identical(other.classGroups, classGroups) || other.classGroups == classGroups)&&(identical(other.className, className) || other.className == className)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&const DeepCollectionEquality().equals(other._recentActivities, _recentActivities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classSize,activeStudents,pendingStudents,classEvents,classGroups,className,departmentName,const DeepCollectionEquality().hash(_recentActivities));

@override
String toString() {
  return 'ClassLeaderDashboardStats(classSize: $classSize, activeStudents: $activeStudents, pendingStudents: $pendingStudents, classEvents: $classEvents, classGroups: $classGroups, className: $className, departmentName: $departmentName, recentActivities: $recentActivities)';
}


}

/// @nodoc
abstract mixin class _$ClassLeaderDashboardStatsCopyWith<$Res> implements $ClassLeaderDashboardStatsCopyWith<$Res> {
  factory _$ClassLeaderDashboardStatsCopyWith(_ClassLeaderDashboardStats value, $Res Function(_ClassLeaderDashboardStats) _then) = __$ClassLeaderDashboardStatsCopyWithImpl;
@override @useResult
$Res call({
 int classSize, int activeStudents, int pendingStudents, int classEvents, int classGroups, String? className, String? departmentName, List<StudentActivity>? recentActivities
});




}
/// @nodoc
class __$ClassLeaderDashboardStatsCopyWithImpl<$Res>
    implements _$ClassLeaderDashboardStatsCopyWith<$Res> {
  __$ClassLeaderDashboardStatsCopyWithImpl(this._self, this._then);

  final _ClassLeaderDashboardStats _self;
  final $Res Function(_ClassLeaderDashboardStats) _then;

/// Create a copy of ClassLeaderDashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? classSize = null,Object? activeStudents = null,Object? pendingStudents = null,Object? classEvents = null,Object? classGroups = null,Object? className = freezed,Object? departmentName = freezed,Object? recentActivities = freezed,}) {
  return _then(_ClassLeaderDashboardStats(
classSize: null == classSize ? _self.classSize : classSize // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingStudents: null == pendingStudents ? _self.pendingStudents : pendingStudents // ignore: cast_nullable_to_non_nullable
as int,classEvents: null == classEvents ? _self.classEvents : classEvents // ignore: cast_nullable_to_non_nullable
as int,classGroups: null == classGroups ? _self.classGroups : classGroups // ignore: cast_nullable_to_non_nullable
as int,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,departmentName: freezed == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String?,recentActivities: freezed == recentActivities ? _self._recentActivities : recentActivities // ignore: cast_nullable_to_non_nullable
as List<StudentActivity>?,
  ));
}


}


/// @nodoc
mixin _$StudentActivity {

 String get id; String? get studentName; String? get studentId; String get activityType; String? get description; String? get timestamp;
/// Create a copy of StudentActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentActivityCopyWith<StudentActivity> get copyWith => _$StudentActivityCopyWithImpl<StudentActivity>(this as StudentActivity, _$identity);

  /// Serializes this StudentActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentName,studentId,activityType,description,timestamp);

@override
String toString() {
  return 'StudentActivity(id: $id, studentName: $studentName, studentId: $studentId, activityType: $activityType, description: $description, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $StudentActivityCopyWith<$Res>  {
  factory $StudentActivityCopyWith(StudentActivity value, $Res Function(StudentActivity) _then) = _$StudentActivityCopyWithImpl;
@useResult
$Res call({
 String id, String? studentName, String? studentId, String activityType, String? description, String? timestamp
});




}
/// @nodoc
class _$StudentActivityCopyWithImpl<$Res>
    implements $StudentActivityCopyWith<$Res> {
  _$StudentActivityCopyWithImpl(this._self, this._then);

  final StudentActivity _self;
  final $Res Function(StudentActivity) _then;

/// Create a copy of StudentActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentName = freezed,Object? studentId = freezed,Object? activityType = null,Object? description = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentActivity].
extension StudentActivityPatterns on StudentActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentActivity value)  $default,){
final _that = this;
switch (_that) {
case _StudentActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentActivity value)?  $default,){
final _that = this;
switch (_that) {
case _StudentActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? studentName,  String? studentId,  String activityType,  String? description,  String? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentActivity() when $default != null:
return $default(_that.id,_that.studentName,_that.studentId,_that.activityType,_that.description,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? studentName,  String? studentId,  String activityType,  String? description,  String? timestamp)  $default,) {final _that = this;
switch (_that) {
case _StudentActivity():
return $default(_that.id,_that.studentName,_that.studentId,_that.activityType,_that.description,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? studentName,  String? studentId,  String activityType,  String? description,  String? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _StudentActivity() when $default != null:
return $default(_that.id,_that.studentName,_that.studentId,_that.activityType,_that.description,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentActivity implements StudentActivity {
  const _StudentActivity({required this.id, this.studentName, this.studentId, required this.activityType, this.description, this.timestamp});
  factory _StudentActivity.fromJson(Map<String, dynamic> json) => _$StudentActivityFromJson(json);

@override final  String id;
@override final  String? studentName;
@override final  String? studentId;
@override final  String activityType;
@override final  String? description;
@override final  String? timestamp;

/// Create a copy of StudentActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentActivityCopyWith<_StudentActivity> get copyWith => __$StudentActivityCopyWithImpl<_StudentActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.description, description) || other.description == description)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentName,studentId,activityType,description,timestamp);

@override
String toString() {
  return 'StudentActivity(id: $id, studentName: $studentName, studentId: $studentId, activityType: $activityType, description: $description, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$StudentActivityCopyWith<$Res> implements $StudentActivityCopyWith<$Res> {
  factory _$StudentActivityCopyWith(_StudentActivity value, $Res Function(_StudentActivity) _then) = __$StudentActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? studentName, String? studentId, String activityType, String? description, String? timestamp
});




}
/// @nodoc
class __$StudentActivityCopyWithImpl<$Res>
    implements _$StudentActivityCopyWith<$Res> {
  __$StudentActivityCopyWithImpl(this._self, this._then);

  final _StudentActivity _self;
  final $Res Function(_StudentActivity) _then;

/// Create a copy of StudentActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentName = freezed,Object? studentId = freezed,Object? activityType = null,Object? description = freezed,Object? timestamp = freezed,}) {
  return _then(_StudentActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PendingStudent {

 String get id; String get email; String get username; String? get firstName; String? get lastName; String? get phoneNumber; String? get university; String? get department; String? get studentId; String? get registrationDate; String? get verificationStatus;
/// Create a copy of PendingStudent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingStudentCopyWith<PendingStudent> get copyWith => _$PendingStudentCopyWithImpl<PendingStudent>(this as PendingStudent, _$identity);

  /// Serializes this PendingStudent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingStudent&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.university, university) || other.university == university)&&(identical(other.department, department) || other.department == department)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.registrationDate, registrationDate) || other.registrationDate == registrationDate)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,firstName,lastName,phoneNumber,university,department,studentId,registrationDate,verificationStatus);

@override
String toString() {
  return 'PendingStudent(id: $id, email: $email, username: $username, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, university: $university, department: $department, studentId: $studentId, registrationDate: $registrationDate, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $PendingStudentCopyWith<$Res>  {
  factory $PendingStudentCopyWith(PendingStudent value, $Res Function(PendingStudent) _then) = _$PendingStudentCopyWithImpl;
@useResult
$Res call({
 String id, String email, String username, String? firstName, String? lastName, String? phoneNumber, String? university, String? department, String? studentId, String? registrationDate, String? verificationStatus
});




}
/// @nodoc
class _$PendingStudentCopyWithImpl<$Res>
    implements $PendingStudentCopyWith<$Res> {
  _$PendingStudentCopyWithImpl(this._self, this._then);

  final PendingStudent _self;
  final $Res Function(PendingStudent) _then;

/// Create a copy of PendingStudent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? phoneNumber = freezed,Object? university = freezed,Object? department = freezed,Object? studentId = freezed,Object? registrationDate = freezed,Object? verificationStatus = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,registrationDate: freezed == registrationDate ? _self.registrationDate : registrationDate // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingStudent].
extension PendingStudentPatterns on PendingStudent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingStudent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingStudent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingStudent value)  $default,){
final _that = this;
switch (_that) {
case _PendingStudent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingStudent value)?  $default,){
final _that = this;
switch (_that) {
case _PendingStudent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String username,  String? firstName,  String? lastName,  String? phoneNumber,  String? university,  String? department,  String? studentId,  String? registrationDate,  String? verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingStudent() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.phoneNumber,_that.university,_that.department,_that.studentId,_that.registrationDate,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String username,  String? firstName,  String? lastName,  String? phoneNumber,  String? university,  String? department,  String? studentId,  String? registrationDate,  String? verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _PendingStudent():
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.phoneNumber,_that.university,_that.department,_that.studentId,_that.registrationDate,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String username,  String? firstName,  String? lastName,  String? phoneNumber,  String? university,  String? department,  String? studentId,  String? registrationDate,  String? verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _PendingStudent() when $default != null:
return $default(_that.id,_that.email,_that.username,_that.firstName,_that.lastName,_that.phoneNumber,_that.university,_that.department,_that.studentId,_that.registrationDate,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingStudent implements PendingStudent {
  const _PendingStudent({required this.id, required this.email, required this.username, this.firstName, this.lastName, this.phoneNumber, this.university, this.department, this.studentId, this.registrationDate, this.verificationStatus});
  factory _PendingStudent.fromJson(Map<String, dynamic> json) => _$PendingStudentFromJson(json);

@override final  String id;
@override final  String email;
@override final  String username;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? phoneNumber;
@override final  String? university;
@override final  String? department;
@override final  String? studentId;
@override final  String? registrationDate;
@override final  String? verificationStatus;

/// Create a copy of PendingStudent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingStudentCopyWith<_PendingStudent> get copyWith => __$PendingStudentCopyWithImpl<_PendingStudent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingStudentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingStudent&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.university, university) || other.university == university)&&(identical(other.department, department) || other.department == department)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.registrationDate, registrationDate) || other.registrationDate == registrationDate)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,username,firstName,lastName,phoneNumber,university,department,studentId,registrationDate,verificationStatus);

@override
String toString() {
  return 'PendingStudent(id: $id, email: $email, username: $username, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, university: $university, department: $department, studentId: $studentId, registrationDate: $registrationDate, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$PendingStudentCopyWith<$Res> implements $PendingStudentCopyWith<$Res> {
  factory _$PendingStudentCopyWith(_PendingStudent value, $Res Function(_PendingStudent) _then) = __$PendingStudentCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String username, String? firstName, String? lastName, String? phoneNumber, String? university, String? department, String? studentId, String? registrationDate, String? verificationStatus
});




}
/// @nodoc
class __$PendingStudentCopyWithImpl<$Res>
    implements _$PendingStudentCopyWith<$Res> {
  __$PendingStudentCopyWithImpl(this._self, this._then);

  final _PendingStudent _self;
  final $Res Function(_PendingStudent) _then;

/// Create a copy of PendingStudent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? phoneNumber = freezed,Object? university = freezed,Object? department = freezed,Object? studentId = freezed,Object? registrationDate = freezed,Object? verificationStatus = freezed,}) {
  return _then(_PendingStudent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,registrationDate: freezed == registrationDate ? _self.registrationDate : registrationDate // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ClassLeader {

 String get id; String get userId; String? get username; String? get firstName; String? get lastName; String? get email; String? get profilePicture; String? get university; String? get department; String? get className; int get studentsCount; String? get assignedAt;
/// Create a copy of ClassLeader
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassLeaderCopyWith<ClassLeader> get copyWith => _$ClassLeaderCopyWithImpl<ClassLeader>(this as ClassLeader, _$identity);

  /// Serializes this ClassLeader to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassLeader&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.university, university) || other.university == university)&&(identical(other.department, department) || other.department == department)&&(identical(other.className, className) || other.className == className)&&(identical(other.studentsCount, studentsCount) || other.studentsCount == studentsCount)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,username,firstName,lastName,email,profilePicture,university,department,className,studentsCount,assignedAt);

@override
String toString() {
  return 'ClassLeader(id: $id, userId: $userId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, university: $university, department: $department, className: $className, studentsCount: $studentsCount, assignedAt: $assignedAt)';
}


}

/// @nodoc
abstract mixin class $ClassLeaderCopyWith<$Res>  {
  factory $ClassLeaderCopyWith(ClassLeader value, $Res Function(ClassLeader) _then) = _$ClassLeaderCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? username, String? firstName, String? lastName, String? email, String? profilePicture, String? university, String? department, String? className, int studentsCount, String? assignedAt
});




}
/// @nodoc
class _$ClassLeaderCopyWithImpl<$Res>
    implements $ClassLeaderCopyWith<$Res> {
  _$ClassLeaderCopyWithImpl(this._self, this._then);

  final ClassLeader _self;
  final $Res Function(ClassLeader) _then;

/// Create a copy of ClassLeader
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,Object? profilePicture = freezed,Object? university = freezed,Object? department = freezed,Object? className = freezed,Object? studentsCount = null,Object? assignedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,studentsCount: null == studentsCount ? _self.studentsCount : studentsCount // ignore: cast_nullable_to_non_nullable
as int,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassLeader].
extension ClassLeaderPatterns on ClassLeader {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassLeader value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassLeader() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassLeader value)  $default,){
final _that = this;
switch (_that) {
case _ClassLeader():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassLeader value)?  $default,){
final _that = this;
switch (_that) {
case _ClassLeader() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? university,  String? department,  String? className,  int studentsCount,  String? assignedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassLeader() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.university,_that.department,_that.className,_that.studentsCount,_that.assignedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? university,  String? department,  String? className,  int studentsCount,  String? assignedAt)  $default,) {final _that = this;
switch (_that) {
case _ClassLeader():
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.university,_that.department,_that.className,_that.studentsCount,_that.assignedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? university,  String? department,  String? className,  int studentsCount,  String? assignedAt)?  $default,) {final _that = this;
switch (_that) {
case _ClassLeader() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.university,_that.department,_that.className,_that.studentsCount,_that.assignedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassLeader implements ClassLeader {
  const _ClassLeader({required this.id, required this.userId, this.username, this.firstName, this.lastName, this.email, this.profilePicture, this.university, this.department, this.className, this.studentsCount = 0, this.assignedAt});
  factory _ClassLeader.fromJson(Map<String, dynamic> json) => _$ClassLeaderFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? username;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? email;
@override final  String? profilePicture;
@override final  String? university;
@override final  String? department;
@override final  String? className;
@override@JsonKey() final  int studentsCount;
@override final  String? assignedAt;

/// Create a copy of ClassLeader
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassLeaderCopyWith<_ClassLeader> get copyWith => __$ClassLeaderCopyWithImpl<_ClassLeader>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassLeaderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassLeader&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.university, university) || other.university == university)&&(identical(other.department, department) || other.department == department)&&(identical(other.className, className) || other.className == className)&&(identical(other.studentsCount, studentsCount) || other.studentsCount == studentsCount)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,username,firstName,lastName,email,profilePicture,university,department,className,studentsCount,assignedAt);

@override
String toString() {
  return 'ClassLeader(id: $id, userId: $userId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, university: $university, department: $department, className: $className, studentsCount: $studentsCount, assignedAt: $assignedAt)';
}


}

/// @nodoc
abstract mixin class _$ClassLeaderCopyWith<$Res> implements $ClassLeaderCopyWith<$Res> {
  factory _$ClassLeaderCopyWith(_ClassLeader value, $Res Function(_ClassLeader) _then) = __$ClassLeaderCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? username, String? firstName, String? lastName, String? email, String? profilePicture, String? university, String? department, String? className, int studentsCount, String? assignedAt
});




}
/// @nodoc
class __$ClassLeaderCopyWithImpl<$Res>
    implements _$ClassLeaderCopyWith<$Res> {
  __$ClassLeaderCopyWithImpl(this._self, this._then);

  final _ClassLeader _self;
  final $Res Function(_ClassLeader) _then;

/// Create a copy of ClassLeader
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,Object? profilePicture = freezed,Object? university = freezed,Object? department = freezed,Object? className = freezed,Object? studentsCount = null,Object? assignedAt = freezed,}) {
  return _then(_ClassLeader(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,studentsCount: null == studentsCount ? _self.studentsCount : studentsCount // ignore: cast_nullable_to_non_nullable
as int,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
