// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moderation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Report {

 String get id; String get reporterId; String? get reporterName; String? get reporterAvatar; String get reportedUserId; String? get reportedUserName; String? get reportedUserAvatar; String get type; String get reason; String? get description; String? get contentType; String? get contentId; String? get contentPreview; String get status; String? get createdAt; String? get resolvedAt; String? get resolvedBy; String? get resolution; String? get moderatorNotes;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.reporterAvatar, reporterAvatar) || other.reporterAvatar == reporterAvatar)&&(identical(other.reportedUserId, reportedUserId) || other.reportedUserId == reportedUserId)&&(identical(other.reportedUserName, reportedUserName) || other.reportedUserName == reportedUserName)&&(identical(other.reportedUserAvatar, reportedUserAvatar) || other.reportedUserAvatar == reportedUserAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.contentPreview, contentPreview) || other.contentPreview == contentPreview)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.moderatorNotes, moderatorNotes) || other.moderatorNotes == moderatorNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reporterId,reporterName,reporterAvatar,reportedUserId,reportedUserName,reportedUserAvatar,type,reason,description,contentType,contentId,contentPreview,status,createdAt,resolvedAt,resolvedBy,resolution,moderatorNotes]);

@override
String toString() {
  return 'Report(id: $id, reporterId: $reporterId, reporterName: $reporterName, reporterAvatar: $reporterAvatar, reportedUserId: $reportedUserId, reportedUserName: $reportedUserName, reportedUserAvatar: $reportedUserAvatar, type: $type, reason: $reason, description: $description, contentType: $contentType, contentId: $contentId, contentPreview: $contentPreview, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolution: $resolution, moderatorNotes: $moderatorNotes)';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 String id, String reporterId, String? reporterName, String? reporterAvatar, String reportedUserId, String? reportedUserName, String? reportedUserAvatar, String type, String reason, String? description, String? contentType, String? contentId, String? contentPreview, String status, String? createdAt, String? resolvedAt, String? resolvedBy, String? resolution, String? moderatorNotes
});




}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reporterId = null,Object? reporterName = freezed,Object? reporterAvatar = freezed,Object? reportedUserId = null,Object? reportedUserName = freezed,Object? reportedUserAvatar = freezed,Object? type = null,Object? reason = null,Object? description = freezed,Object? contentType = freezed,Object? contentId = freezed,Object? contentPreview = freezed,Object? status = null,Object? createdAt = freezed,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolution = freezed,Object? moderatorNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reporterName: freezed == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String?,reporterAvatar: freezed == reporterAvatar ? _self.reporterAvatar : reporterAvatar // ignore: cast_nullable_to_non_nullable
as String?,reportedUserId: null == reportedUserId ? _self.reportedUserId : reportedUserId // ignore: cast_nullable_to_non_nullable
as String,reportedUserName: freezed == reportedUserName ? _self.reportedUserName : reportedUserName // ignore: cast_nullable_to_non_nullable
as String?,reportedUserAvatar: freezed == reportedUserAvatar ? _self.reportedUserAvatar : reportedUserAvatar // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,contentId: freezed == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String?,contentPreview: freezed == contentPreview ? _self.contentPreview : contentPreview // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,moderatorNotes: freezed == moderatorNotes ? _self.moderatorNotes : moderatorNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reporterId,  String? reporterName,  String? reporterAvatar,  String reportedUserId,  String? reportedUserName,  String? reportedUserAvatar,  String type,  String reason,  String? description,  String? contentType,  String? contentId,  String? contentPreview,  String status,  String? createdAt,  String? resolvedAt,  String? resolvedBy,  String? resolution,  String? moderatorNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reporterId,_that.reporterName,_that.reporterAvatar,_that.reportedUserId,_that.reportedUserName,_that.reportedUserAvatar,_that.type,_that.reason,_that.description,_that.contentType,_that.contentId,_that.contentPreview,_that.status,_that.createdAt,_that.resolvedAt,_that.resolvedBy,_that.resolution,_that.moderatorNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reporterId,  String? reporterName,  String? reporterAvatar,  String reportedUserId,  String? reportedUserName,  String? reportedUserAvatar,  String type,  String reason,  String? description,  String? contentType,  String? contentId,  String? contentPreview,  String status,  String? createdAt,  String? resolvedAt,  String? resolvedBy,  String? resolution,  String? moderatorNotes)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.reporterId,_that.reporterName,_that.reporterAvatar,_that.reportedUserId,_that.reportedUserName,_that.reportedUserAvatar,_that.type,_that.reason,_that.description,_that.contentType,_that.contentId,_that.contentPreview,_that.status,_that.createdAt,_that.resolvedAt,_that.resolvedBy,_that.resolution,_that.moderatorNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reporterId,  String? reporterName,  String? reporterAvatar,  String reportedUserId,  String? reportedUserName,  String? reportedUserAvatar,  String type,  String reason,  String? description,  String? contentType,  String? contentId,  String? contentPreview,  String status,  String? createdAt,  String? resolvedAt,  String? resolvedBy,  String? resolution,  String? moderatorNotes)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reporterId,_that.reporterName,_that.reporterAvatar,_that.reportedUserId,_that.reportedUserName,_that.reportedUserAvatar,_that.type,_that.reason,_that.description,_that.contentType,_that.contentId,_that.contentPreview,_that.status,_that.createdAt,_that.resolvedAt,_that.resolvedBy,_that.resolution,_that.moderatorNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({required this.id, required this.reporterId, this.reporterName, this.reporterAvatar, required this.reportedUserId, this.reportedUserName, this.reportedUserAvatar, required this.type, required this.reason, this.description, this.contentType, this.contentId, this.contentPreview, this.status = 'pending', this.createdAt, this.resolvedAt, this.resolvedBy, this.resolution, this.moderatorNotes});
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  String id;
@override final  String reporterId;
@override final  String? reporterName;
@override final  String? reporterAvatar;
@override final  String reportedUserId;
@override final  String? reportedUserName;
@override final  String? reportedUserAvatar;
@override final  String type;
@override final  String reason;
@override final  String? description;
@override final  String? contentType;
@override final  String? contentId;
@override final  String? contentPreview;
@override@JsonKey() final  String status;
@override final  String? createdAt;
@override final  String? resolvedAt;
@override final  String? resolvedBy;
@override final  String? resolution;
@override final  String? moderatorNotes;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reporterId, reporterId) || other.reporterId == reporterId)&&(identical(other.reporterName, reporterName) || other.reporterName == reporterName)&&(identical(other.reporterAvatar, reporterAvatar) || other.reporterAvatar == reporterAvatar)&&(identical(other.reportedUserId, reportedUserId) || other.reportedUserId == reportedUserId)&&(identical(other.reportedUserName, reportedUserName) || other.reportedUserName == reportedUserName)&&(identical(other.reportedUserAvatar, reportedUserAvatar) || other.reportedUserAvatar == reportedUserAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.contentPreview, contentPreview) || other.contentPreview == contentPreview)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.moderatorNotes, moderatorNotes) || other.moderatorNotes == moderatorNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reporterId,reporterName,reporterAvatar,reportedUserId,reportedUserName,reportedUserAvatar,type,reason,description,contentType,contentId,contentPreview,status,createdAt,resolvedAt,resolvedBy,resolution,moderatorNotes]);

