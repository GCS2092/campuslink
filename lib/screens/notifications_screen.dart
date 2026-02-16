import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification.dart' as models;
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/premium_design.dart';
import '../utils/toast_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<models.Notification> _notifications = [];
  bool _isLoading = true;
  String _filter = 'all';
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadUnreadCount();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.getNotifications(
        isRead: _filter == 'unread' ? false : null,
      );
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      setState(() => _unreadCount = count);
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  Future<void> _handleMarkAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _handleDeleteNotification(String id) async {
    try {
      final success = await _notificationService.deleteNotification(id);
      if (success) {
        await _loadNotifications();
        await _loadUnreadCount();
        if (mounted) {
          ToastService.showSuccess('Notification supprimée');
        }
      } else {
        if (mounted) {
          ToastService.showError('Erreur lors de la suppression');
        }
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      if (mounted) {
        ToastService.showError('Erreur: ${e.toString()}');
      }
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications();
      await _loadUnreadCount();
      if (mounted) {
        ToastService.showSuccess('Toutes les notifications ont été marquées comme lues');
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'friend_request':
        return Icons.person_add;
      case 'friend_accepted':
        return Icons.check_circle;
      case 'event_invitation':
        return Icons.event;
      case 'group_invitation':
        return Icons.group_add;
      case 'participation':
        return Icons.people;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'friend_request':
      case 'friend_accepted':
        return AppColors.primary;
      case 'event_invitation':
      case 'participation':
        return AppColors.accent;
      case 'group_invitation':
        return AppColors.secondary;
      case 'message':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: PremiumDesign.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_unreadCount > 0 && _filter == 'all')
            TextButton.icon(
              onPressed: _handleMarkAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Tout marquer'),
              style: TextButton.styleFrom(foregroundColor: isDark ? Colors.white : AppColors.primary),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? PremiumDesign.surfaceElevatedDark : PremiumDesign.surfaceElevated,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButtonPremium(
                    label: 'Toutes',
                    count: _notifications.length,
                    isSelected: _filter == 'all',
                    isDark: isDark,
                    onTap: () {
                      setState(() => _filter = 'all');
                      _loadNotifications();
                    },
                  ),
                ),
                Expanded(
                  child: _FilterButtonPremium(
                    label: 'Non lues',
                    count: _unreadCount,
                    isSelected: _filter == 'unread',
                    isDark: isDark,
                    onTap: () {
                      setState(() => _filter = 'unread');
                      _loadNotifications();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: PremiumCard(
                          padding: const EdgeInsets.all(PremiumDesign.spacingXXL),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: PremiumDesign.spacingL),
                              Text(
                                _filter == 'unread' ? 'Aucune notification non lue' : 'Aucune notification',
                                style: PremiumDesign.titleMedium.copyWith(
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await _loadNotifications();
                          await _loadUnreadCount();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PremiumDesign.spacingL,
                            vertical: PremiumDesign.spacingM,
                          ),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: PremiumDesign.spacingM),
                              child: _NotificationCardPremium(
                                notification: notification,
                                icon: _getNotificationIcon(notification.notificationType),
                                color: _getNotificationColor(notification.notificationType),
                                isDark: isDark,
                                onTap: () {
                                  if (!notification.isRead) {
                                    _handleMarkAsRead(notification.id);
                                  }
                                },
                                onDelete: () => _handleDeleteNotification(notification.id),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterButtonPremium extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterButtonPremium({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: PremiumDesign.spacingL),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: PremiumDesign.labelLarge.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white60 : AppColors.textSecondary),
              ),
            ),
            if (count > 0)
              Container(
                margin: const EdgeInsets.only(top: PremiumDesign.spacingXS),
                padding: const EdgeInsets.symmetric(
                  horizontal: PremiumDesign.spacingS,
                  vertical: PremiumDesign.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(PremiumDesign.radiusS),
                ),
                child: Text(
                  '$count',
                  style: PremiumDesign.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCardPremium extends StatelessWidget {
  final models.Notification notification;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCardPremium({
    required this.notification,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM yyyy');
    final createdAt = notification.createdAt;
    final isToday = createdAt.year == DateTime.now().year &&
                    createdAt.month == DateTime.now().month &&
                    createdAt.day == DateTime.now().day;

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(PremiumDesign.spacingL),
      backgroundColor: notification.isRead
          ? null
          : AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(PremiumDesign.radiusM),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: PremiumDesign.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: PremiumDesign.titleSmall.copyWith(
                    fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: PremiumDesign.spacingXS),
                Text(
                  notification.message,
                  style: PremiumDesign.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: PremiumDesign.spacingXS),
                Text(
                  isToday ? timeFormat.format(createdAt) : dateFormat.format(createdAt),
                  style: PremiumDesign.labelSmall.copyWith(
                    color: isDark ? Colors.white38 : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(bottom: PremiumDesign.spacingS),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: isDark ? Colors.white38 : AppColors.textSecondary,
                ),
                onPressed: onDelete,
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
