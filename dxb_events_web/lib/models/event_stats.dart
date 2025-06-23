/// Model for event statistics
class EventStats {
  final int totalEvents;
  final int activeEvents;
  final int familyFriendlyEvents;
  final int freeEvents;
  final Map<String, int> eventsByCategory;
  final Map<String, int> eventsByArea;
  final double averageRating;
  final String lastUpdated;

  const EventStats({
    required this.totalEvents,
    required this.activeEvents,
    required this.familyFriendlyEvents,
    required this.freeEvents,
    this.eventsByCategory = const {},
    this.eventsByArea = const {},
    required this.averageRating,
    required this.lastUpdated,
  });

  factory EventStats.fromJson(Map<String, dynamic> json) {
    // Handle both old and new API response formats
    
    // Extract categories from top_categories array
    final topCategories = json['top_categories'] as List<dynamic>? ?? [];
    final eventsByCategory = <String, int>{};
    for (final category in topCategories) {
      if (category is Map<String, dynamic>) {
        final name = category['_id']?.toString() ?? 'Unknown';
        final count = category['count'] as int? ?? 0;
        eventsByCategory[name] = count;
      }
    }
    
    // Extract areas from top_areas array
    final topAreas = json['top_areas'] as List<dynamic>? ?? [];
    final eventsByArea = <String, int>{};
    for (final area in topAreas) {
      if (area is Map<String, dynamic>) {
        final name = area['_id']?.toString() ?? 'Unknown';
        final count = area['count'] as int? ?? 0;
        if (name != 'null' && name != 'Unknown') {
          eventsByArea[name] = count;
        }
      }
    }
    
    return EventStats(
      totalEvents: json['total_events'] ?? 0,
      activeEvents: json['active_events'] ?? 0,
      familyFriendlyEvents: json['family_friendly_events'] ?? 0,
      freeEvents: json['free_events'] ?? 0,
      eventsByCategory: eventsByCategory,
      eventsByArea: eventsByArea,
      averageRating: json['average_rating']?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_events': totalEvents,
      'active_events': activeEvents,
      'family_friendly_events': familyFriendlyEvents,
      'free_events': freeEvents,
      'events_by_category': eventsByCategory,
      'events_by_area': eventsByArea,
      'average_rating': averageRating,
      'last_updated': lastUpdated,
    };
  }

  /// Create empty stats for loading/error states
  factory EventStats.empty() {
    return const EventStats(
      totalEvents: 0,
      activeEvents: 0,
      familyFriendlyEvents: 0,
      freeEvents: 0,
      averageRating: 0.0,
      lastUpdated: '',
    );
  }

  /// Format total events for display (150+ format)
  String get formattedTotalEvents {
    if (totalEvents >= 1000) {
      final k = totalEvents / 1000;
      return '${k.toStringAsFixed(k == k.roundToDouble() ? 0 : 1)}k+';
    } else if (totalEvents >= 100) {
      final hundreds = (totalEvents / 100).floor() * 100;
      return '${hundreds}+';
    } else if (totalEvents >= 50) {
      return '50+';
    } else {
      return totalEvents.toString();
    }
  }

  /// Format family events for display
  String get formattedFamilyEvents {
    if (familyFriendlyEvents >= 100) {
      final hundreds = (familyFriendlyEvents / 100).floor() * 100;
      return '${hundreds}+';
    } else if (familyFriendlyEvents >= 50) {
      return '50+';
    } else {
      return familyFriendlyEvents.toString();
    }
  }

  /// Get venue count (estimate based on areas)
  String get formattedVenueCount {
    final venueCount = eventsByArea.length;
    if (venueCount >= 100) {
      final hundreds = (venueCount / 100).floor() * 100;
      return '${hundreds}+';
    } else if (venueCount >= 50) {
      return '50+';
    } else {
      return venueCount.toString();
    }
  }
} 