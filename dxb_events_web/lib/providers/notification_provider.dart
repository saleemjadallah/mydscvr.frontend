import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications/notification_service.dart';
import '../services/api/notification_api_service.dart';
import '../services/providers/auth_provider_mongodb.dart';

/// Provider for the notification service singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for the notification API service
final notificationApiProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiService(ref);
});

/// Provider for the current notification settings
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(service);
});

/// Provider for the list of notifications
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationsNotifier(service, ref);
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

/// Provider for filtering notifications by type
final filteredNotificationsProvider = Provider.family<List<AppNotification>, NotificationType?>((ref, type) {
  final notifications = ref.watch(notificationsProvider);
  if (type == null) return notifications;
  return notifications.where((n) => n.type == type).toList();
});

/// State notifier for managing notification settings
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationService _service;

  NotificationSettingsNotifier(this._service) : super(const NotificationSettings()) {
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    state = _service.settings;
  }

  /// Update push notification settings
  Future<void> updatePushNotifications(bool enabled) async {
    final newSettings = state.copyWith(pushNotifications: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update event reminder settings
  Future<void> updateEventReminders(bool enabled) async {
    final newSettings = state.copyWith(eventReminders: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update new events notifications
  Future<void> updateNewEvents(bool enabled) async {
    final newSettings = state.copyWith(newEvents: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update event updates notifications
  Future<void> updateEventUpdates(bool enabled) async {
    final newSettings = state.copyWith(eventUpdates: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update social activity notifications
  Future<void> updateSocialActivity(bool enabled) async {
    final newSettings = state.copyWith(socialActivity: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update promotional offers notifications
  Future<void> updatePromotionalOffers(bool enabled) async {
    final newSettings = state.copyWith(promotionalOffers: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update weekly digest setting
  Future<void> updateWeeklyDigest(bool enabled) async {
    final newSettings = state.copyWith(weeklyDigest: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update reminder timing
  Future<void> updateReminderMinutes(int minutes) async {
    final newSettings = state.copyWith(reminderMinutes: minutes);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update quiet hours setting
  Future<void> updateQuietHours(bool enabled) async {
    final newSettings = state.copyWith(quietHours: enabled);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Update quiet hours time range
  Future<void> updateQuietHoursTime(int startHour, int endHour) async {
    final newSettings = state.copyWith(
      quietStartHour: startHour,
      quietEndHour: endHour,
    );
    await _service.updateSettings(newSettings);
    state = newSettings;
  }

  /// Mute notifications for specific event type
  Future<void> muteEventType(String eventType) async {
    final mutedTypes = [...state.mutedEventTypes];
    if (!mutedTypes.contains(eventType)) {
      mutedTypes.add(eventType);
      final newSettings = state.copyWith(mutedEventTypes: mutedTypes);
      await _service.updateSettings(newSettings);
      state = newSettings;
    }
  }

  /// Unmute notifications for specific event type
  Future<void> unmuteEventType(String eventType) async {
    final mutedTypes = [...state.mutedEventTypes];
    mutedTypes.remove(eventType);
    final newSettings = state.copyWith(mutedEventTypes: mutedTypes);
    await _service.updateSettings(newSettings);
    state = newSettings;
  }
}

/// State notifier for managing notifications list
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final NotificationService _service;
  final Ref _ref;

  NotificationsNotifier(this._service, this._ref) : super(const []) {
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    
    // Check if user is authenticated
    final authState = _ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      // Fetch notifications from API
      await _fetchFromApi();
    } else {
      // Use local notifications
      state = _service.notifications;
    }
    
    // Listen to new notifications
    _service.notificationStream.listen((notification) {
      state = [notification, ...state];
    });
  }
  
  Future<void> _fetchFromApi() async {
    try {
      final apiService = _ref.read(notificationApiProvider);
      final notifications = await apiService.fetchNotifications();
      
      // Update local storage
      for (final notification in notifications) {
        await _service.addNotification(notification);
      }
      
      state = notifications;
    } catch (e) {
      print('Failed to fetch notifications from API: $e');
      // Fall back to local notifications
      state = _service.notifications;
    }
  }

  /// Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    await _service.addNotification(notification);
    state = _service.notifications;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    // Update locally first for instant feedback
    await _service.markAsRead(notificationId);
    state = _service.notifications;
    
    // Sync with API if authenticated
    final authState = _ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      final apiService = _ref.read(notificationApiProvider);
      await apiService.markAsRead(notificationId);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    // Update locally first
    await _service.markAllAsRead();
    state = _service.notifications;
    
    // Sync with API if authenticated
    final authState = _ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      final apiService = _ref.read(notificationApiProvider);
      await apiService.markAllAsRead();
    }
  }

  /// Remove notification
  Future<void> removeNotification(String notificationId) async {
    // Update locally first
    await _service.removeNotification(notificationId);
    state = _service.notifications;
    
    // Sync with API if authenticated
    final authState = _ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      final apiService = _ref.read(notificationApiProvider);
      await apiService.deleteNotification(notificationId);
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    // Update locally first
    await _service.clearAllNotifications();
    state = const [];
    
    // Sync with API if authenticated
    final authState = _ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      final apiService = _ref.read(notificationApiProvider);
      await apiService.clearAllNotifications();
    }
  }
  
  /// Refresh notifications from API
  Future<void> refresh() async {
    final authState = _ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      await _fetchFromApi();
    }
  }

} 