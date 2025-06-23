import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/notification_provider.dart';
import '../../services/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/curved_container.dart';
import '../common/glass_container.dart';

class NotificationPanel extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const NotificationPanel({
    super.key,
    this.onClose,
  });

  @override
  ConsumerState<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends ConsumerState<NotificationPanel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  NotificationType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(filteredNotificationsProvider(_selectedFilter));
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Container(
      width: 380,
      height: 600,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(unreadCount),
          _buildFilterTabs(),
          Expanded(
            child: _buildNotificationsList(notifications),
          ),
          _buildActions(),
        ],
      ),
    ).animate(controller: _animationController).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      curve: Curves.elasticOut,
    ).fadeIn();
  }

  Widget _buildHeader(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.dubaiGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.notification,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(
                Iconsax.close_circle,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      (null, 'All', Iconsax.notification),
      (NotificationType.eventReminder, 'Reminders', Iconsax.clock),
      (NotificationType.newEvent, 'New Events', Iconsax.star),
      (NotificationType.socialActivity, 'Social', Iconsax.people),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter.$1;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.dubaiGradient : null,
                  color: isSelected ? null : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.transparent 
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.$3,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filter.$2,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationItem(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onDismiss: () => _handleNotificationDismiss(notification),
        ).animate(delay: Duration(milliseconds: index * 50))
         .slideX(begin: 1, curve: Curves.easeOutQuart)
         .fadeIn();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.notification_status,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final notifications = ref.watch(notificationsProvider);
    final hasNotifications = notifications.isNotEmpty;
    final hasUnread = notifications.any((n) => !n.isRead);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (hasUnread)
            Expanded(
              child: _ActionButton(
                onPressed: () {
                  ref.read(notificationsProvider.notifier).markAllAsRead();
                },
                icon: Iconsax.tick_circle,
                text: 'Mark all read',
                color: AppTheme.primaryColor,
              ),
            ),
          if (hasUnread && hasNotifications) const SizedBox(width: 12),
          if (hasNotifications)
            Expanded(
              child: _ActionButton(
                onPressed: () {
                  _showClearConfirmation();
                },
                icon: Iconsax.trash,
                text: 'Clear all',
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    
    // Navigate if action URL provided
    if (notification.actionUrl != null) {
      // Handle navigation based on actionUrl
      // This would integrate with your navigation system
    }
  }

  void _handleNotificationDismiss(AppNotification notification) {
    ref.read(notificationsProvider.notifier).removeNotification(notification.id);
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear all notifications?'),
        content: const Text(
          'This action cannot be undone. All notifications will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notificationsProvider.notifier).clearAll();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Iconsax.trash,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead 
                  ? Colors.grey.withOpacity(0.1)
                  : AppTheme.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityBadge(),
                          const Spacer(),
                          Text(
                            _formatTime(notification.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.eventReminder:
        icon = Iconsax.clock;
        color = Colors.orange;
        break;
      case NotificationType.newEvent:
        icon = Iconsax.star;
        color = AppTheme.primaryColor;
        break;
      case NotificationType.eventUpdate:
        icon = Iconsax.info_circle;
        color = Colors.blue;
        break;
      case NotificationType.bookingConfirmation:
        icon = Iconsax.tick_circle;
        color = Colors.green;
        break;
      case NotificationType.eventCancellation:
        icon = Iconsax.close_circle;
        color = Colors.red;
        break;
      case NotificationType.socialActivity:
        icon = Iconsax.people;
        color = Colors.purple;
        break;
      case NotificationType.promotionalOffer:
        icon = Iconsax.gift;
        color = Colors.pink;
        break;
      default:
        icon = Iconsax.notification;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildPriorityBadge() {
    if (notification.priority == NotificationPriority.normal ||
        notification.priority == NotificationPriority.low) {
      return const SizedBox.shrink();
    }

    String text;
    Color color;

    switch (notification.priority) {
      case NotificationPriority.high:
        text = 'HIGH';
        color = Colors.orange;
        break;
      case NotificationPriority.urgent:
        text = 'URGENT';
        color = Colors.red;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
} 