@override
String toString() {
  return 'Report(id: $id, reporterId: $reporterId, reporterName: $reporterName, reporterAvatar: $reporterAvatar, reportedUserId: $reportedUserId, reportedUserName: $reportedUserName, reportedUserAvatar: $reportedUserAvatar, type: $type, reason: $reason, description: $description, contentType: $contentType, contentId: $contentId, contentPreview: $contentPreview, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolution: $resolution, moderatorNotes: $moderatorNotes)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String reporterId, String? reporterName, String? reporterAvatar, String reportedUserId, String? reportedUserName, String? reportedUserAvatar, String type, String reason, String? description, String? contentType, String? contentId, String? contentPreview, String status, String? createdAt, String? resolvedAt, String? resolvedBy, String? resolution, String? moderatorNotes
});




}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reporterId = null,Object? reporterName = freezed,Object? reporterAvatar = freezed,Object? reportedUserId = null,Object? reportedUserName = freezed,Object? reportedUserAvatar = freezed,Object? type = null,Object? reason = null,Object? description = freezed,Object? contentType = freezed,Object? contentId = freezed,Object? contentPreview = freezed,Object? status = null,Object? createdAt = freezed,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolution = freezed,Object? moderatorNotes = freezed,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reporterId: null == reporterId ? _self.reporterId : reporterId // ignore: cast_nullable_to_non_nullable
as String,reporterName: freezed == reporterName ? _self.reporterName : reporterName // ignore: cast_nullable_to_non_nullable
as String?,reporterAvatar: freezed == reporterAvatar ? _self.reporterAvatar : reporterAvatar // ignore: cast_nullable_to_non_nullable
as String?,reportedUserId: null == reportedUserId ? _self.reportedUserId : reportedUserId // ignore: cast_nullable_to_non_nullable
as String,reportedUserName: freezed == reportedUserName ? _self.reportedUserName : reportedUserName // ignore: cast_nullable_to_non_nullable
as String?,reportedUserAvatar: freezed == reportedUserAvatar ? _self.reportedUserAvatar : reportedUserAvatar // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,contentId: freezed == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String?,contentPreview: freezed == contentPreview ? _self.contentPreview : contentPreview // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,moderatorNotes: freezed == moderatorNotes ? _self.moderatorNotes : moderatorNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModerationAction {

 String get id; String get userId; String? get userName; String? get userAvatar; String get action; String? get reason; String? get duration; String? get contentType; String? get contentId; String? get moderatorId; String? get moderatorName; String? get createdAt;
