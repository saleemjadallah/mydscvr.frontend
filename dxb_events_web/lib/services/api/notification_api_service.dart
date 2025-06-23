import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notifications/notification_service.dart';
import '../api/dio_config.dart';
import '../../services/providers/auth_provider_mongodb.dart';

/// API service for backend notification operations
class NotificationApiService {
  final Ref ref;
  
  NotificationApiService(this.ref);
  
  /// Base headers for API requests
  Map<String, String> get _headers {
    final authState = ref.read(authProvider);
    final token = authState.accessToken;
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  /// Get API base URL
  String get _baseUrl => DioConfig.getApiBaseUrl();
  
  /// Fetch notifications from backend
  Future<List<AppNotification>> fetchNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    NotificationType? type,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'unread_only': unreadOnly.toString(),
        if (type != null) 'notification_type': _typeToString(type),
      };
      
      final uri = Uri.parse('${_baseUrl}/api/notifications')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notificationsList = data['notifications'] as List;
        
        return notificationsList.map((json) => _parseNotification(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('${_baseUrl}/api/notifications/$notificationId/read'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('${_baseUrl}/api/notifications/mark-all-read'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
  
  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}/api/notifications/$notificationId'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
  
  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}/api/notifications'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing notifications: $e');
      return false;
    }
  }
  
  /// Get notification settings
  Future<NotificationSettings?> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}/api/notifications/settings'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseSettings(data);
      }
      return null;
    } catch (e) {
      print('Error fetching notification settings: $e');
      return null;
    }
  }
  
  /// Update notification settings
  Future<bool> updateSettings(NotificationSettings settings) async {
    try {
      final body = {
        'push_notifications': settings.pushNotifications,
        'email_notifications': settings.eventReminders, // Map to email for now
        'event_reminders': settings.eventReminders,
        'new_events': settings.newEvents,
        'event_updates': settings.eventUpdates,
        'social_activity': settings.socialActivity,
        'promotional_offers': settings.promotionalOffers,
        'weekly_digest': settings.weeklyDigest,
        'reminder_minutes': settings.reminderMinutes,
        'quiet_hours': settings.quietHours,
        'quiet_start_hour': settings.quietStartHour,
        'quiet_end_hour': settings.quietEndHour,
        'muted_event_types': settings.mutedEventTypes,
      };
      
      final response = await http.put(
        Uri.parse('${_baseUrl}/api/notifications/settings'),
        headers: _headers,
        body: json.encode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating notification settings: $e');
      return false;
    }
  }
  
  /// Get notification statistics
  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}/api/notifications/stats'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching notification stats: $e');
      return null;
    }
  }
  
  /// Send test notification
  Future<bool> sendTestNotification() async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}/api/notifications/test'),
        headers: _headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending test notification: $e');
      return false;
    }
  }
  
  /// Parse notification from JSON
  AppNotification _parseNotification(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      type: _parseType(json['type']),
      priority: _parsePriority(json['priority']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['created_at']),
      isRead: json['status'] == 'read',
      actionUrl: json['action_url'],
      data: json['data'],
    );
  }
  
  /// Parse notification settings from JSON
  NotificationSettings _parseSettings(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['push_notifications'] ?? true,
      eventReminders: json['event_reminders'] ?? true,
      newEvents: json['new_events'] ?? true,
      eventUpdates: json['event_updates'] ?? true,
      socialActivity: json['social_activity'] ?? true,
      promotionalOffers: json['promotional_offers'] ?? false,
      weeklyDigest: json['weekly_digest'] ?? true,
      reminderMinutes: json['reminder_minutes'] ?? 1440,
      quietHours: json['quiet_hours'] ?? false,
      quietStartHour: json['quiet_start_hour'] ?? 22,
      quietEndHour: json['quiet_end_hour'] ?? 8,
      mutedEventTypes: List<String>.from(json['muted_event_types'] ?? []),
    );
  }
  
  /// Parse notification type from string
  NotificationType _parseType(String? type) {
    switch (type) {
      case 'event_reminder':
        return NotificationType.eventReminder;
      case 'new_event':
        return NotificationType.newEvent;
      case 'event_update':
        return NotificationType.eventUpdate;
      case 'booking_confirmation':
        return NotificationType.bookingConfirmation;
      case 'event_cancellation':
        return NotificationType.eventCancellation;
      case 'social_activity':
        return NotificationType.socialActivity;
      case 'promotional_offer':
        return NotificationType.promotionalOffer;
      case 'system':
        return NotificationType.systemUpdate;
      default:
        return NotificationType.systemUpdate;
    }
  }
  
  /// Parse notification priority from string
  NotificationPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'urgent':
        return NotificationPriority.urgent;
      case 'high':
        return NotificationPriority.high;
      case 'low':
        return NotificationPriority.low;
      default:
        return NotificationPriority.normal;
    }
  }
  
  /// Convert type to string for API
  String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return 'event_reminder';
      case NotificationType.newEvent:
        return 'new_event';
      case NotificationType.eventUpdate:
        return 'event_update';
      case NotificationType.bookingConfirmation:
        return 'booking_confirmation';
      case NotificationType.eventCancellation:
        return 'event_cancellation';
      case NotificationType.socialActivity:
        return 'social_activity';
      case NotificationType.promotionalOffer:
        return 'promotional_offer';
      case NotificationType.systemUpdate:
        return 'system';
    }
  }
}

/// Provider for the notification API service
final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiService(ref);
});