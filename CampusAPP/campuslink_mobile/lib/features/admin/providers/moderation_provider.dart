import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/moderation_service.dart';
import '../models/moderation_model.dart';

// ============ REPORTS PROVIDERS ============

final reportsProvider = FutureProvider.family<List<Report>, ReportFilter>((ref, filter) async {
  final service = ref.watch(moderationServiceProvider);
  return service.getReports(
    status: filter.status,
    type: filter.type,
    page: filter.page,
    pageSize: filter.pageSize,
  );
});

class ReportFilter {
  final String? status;
  final String? type;
  final int? page;
  final int? pageSize;

  const ReportFilter({
    this.status,
    this.type,
    this.page,
    this.pageSize,
  });
}

final reportDetailProvider = FutureProvider.family<Report, String>((ref, id) async {
  final service = ref.watch(moderationServiceProvider);
  return service.getReport(id);
});

// ============ MODERATIONS PROVIDERS ============

final moderationsProvider = FutureProvider.family<List<ModerationAction>, String?>((ref, userId) async {
  final service = ref.watch(moderationServiceProvider);
  return service.getModerations(userId: userId);
});

final bannedUsersProvider = FutureProvider<List<BannedUser>>((ref) async {
  final service = ref.watch(moderationServiceProvider);
  return service.getBannedUsers();
});

final pendingVerificationsProvider = FutureProvider<List<PendingVerification>>((ref) async {
  final service = ref.watch(moderationServiceProvider);
  return service.getPendingVerifications();
});

// ============ MODERATION ACTIONS NOTIFIER ============

final moderationActionsProvider =
    NotifierProvider<ModerationActionsNotifier, AsyncValue<void>>(
  ModerationActionsNotifier.new,
);

class ModerationActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> resolveReport(String id, String action, {String? notes}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(moderationServiceProvider);
      await service.resolveReport(id, action, notes: notes);
      ref.invalidate(reportsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createReport(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(moderationServiceProvider);
      await service.createReport(data);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> banUser(String userId, {String? reason, int? days}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(moderationServiceProvider);
      await service.banUser(userId, reason: reason, days: days);
      ref.invalidate(bannedUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unbanUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(moderationServiceProvider);
      await service.unbanUser(userId);
      ref.invalidate(bannedUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verifyUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(moderationServiceProvider);
      await service.verifyUser(userId);
      ref.invalidate(pendingVerificationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectUser(String userId, {String? reason}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(moderationServiceProvider);
      await service.rejectUser(userId, reason: reason);
      ref.invalidate(pendingVerificationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