/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationActionCopyWith<ModerationAction> get copyWith => _$ModerationActionCopyWithImpl<ModerationAction>(this as ModerationAction, _$identity);

  /// Serializes this ModerationAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationAction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.action, action) || other.action == action)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.moderatorId, moderatorId) || other.moderatorId == moderatorId)&&(identical(other.moderatorName, moderatorName) || other.moderatorName == moderatorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userAvatar,action,reason,duration,contentType,contentId,moderatorId,moderatorName,createdAt);

@override
String toString() {
  return 'ModerationAction(id: $id, userId: $userId, userName: $userName, userAvatar: $userAvatar, action: $action, reason: $reason, duration: $duration, contentType: $contentType, contentId: $contentId, moderatorId: $moderatorId, moderatorName: $moderatorName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ModerationActionCopyWith<$Res>  {
  factory $ModerationActionCopyWith(ModerationAction value, $Res Function(ModerationAction) _then) = _$ModerationActionCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? userName, String? userAvatar, String action, String? reason, String? duration, String? contentType, String? contentId, String? moderatorId, String? moderatorName, String? createdAt
});




}
/// @nodoc
class _$ModerationActionCopyWithImpl<$Res>
    implements $ModerationActionCopyWith<$Res> {
  _$ModerationActionCopyWithImpl(this._self, this._then);

  final ModerationAction _self;
  final $Res Function(ModerationAction) _then;

/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = freezed,Object? userAvatar = freezed,Object? action = null,Object? reason = freezed,Object? duration = freezed,Object? contentType = freezed,Object? contentId = freezed,Object? moderatorId = freezed,Object? moderatorName = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,contentId: freezed == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String?,moderatorId: freezed == moderatorId ? _self.moderatorId : moderatorId // ignore: cast_nullable_to_non_nullable
as String?,moderatorName: freezed == moderatorName ? _self.moderatorName : moderatorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationAction].
extension ModerationActionPatterns on ModerationAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationAction value)  $default,){
final _that = this;
switch (_that) {
case _ModerationAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationAction value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? userName,  String? userAvatar,  String action,  String? reason,  String? duration,  String? contentType,  String? contentId,  String? moderatorId,  String? moderatorName,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userAvatar,_that.action,_that.reason,_that.duration,_that.contentType,_that.contentId,_that.moderatorId,_that.moderatorName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? userName,  String? userAvatar,  String action,  String? reason,  String? duration,  String? contentType,  String? contentId,  String? moderatorId,  String? moderatorName,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ModerationAction():
return $default(_that.id,_that.userId,_that.userName,_that.userAvatar,_that.action,_that.reason,_that.duration,_that.contentType,_that.contentId,_that.moderatorId,_that.moderatorName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? userName,  String? userAvatar,  String action,  String? reason,  String? duration,  String? contentType,  String? contentId,  String? moderatorId,  String? moderatorName,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ModerationAction() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userAvatar,_that.action,_that.reason,_that.duration,_that.contentType,_that.contentId,_that.moderatorId,_that.moderatorName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationAction implements ModerationAction {
  const _ModerationAction({required this.id, required this.userId, this.userName, this.userAvatar, required this.action, this.reason, this.duration, this.contentType, this.contentId, this.moderatorId, this.moderatorName, this.createdAt});
  factory _ModerationAction.fromJson(Map<String, dynamic> json) => _$ModerationActionFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? userName;
@override final  String? userAvatar;
@override final  String action;
@override final  String? reason;
@override final  String? duration;
@override final  String? contentType;
@override final  String? contentId;
@override final  String? moderatorId;
@override final  String? moderatorName;
@override final  String? createdAt;

/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationActionCopyWith<_ModerationAction> get copyWith => __$ModerationActionCopyWithImpl<_ModerationAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationAction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.action, action) || other.action == action)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.moderatorId, moderatorId) || other.moderatorId == moderatorId)&&(identical(other.moderatorName, moderatorName) || other.moderatorName == moderatorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userAvatar,action,reason,duration,contentType,contentId,moderatorId,moderatorName,createdAt);

