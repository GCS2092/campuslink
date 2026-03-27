import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

// Provider for notifications list
final notificationsProvider = FutureProvider.family<List<Notification>, NotificationFilterParams>((ref, params) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(
    isRead: params.isRead,
    type: params.type,
    page: params.page,
    pageSize: params.pageSize,
  );
});

// Provider for a single notification
final notificationProvider = FutureProvider.family<Notification, String>((ref, id) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotification(id);
});

// Provider for unread notifications count
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount();
});

// Provider for notification preferences
final notificationPreferencesProvider = FutureProvider<NotificationPreferences>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getPreferences();
});

// State notifier for notifications
class NotificationsNotifier extends Notifier<NotificationsState> {
  NotificationService get _service => ref.read(notificationServiceProvider);

  @override
  NotificationsState build() => const NotificationsState();

  Future<void> loadNotifications({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, notifications: []);
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newNotifications = await _service.getNotifications(
        isRead: state.isRead,
        type: state.type,
        page: state.page,
        pageSize: state.pageSize,
      );

      final allNotifications = refresh
          ? newNotifications
          : [...state.notifications, ...newNotifications];

      state = state.copyWith(
        notifications: allNotifications,
        isLoading: false,
        hasMore: newNotifications.length == state.pageSize,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true, readAt: DateTime.now().toIso8601String());
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        return n.copyWith(isRead: true, readAt: DateTime.now().toIso8601String());
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      // Update local state
      final updatedNotifications = state.notifications.where((n) => n.id != notificationId).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setIsRead(bool? isRead) {
    state = state.copyWith(isRead: isRead, page: 1);
    loadNotifications(refresh: true);
  }

  void setType(String? type) {
    state = state.copyWith(type: type, page: 1);
    loadNotifications(refresh: true);
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);

// State class
class NotificationsState {
  final List<Notification> notifications;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;
  final int pageSize;
  final bool? isRead;
  final String? type;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 20,
    this.isRead,
    this.type,
  });

  NotificationsState copyWith({
    List<Notification>? notifications,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
    int? pageSize,
    bool? isRead,
    String? type,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

// Filter params class
class NotificationFilterParams {
  final bool? isRead;
  final String? type;
  final int? page;
  final int? pageSize;

  const NotificationFilterParams({
    this.isRead,
    this.type,
    this.page,
    this.pageSize,
  });
}
