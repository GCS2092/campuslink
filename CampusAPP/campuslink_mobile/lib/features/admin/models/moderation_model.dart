import 'package:freezed_annotation/freezed_annotation.dart';

part 'moderation_model.freezed.dart';
part 'moderation_model.g.dart';

// ============ REPORTS ============

@freezed
abstract class Report with _$Report {
  const factory Report({
    required String id,
    required String reporterId,
    String? reporterName,
    String? reporterAvatar,
    required String reportedUserId,
    String? reportedUserName,
    String? reportedUserAvatar,
    required String type,
    required String reason,
    String? description,
    String? contentType,
    String? contentId,
    String? contentPreview,
    @Default('pending') String status,
    String? createdAt,
    String? resolvedAt,
    String? resolvedBy,
    String? resolution,
    String? moderatorNotes,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) =>
      _$ReportFromJson(json);
}

// ============ MODERATION ACTIONS ============

@freezed
abstract class ModerationAction with _$ModerationAction {
  const factory ModerationAction({
    required String id,
    required String userId,
    String? userName,
    String? userAvatar,
    required String action,
    String? reason,
    String? duration,
    String? contentType,
    String? contentId,
    String? moderatorId,
    String? moderatorName,
    String? createdAt,
  }) = _ModerationAction;

  factory ModerationAction.fromJson(Map<String, dynamic> json) =>
      _$ModerationActionFromJson(json);
}

// ============ BANNED USERS ============

@freezed
abstract class BannedUser with _$BannedUser {
  const factory BannedUser({
    required String id,
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
    String? banReason,
    String? bannedAt,
    String? bannedUntil,
    bool? isPermanent,
    String? bannedBy,
    String? bannedByName,
  }) = _BannedUser;

  factory BannedUser.fromJson(Map<String, dynamic> json) =>
      _$BannedUserFromJson(json);
}

// ============ PENDING VERIFICATIONS ============

@freezed
abstract class PendingVerification with _$PendingVerification {
  const factory PendingVerification({
    required String id,
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
    String? university,
    String? studentId,
    String? universityEmail,
    String? submittedAt,
    String? verificationMethod,
    List<String>? documents,
  }) = _PendingVerification;

  factory PendingVerification.fromJson(Map<String, dynamic> json) =>
      _$PendingVerificationFromJson(json);
}
