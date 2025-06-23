import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification types for different kinds of alerts
enum NotificationType {
  eventReminder,
  newEvent,
  eventUpdate,
  bookingConfirmation,
  eventCancellation,
  socialActivity,
  promotionalOffer,
  systemUpdate,
}

/// Notification priority levels
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final bool isRead;
  final bool isSticky; // Sticky notifications don't auto-dismiss

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    required this.timestamp,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.isRead = false,
    this.isSticky = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    bool? isRead,
    bool? isSticky,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      isRead: isRead ?? this.isRead,
      isSticky: isSticky ?? this.isSticky,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'isRead': isRead,
      'isSticky': isSticky,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      isRead: json['isRead'] ?? false,
      isSticky: json['isSticky'] ?? false,
    );
  }
}

/// Notification settings model
class NotificationSettings {
  final bool pushNotifications;
  final bool eventReminders;
  final bool newEvents;
  final bool eventUpdates;
  final bool socialActivity;
  final bool promotionalOffers;
  final bool weeklyDigest;
  final int reminderMinutes; // Minutes before event to remind
  final List<String> mutedEventTypes;
  final bool quietHours;
  final int quietStartHour;
  final int quietEndHour;

  const NotificationSettings({
    this.pushNotifications = true,
    this.eventReminders = true,
    this.newEvents = true,
    this.eventUpdates = true,
    this.socialActivity = false,
    this.promotionalOffers = false,
    this.weeklyDigest = true,
    this.reminderMinutes = 60,
    this.mutedEventTypes = const [],
    this.quietHours = false,
    this.quietStartHour = 22,
    this.quietEndHour = 8,
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? eventReminders,
    bool? newEvents,
    bool? eventUpdates,
    bool? socialActivity,
    bool? promotionalOffers,
    bool? weeklyDigest,
    int? reminderMinutes,
    List<String>? mutedEventTypes,
    bool? quietHours,
    int? quietStartHour,
    int? quietEndHour,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      eventReminders: eventReminders ?? this.eventReminders,
      newEvents: newEvents ?? this.newEvents,
      eventUpdates: eventUpdates ?? this.eventUpdates,
      socialActivity: socialActivity ?? this.socialActivity,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      mutedEventTypes: mutedEventTypes ?? this.mutedEventTypes,
      quietHours: quietHours ?? this.quietHours,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'eventReminders': eventReminders,
      'newEvents': newEvents,
      'eventUpdates': eventUpdates,
      'socialActivity': socialActivity,
      'promotionalOffers': promotionalOffers,
      'weeklyDigest': weeklyDigest,
      'reminderMinutes': reminderMinutes,
      'mutedEventTypes': mutedEventTypes,
      'quietHours': quietHours,
      'quietStartHour': quietStartHour,
      'quietEndHour': quietEndHour,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['pushNotifications'] ?? true,
      eventReminders: json['eventReminders'] ?? true,
      newEvents: json['newEvents'] ?? true,
      eventUpdates: json['eventUpdates'] ?? true,
      socialActivity: json['socialActivity'] ?? false,
      promotionalOffers: json['promotionalOffers'] ?? false,
      weeklyDigest: json['weeklyDigest'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 60,
      mutedEventTypes: List<String>.from(json['mutedEventTypes'] ?? []),
      quietHours: json['quietHours'] ?? false,
      quietStartHour: json['quietStartHour'] ?? 22,
      quietEndHour: json['quietEndHour'] ?? 8,
    );
  }
}

/// Notification Service for managing notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<AppNotification> _notificationStream = 
      StreamController<AppNotification>.broadcast();
  final List<AppNotification> _notifications = [];
  NotificationSettings _settings = const NotificationSettings();
  
  late SharedPreferences _prefs;
  bool _initialized = false;

  Stream<AppNotification> get notificationStream => _notificationStream.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  NotificationSettings get settings => _settings;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    await _loadNotifications();
    await _loadSettings();
    _setupEventReminders();
    _initialized = true;
    
