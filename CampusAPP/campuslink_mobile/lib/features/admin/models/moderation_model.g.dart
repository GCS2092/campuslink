// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  id: json['id'] as String,
  reporterId: json['reporterId'] as String,
  reporterName: json['reporterName'] as String?,
  reporterAvatar: json['reporterAvatar'] as String?,
  reportedUserId: json['reportedUserId'] as String,
  reportedUserName: json['reportedUserName'] as String?,
  reportedUserAvatar: json['reportedUserAvatar'] as String?,
  type: json['type'] as String,
  reason: json['reason'] as String,
  description: json['description'] as String?,
  contentType: json['contentType'] as String?,
  contentId: json['contentId'] as String?,
  contentPreview: json['contentPreview'] as String?,
  status: json['status'] as String? ?? 'pending',
  createdAt: json['createdAt'] as String?,
  resolvedAt: json['resolvedAt'] as String?,
  resolvedBy: json['resolvedBy'] as String?,
  resolution: json['resolution'] as String?,
  moderatorNotes: json['moderatorNotes'] as String?,
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'id': instance.id,
  'reporterId': instance.reporterId,
  'reporterName': instance.reporterName,
  'reporterAvatar': instance.reporterAvatar,
  'reportedUserId': instance.reportedUserId,
  'reportedUserName': instance.reportedUserName,
  'reportedUserAvatar': instance.reportedUserAvatar,
  'type': instance.type,
  'reason': instance.reason,
  'description': instance.description,
  'contentType': instance.contentType,
  'contentId': instance.contentId,
  'contentPreview': instance.contentPreview,
  'status': instance.status,
  'createdAt': instance.createdAt,
  'resolvedAt': instance.resolvedAt,
  'resolvedBy': instance.resolvedBy,
  'resolution': instance.resolution,
  'moderatorNotes': instance.moderatorNotes,
};

_ModerationAction _$ModerationActionFromJson(Map<String, dynamic> json) =>
    _ModerationAction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      action: json['action'] as String,
      reason: json['reason'] as String?,
      duration: json['duration'] as String?,
      contentType: json['contentType'] as String?,
      contentId: json['contentId'] as String?,
      moderatorId: json['moderatorId'] as String?,
      moderatorName: json['moderatorName'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$ModerationActionToJson(_ModerationAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'action': instance.action,
      'reason': instance.reason,
      'duration': instance.duration,
      'contentType': instance.contentType,
      'contentId': instance.contentId,
      'moderatorId': instance.moderatorId,
      'moderatorName': instance.moderatorName,
      'createdAt': instance.createdAt,
    };

_BannedUser _$BannedUserFromJson(Map<String, dynamic> json) => _BannedUser(
  id: json['id'] as String,
  userId: json['userId'] as String,
  username: json['username'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  profilePicture: json['profilePicture'] as String?,
  banReason: json['banReason'] as String?,
  bannedAt: json['bannedAt'] as String?,
  bannedUntil: json['bannedUntil'] as String?,
  isPermanent: json['isPermanent'] as bool?,
  bannedBy: json['bannedBy'] as String?,
  bannedByName: json['bannedByName'] as String?,
);

Map<String, dynamic> _$BannedUserToJson(_BannedUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'profilePicture': instance.profilePicture,
      'banReason': instance.banReason,
      'bannedAt': instance.bannedAt,
      'bannedUntil': instance.bannedUntil,
      'isPermanent': instance.isPermanent,
      'bannedBy': instance.bannedBy,
      'bannedByName': instance.bannedByName,
    };

_PendingVerification _$PendingVerificationFromJson(Map<String, dynamic> json) =>
    _PendingVerification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      profilePicture: json['profilePicture'] as String?,
      university: json['university'] as String?,
      studentId: json['studentId'] as String?,
      universityEmail: json['universityEmail'] as String?,
      submittedAt: json['submittedAt'] as String?,
      verificationMethod: json['verificationMethod'] as String?,
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PendingVerificationToJson(
  _PendingVerification instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'username': instance.username,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'profilePicture': instance.profilePicture,
  'university': instance.university,
  'studentId': instance.studentId,
  'universityEmail': instance.universityEmail,
  'submittedAt': instance.submittedAt,
  'verificationMethod': instance.verificationMethod,
  'documents': instance.documents,
};