@override
String toString() {
  return 'ModerationAction(id: $id, userId: $userId, userName: $userName, userAvatar: $userAvatar, action: $action, reason: $reason, duration: $duration, contentType: $contentType, contentId: $contentId, moderatorId: $moderatorId, moderatorName: $moderatorName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ModerationActionCopyWith<$Res> implements $ModerationActionCopyWith<$Res> {
  factory _$ModerationActionCopyWith(_ModerationAction value, $Res Function(_ModerationAction) _then) = __$ModerationActionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? userName, String? userAvatar, String action, String? reason, String? duration, String? contentType, String? contentId, String? moderatorId, String? moderatorName, String? createdAt
});




}
/// @nodoc
class __$ModerationActionCopyWithImpl<$Res>
    implements _$ModerationActionCopyWith<$Res> {
  __$ModerationActionCopyWithImpl(this._self, this._then);

  final _ModerationAction _self;
  final $Res Function(_ModerationAction) _then;

/// Create a copy of ModerationAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = freezed,Object? userAvatar = freezed,Object? action = null,Object? reason = freezed,Object? duration = freezed,Object? contentType = freezed,Object? contentId = freezed,Object? moderatorId = freezed,Object? moderatorName = freezed,Object? createdAt = freezed,}) {
  return _then(_ModerationAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,contentId: freezed == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String?,moderatorId: freezed == moderatorId ? _self.moderatorId : moderatorId // ignore: cast_nullable_to_non_nullable
as String?,moderatorName: freezed == moderatorName ? _self.moderatorName : moderatorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BannedUser {

 String get id; String get userId; String? get username; String? get firstName; String? get lastName; String? get email; String? get profilePicture; String? get banReason; String? get bannedAt; String? get bannedUntil; bool? get isPermanent; String? get bannedBy; String? get bannedByName;
/// Create a copy of BannedUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BannedUserCopyWith<BannedUser> get copyWith => _$BannedUserCopyWithImpl<BannedUser>(this as BannedUser, _$identity);

  /// Serializes this BannedUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BannedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.banReason, banReason) || other.banReason == banReason)&&(identical(other.bannedAt, bannedAt) || other.bannedAt == bannedAt)&&(identical(other.bannedUntil, bannedUntil) || other.bannedUntil == bannedUntil)&&(identical(other.isPermanent, isPermanent) || other.isPermanent == isPermanent)&&(identical(other.bannedBy, bannedBy) || other.bannedBy == bannedBy)&&(identical(other.bannedByName, bannedByName) || other.bannedByName == bannedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,username,firstName,lastName,email,profilePicture,banReason,bannedAt,bannedUntil,isPermanent,bannedBy,bannedByName);

@override
String toString() {
  return 'BannedUser(id: $id, userId: $userId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, banReason: $banReason, bannedAt: $bannedAt, bannedUntil: $bannedUntil, isPermanent: $isPermanent, bannedBy: $bannedBy, bannedByName: $bannedByName)';
}


}

/// @nodoc
abstract mixin class $BannedUserCopyWith<$Res>  {
  factory $BannedUserCopyWith(BannedUser value, $Res Function(BannedUser) _then) = _$BannedUserCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? username, String? firstName, String? lastName, String? email, String? profilePicture, String? banReason, String? bannedAt, String? bannedUntil, bool? isPermanent, String? bannedBy, String? bannedByName
});




}
/// @nodoc
class _$BannedUserCopyWithImpl<$Res>
    implements $BannedUserCopyWith<$Res> {
  _$BannedUserCopyWithImpl(this._self, this._then);

  final BannedUser _self;
  final $Res Function(BannedUser) _then;

/// Create a copy of BannedUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,Object? profilePicture = freezed,Object? banReason = freezed,Object? bannedAt = freezed,Object? bannedUntil = freezed,Object? isPermanent = freezed,Object? bannedBy = freezed,Object? bannedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,banReason: freezed == banReason ? _self.banReason : banReason // ignore: cast_nullable_to_non_nullable
as String?,bannedAt: freezed == bannedAt ? _self.bannedAt : bannedAt // ignore: cast_nullable_to_non_nullable
as String?,bannedUntil: freezed == bannedUntil ? _self.bannedUntil : bannedUntil // ignore: cast_nullable_to_non_nullable
as String?,isPermanent: freezed == isPermanent ? _self.isPermanent : isPermanent // ignore: cast_nullable_to_non_nullable
as bool?,bannedBy: freezed == bannedBy ? _self.bannedBy : bannedBy // ignore: cast_nullable_to_non_nullable
as String?,bannedByName: freezed == bannedByName ? _self.bannedByName : bannedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BannedUser].
extension BannedUserPatterns on BannedUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BannedUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BannedUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BannedUser value)  $default,){
final _that = this;
switch (_that) {
case _BannedUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BannedUser value)?  $default,){
final _that = this;
switch (_that) {
case _BannedUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? banReason,  String? bannedAt,  String? bannedUntil,  bool? isPermanent,  String? bannedBy,  String? bannedByName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BannedUser() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.banReason,_that.bannedAt,_that.bannedUntil,_that.isPermanent,_that.bannedBy,_that.bannedByName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? banReason,  String? bannedAt,  String? bannedUntil,  bool? isPermanent,  String? bannedBy,  String? bannedByName)  $default,) {final _that = this;
switch (_that) {
case _BannedUser():
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.banReason,_that.bannedAt,_that.bannedUntil,_that.isPermanent,_that.bannedBy,_that.bannedByName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? banReason,  String? bannedAt,  String? bannedUntil,  bool? isPermanent,  String? bannedBy,  String? bannedByName)?  $default,) {final _that = this;
switch (_that) {
case _BannedUser() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.banReason,_that.bannedAt,_that.bannedUntil,_that.isPermanent,_that.bannedBy,_that.bannedByName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BannedUser implements BannedUser {
  const _BannedUser({required this.id, required this.userId, this.username, this.firstName, this.lastName, this.email, this.profilePicture, this.banReason, this.bannedAt, this.bannedUntil, this.isPermanent, this.bannedBy, this.bannedByName});
  factory _BannedUser.fromJson(Map<String, dynamic> json) => _$BannedUserFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? username;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? email;
@override final  String? profilePicture;
@override final  String? banReason;
@override final  String? bannedAt;
@override final  String? bannedUntil;
@override final  bool? isPermanent;
@override final  String? bannedBy;
@override final  String? bannedByName;

/// Create a copy of BannedUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BannedUserCopyWith<_BannedUser> get copyWith => __$BannedUserCopyWithImpl<_BannedUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BannedUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BannedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.banReason, banReason) || other.banReason == banReason)&&(identical(other.bannedAt, bannedAt) || other.bannedAt == bannedAt)&&(identical(other.bannedUntil, bannedUntil) || other.bannedUntil == bannedUntil)&&(identical(other.isPermanent, isPermanent) || other.isPermanent == isPermanent)&&(identical(other.bannedBy, bannedBy) || other.bannedBy == bannedBy)&&(identical(other.bannedByName, bannedByName) || other.bannedByName == bannedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,username,firstName,lastName,email,profilePicture,banReason,bannedAt,bannedUntil,isPermanent,bannedBy,bannedByName);

@override
String toString() {
  return 'BannedUser(id: $id, userId: $userId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, banReason: $banReason, bannedAt: $bannedAt, bannedUntil: $bannedUntil, isPermanent: $isPermanent, bannedBy: $bannedBy, bannedByName: $bannedByName)';
}


}

/// @nodoc
abstract mixin class _$BannedUserCopyWith<$Res> implements $BannedUserCopyWith<$Res> {
  factory _$BannedUserCopyWith(_BannedUser value, $Res Function(_BannedUser) _then) = __$BannedUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? username, String? firstName, String? lastName, String? email, String? profilePicture, String? banReason, String? bannedAt, String? bannedUntil, bool? isPermanent, String? bannedBy, String? bannedByName
});




}
/// @nodoc
class __$BannedUserCopyWithImpl<$Res>
    implements _$BannedUserCopyWith<$Res> {
  __$BannedUserCopyWithImpl(this._self, this._then);

  final _BannedUser _self;
  final $Res Function(_BannedUser) _then;

/// Create a copy of BannedUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,Object? profilePicture = freezed,Object? banReason = freezed,Object? bannedAt = freezed,Object? bannedUntil = freezed,Object? isPermanent = freezed,Object? bannedBy = freezed,Object? bannedByName = freezed,}) {
  return _then(_BannedUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,banReason: freezed == banReason ? _self.banReason : banReason // ignore: cast_nullable_to_non_nullable
as String?,bannedAt: freezed == bannedAt ? _self.bannedAt : bannedAt // ignore: cast_nullable_to_non_nullable
as String?,bannedUntil: freezed == bannedUntil ? _self.bannedUntil : bannedUntil // ignore: cast_nullable_to_non_nullable
as String?,isPermanent: freezed == isPermanent ? _self.isPermanent : isPermanent // ignore: cast_nullable_to_non_nullable
as bool?,bannedBy: freezed == bannedBy ? _self.bannedBy : bannedBy // ignore: cast_nullable_to_non_nullable
as String?,bannedByName: freezed == bannedByName ? _self.bannedByName : bannedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PendingVerification {

 String get id; String get userId; String? get username; String? get firstName; String? get lastName; String? get email; String? get profilePicture; String? get university; String? get studentId; String? get universityEmail; String? get submittedAt; String? get verificationMethod; List<String>? get documents;
/// Create a copy of PendingVerification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingVerificationCopyWith<PendingVerification> get copyWith => _$PendingVerificationCopyWithImpl<PendingVerification>(this as PendingVerification, _$identity);

  /// Serializes this PendingVerification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingVerification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.university, university) || other.university == university)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.universityEmail, universityEmail) || other.universityEmail == universityEmail)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&const DeepCollectionEquality().equals(other.documents, documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,username,firstName,lastName,email,profilePicture,university,studentId,universityEmail,submittedAt,verificationMethod,const DeepCollectionEquality().hash(documents));

@override
String toString() {
  return 'PendingVerification(id: $id, userId: $userId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, university: $university, studentId: $studentId, universityEmail: $universityEmail, submittedAt: $submittedAt, verificationMethod: $verificationMethod, documents: $documents)';
}


}

/// @nodoc
abstract mixin class $PendingVerificationCopyWith<$Res>  {
  factory $PendingVerificationCopyWith(PendingVerification value, $Res Function(PendingVerification) _then) = _$PendingVerificationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? username, String? firstName, String? lastName, String? email, String? profilePicture, String? university, String? studentId, String? universityEmail, String? submittedAt, String? verificationMethod, List<String>? documents
});




}
/// @nodoc
class _$PendingVerificationCopyWithImpl<$Res>
    implements $PendingVerificationCopyWith<$Res> {
  _$PendingVerificationCopyWithImpl(this._self, this._then);

  final PendingVerification _self;
  final $Res Function(PendingVerification) _then;

/// Create a copy of PendingVerification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,Object? profilePicture = freezed,Object? university = freezed,Object? studentId = freezed,Object? universityEmail = freezed,Object? submittedAt = freezed,Object? verificationMethod = freezed,Object? documents = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,universityEmail: freezed == universityEmail ? _self.universityEmail : universityEmail // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verificationMethod: freezed == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String?,documents: freezed == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingVerification].
extension PendingVerificationPatterns on PendingVerification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingVerification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingVerification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingVerification value)  $default,){
final _that = this;
switch (_that) {
case _PendingVerification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingVerification value)?  $default,){
final _that = this;
switch (_that) {
case _PendingVerification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? university,  String? studentId,  String? universityEmail,  String? submittedAt,  String? verificationMethod,  List<String>? documents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingVerification() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.university,_that.studentId,_that.universityEmail,_that.submittedAt,_that.verificationMethod,_that.documents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? university,  String? studentId,  String? universityEmail,  String? submittedAt,  String? verificationMethod,  List<String>? documents)  $default,) {final _that = this;
switch (_that) {
case _PendingVerification():
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.university,_that.studentId,_that.universityEmail,_that.submittedAt,_that.verificationMethod,_that.documents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? username,  String? firstName,  String? lastName,  String? email,  String? profilePicture,  String? university,  String? studentId,  String? universityEmail,  String? submittedAt,  String? verificationMethod,  List<String>? documents)?  $default,) {final _that = this;
switch (_that) {
case _PendingVerification() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.university,_that.studentId,_that.universityEmail,_that.submittedAt,_that.verificationMethod,_that.documents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingVerification implements PendingVerification {
  const _PendingVerification({required this.id, required this.userId, this.username, this.firstName, this.lastName, this.email, this.profilePicture, this.university, this.studentId, this.universityEmail, this.submittedAt, this.verificationMethod, final  List<String>? documents}): _documents = documents;
  factory _PendingVerification.fromJson(Map<String, dynamic> json) => _$PendingVerificationFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? username;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? email;
@override final  String? profilePicture;
@override final  String? university;
@override final  String? studentId;
@override final  String? universityEmail;
@override final  String? submittedAt;
@override final  String? verificationMethod;
 final  List<String>? _documents;
@override List<String>? get documents {
  final value = _documents;
  if (value == null) return null;
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of PendingVerification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingVerificationCopyWith<_PendingVerification> get copyWith => __$PendingVerificationCopyWithImpl<_PendingVerification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingVerificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingVerification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.university, university) || other.university == university)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.universityEmail, universityEmail) || other.universityEmail == universityEmail)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&const DeepCollectionEquality().equals(other._documents, _documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,username,firstName,lastName,email,profilePicture,university,studentId,universityEmail,submittedAt,verificationMethod,const DeepCollectionEquality().hash(_documents));