    if (kDebugMode) {
      print('NotificationService initialized');
    }
  }

  /// Load notifications from local storage
  Future<void> _loadNotifications() async {
    final notificationsJson = _prefs.getStringList('notifications') ?? [];
    _notifications.clear();
    
    for (final jsonString in notificationsJson) {
      try {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        _notifications.add(AppNotification.fromJson(data));
      } catch (e) {
        if (kDebugMode) {
          print('Error loading notification: $e');
        }
      }
    }
    
    // Sort by timestamp (newest first)
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    final notificationsJson = _notifications
        .map((notification) => jsonEncode(notification.toJson()))
        .toList();
    await _prefs.setStringList('notifications', notificationsJson);
  }

  /// Load notification settings
  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString('notification_settings');
    if (settingsJson != null) {
      try {
        final data = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = NotificationSettings.fromJson(data);
      } catch (e) {
        if (kDebugMode) {
          print('Error loading notification settings: $e');
        }
      }
    }
  }

  /// Save notification settings
  Future<void> _saveSettings() async {
    await _prefs.setString('notification_settings', jsonEncode(_settings.toJson()));
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    _setupEventReminders(); // Refresh reminders
  }

  /// Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    // Check if notifications are enabled for this type
    if (!_shouldShowNotification(notification)) {
      return;
    }

    // Check quiet hours
    if (_isQuietTime()) {
      // Store for later or reduce priority
      final delayedNotification = notification.copyWith(
        priority: NotificationPriority.low,
      );
      _notifications.insert(0, delayedNotification);
    } else {
      _notifications.insert(0, notification);
      _notificationStream.add(notification);
    }

    // Limit stored notifications (keep last 100)
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }

    await _saveNotifications();
    
    if (kDebugMode) {
      print('Notification added: ${notification.title}');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
  }

  /// Remove notification
  Future<void> removeNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  /// Setup event reminders
  void _setupEventReminders() {
    // Event reminders will be integrated with actual event booking system
    // This method is called when notification settings change
    if (_settings.eventReminders) {
      // Event reminder logic will be implemented when booking system is ready
      if (kDebugMode) {
        print('Event reminders enabled');
      }
    }
  }

  /// Check if we should show this notification type
  bool _shouldShowNotification(AppNotification notification) {
    if (!_settings.pushNotifications) return false;
    
    switch (notification.type) {
      case NotificationType.eventReminder:
        return _settings.eventReminders;
      case NotificationType.newEvent:
        return _settings.newEvents;
      case NotificationType.eventUpdate:
        return _settings.eventUpdates;
      case NotificationType.socialActivity:
        return _settings.socialActivity;
      case NotificationType.promotionalOffer:
        return _settings.promotionalOffers;
      default:
        return true;
    }
  }

  /// Check if current time is within quiet hours
  bool _isQuietTime() {
    if (!_settings.quietHours) return false;
    
    final now = DateTime.now();
    final currentHour = now.hour;
    
    if (_settings.quietStartHour <= _settings.quietEndHour) {
      return currentHour >= _settings.quietStartHour && 
             currentHour < _settings.quietEndHour;
    } else {
      // Quiet hours span midnight
      return currentHour >= _settings.quietStartHour || 
             currentHour < _settings.quietEndHour;
    }
  }

  /// Create notification for new event
  void notifyNewEvent(String eventTitle, String eventId) {
    final notification = AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_new_event',
      title: 'New Event Added',
      body: 'Check out "$eventTitle" - perfect for your family!',
      type: NotificationType.newEvent,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
      data: {'eventId': eventId},
      actionUrl: '/event/$eventId',
    );
    addNotification(notification);
  }

  /// Create notification for event update
  void notifyEventUpdate(String eventTitle, String updateMessage, String eventId) {
    final notification = AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_event_update',
      title: 'Event Updated',
      body: '$eventTitle: $updateMessage',
      type: NotificationType.eventUpdate,
      priority: NotificationPriority.high,
      timestamp: DateTime.now(),
      data: {'eventId': eventId},
      actionUrl: '/event/$eventId',
    );
    addNotification(notification);
  }

  /// Create notification for booking confirmation
  void notifyBookingConfirmation(String eventTitle, String bookingId) {
    final notification = AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_booking_confirmed',
      title: 'Booking Confirmed!',
      body: 'Your booking for "$eventTitle" has been confirmed.',
      type: NotificationType.bookingConfirmation,
      priority: NotificationPriority.high,
      timestamp: DateTime.now(),
      data: {'bookingId': bookingId},
      isSticky: true,
    );
    addNotification(notification);
  }

  /// Create notification for social activity
  void notifySocialActivity(String message, {String? actionUrl}) {
    final notification = AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_social',
      title: 'Social Activity',
      body: message,
      type: NotificationType.socialActivity,
      priority: NotificationPriority.low,
      timestamp: DateTime.now(),
      actionUrl: actionUrl,
    );
    addNotification(notification);
  }

  /// Dispose resources
  void dispose() {
    _notificationStream.close();
  }
} 