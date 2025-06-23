import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/notification_provider.dart';
import '../../services/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import 'notification_panel.dart';

class NotificationBell extends ConsumerStatefulWidget {
  final double size;
  final Color? color;
  final bool showPanel;

  const NotificationBell({
    super.key,
    this.size = 24,
    this.color,
    this.showPanel = true,
  });

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _badgeController;
  OverlayEntry? _overlayEntry;
  final GlobalKey _bellKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _badgeController.dispose();
    _closePanel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    
    // Listen for new notifications to trigger animations
    ref.listen(unreadNotificationCountProvider, (previous, current) {
      if (previous != null && current > previous) {
        _triggerNewNotificationAnimation();
      }
    });

    return GestureDetector(
      key: _bellKey,
      onTap: widget.showPanel ? _togglePanel : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Iconsax.notification,
              size: widget.size,
              color: widget.color ?? Colors.grey[700],
            ).animate(controller: _shakeController)
              .shake(duration: 500.ms, hz: 4, curve: Curves.easeInOut),
            
            if (unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: _buildNotificationBadge(unreadCount)
                    .animate(controller: _badgeController)
                    .scale(begin: const Offset(0, 0))
                    .then()
                    .shimmer(duration: 1000.ms, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(int count) {
    final displayCount = count > 99 ? '99+' : count.toString();
    
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF4757),
            Color(0xFFE84118),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayCount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  void _triggerNewNotificationAnimation() {
    // Shake the bell
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });

    // Animate the badge
    _badgeController.forward().then((_) {
      _badgeController.reset();
    });
  }

  void _togglePanel() {
    if (_overlayEntry != null) {
      _closePanel();
    } else {
      _openPanel();
    }
  }

  void _openPanel() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = 
        _bellKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height + 8,
        right: MediaQuery.of(context).size.width - offset.dx - size.width,
        child: Material(
          color: Colors.transparent,
          child: NotificationPanel(
            onClose: _closePanel,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closePanel() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Floating notification overlay for real-time notifications
class FloatingNotificationOverlay extends ConsumerStatefulWidget {
  const FloatingNotificationOverlay({super.key});

  @override
  ConsumerState<FloatingNotificationOverlay> createState() => 
      _FloatingNotificationOverlayState();
}

class _FloatingNotificationOverlayState 
    extends ConsumerState<FloatingNotificationOverlay>
    with TickerProviderStateMixin {
  
  final List<OverlayEntry> _activeToasts = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _clearAllToasts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new notifications
    ref.listen(notificationsProvider, (previous, current) {
      if (previous != null && current.isNotEmpty) {
        final newNotifications = current.where((notification) =>
          !previous.any((prev) => prev.id == notification.id)
        ).toList();
        
        for (final notification in newNotifications) {
          _showFloatingNotification(notification);
        }
      }
    });

    return const SizedBox.shrink();
  }

  void _showFloatingNotification(notification) {
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        right: 20,
        child: _FloatingNotificationToast(
          notification: notification,
          onDismiss: () => _dismissToast(overlayEntry),
        ),
      ),
    );

    _activeToasts.add(overlayEntry);
    Overlay.of(context).insert(overlayEntry);

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _dismissToast(overlayEntry);
    });
  }

  void _dismissToast(OverlayEntry entry) {
    if (_activeToasts.contains(entry)) {
      entry.remove();
      _activeToasts.remove(entry);
    }
  }

  void _clearAllToasts() {
    for (final toast in _activeToasts) {
      toast.remove();
    }
    _activeToasts.clear();
  }
}

class _FloatingNotificationToast extends StatefulWidget {
  final notification;
  final VoidCallback onDismiss;

  const _FloatingNotificationToast({
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<_FloatingNotificationToast> createState() => 
      _FloatingNotificationToastState();
}

class _FloatingNotificationToastState extends State<_FloatingNotificationToast>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle notification tap
        widget.onDismiss();
      },
      onPanUpdate: (details) {
        if (details.delta.dx > 10) {
          _dismiss();
        }
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.90),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.notification.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _dismiss,
                icon: Icon(
                  Iconsax.close_circle,
                  size: 18,
                  color: Colors.grey[400],
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    ).animate(controller: _slideController)
      .slideX(begin: 1, curve: Curves.easeOutQuart)
      .animate(controller: _fadeController)
      .fadeIn();
  }

  Widget _buildNotificationIcon() {
    IconData icon;
    Color color;

    switch (widget.notification.type) {
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
      case NotificationType.socialActivity:
        icon = Iconsax.people;
        color = Colors.purple;
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
        size: 20,
        color: color,
      ),
    );
  }

  void _dismiss() {
    _slideController.reverse().then((_) {
      _fadeController.reverse().then((_) {
        widget.onDismiss();
      });
    });
  }
} 