@override
String toString() {
  return 'PendingVerification(id: $id, userId: $userId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, university: $university, studentId: $studentId, universityEmail: $universityEmail, submittedAt: $submittedAt, verificationMethod: $verificationMethod, documents: $documents)';
}


}

/// @nodoc
abstract mixin class _$PendingVerificationCopyWith<$Res> implements $PendingVerificationCopyWith<$Res> {
  factory _$PendingVerificationCopyWith(_PendingVerification value, $Res Function(_PendingVerification) _then) = __$PendingVerificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? username, String? firstName, String? lastName, String? email, String? profilePicture, String? university, String? studentId, String? universityEmail, String? submittedAt, String? verificationMethod, List<String>? documents
});




}
/// @nodoc
class __$PendingVerificationCopyWithImpl<$Res>
    implements _$PendingVerificationCopyWith<$Res> {
  __$PendingVerificationCopyWithImpl(this._self, this._then);

  final _PendingVerification _self;
  final $Res Function(_PendingVerification) _then;

/// Create a copy of PendingVerification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? username = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,Object? profilePicture = freezed,Object? university = freezed,Object? studentId = freezed,Object? universityEmail = freezed,Object? submittedAt = freezed,Object? verificationMethod = freezed,Object? documents = freezed,}) {
  return _then(_PendingVerification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,profilePicture: freezed == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,universityEmail: freezed == universityEmail ? _self.universityEmail : universityEmail // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verificationMethod: freezed == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String?,documents: freezed == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
