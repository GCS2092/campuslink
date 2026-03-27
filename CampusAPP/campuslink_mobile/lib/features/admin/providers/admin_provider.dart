import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';
import '../models/admin_model.dart';

// ============ DASHBOARD STATS PROVIDERS ============

final adminDashboardStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getAdminDashboardStats();
});

final universityAdminDashboardStatsProvider = FutureProvider<UniversityAdminDashboardStats>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getUniversityAdminDashboardStats();
});

final classLeaderDashboardStatsProvider = FutureProvider<ClassLeaderDashboardStats>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getClassLeaderDashboardStats();
});

// ============ PENDING STUDENTS PROVIDERS ============

final pendingStudentsProvider = FutureProvider<List<PendingStudent>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getPendingStudents();
});

// ============ CLASS LEADERS PROVIDERS ============

final classLeadersProvider = FutureProvider<List<ClassLeader>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getClassLeaders();
});

final classLeadersByUniversityProvider = FutureProvider<List<ClassLeader>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getClassLeadersByUniversity();
});

// ============ ADMIN ACTIONS NOTIFIER ============

final adminActionsProvider =
    NotifierProvider<AdminActionsNotifier, AsyncValue<void>>(
  AdminActionsNotifier.new,
);

class AdminActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> activateStudent(String id) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(adminServiceProvider);
      await service.activateStudent(id);
      ref.invalidate(pendingStudentsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deactivateStudent(String id) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(adminServiceProvider);
      await service.deactivateStudent(id);
      ref.invalidate(pendingStudentsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> assignClassLeader(String userId) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(adminServiceProvider);
      await service.assignClassLeader(userId);
      ref.invalidate(classLeadersProvider);
      ref.invalidate(classLeadersByUniversityProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> revokeClassLeader(String userId) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(adminServiceProvider);
      await service.revokeClassLeader(userId);
      ref.invalidate(classLeadersProvider);
      ref.invalidate(classLeadersByUniversityProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createStudent(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(adminServiceProvider);
      await service.createStudent(data);
      ref.invalidate(pendingStudentsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
