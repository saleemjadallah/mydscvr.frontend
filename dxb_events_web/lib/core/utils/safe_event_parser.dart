import 'package:flutter/foundation.dart';
import '../../models/event.dart';

/// Safe event parser to handle type casting errors gracefully
class SafeEventParser {
  /// Safely parse an event from JSON with error handling
  static Event? parseEvent(dynamic eventData) {
    try {
      if (eventData == null) {
        if (kDebugMode) {
          print('🚨 SafeEventParser: eventData is null');
        }
        return null;
      }

      // Ensure eventData is a Map<String, dynamic>
      Map<String, dynamic> eventJson;
      if (eventData is Map<String, dynamic>) {
        eventJson = eventData;
      } else if (eventData is Map) {
        // Convert Map to Map<String, dynamic>
        eventJson = Map<String, dynamic>.from(eventData);
      } else {
        if (kDebugMode) {
          print('🚨 SafeEventParser: eventData is not a Map. Type: ${eventData.runtimeType}');
        }
        return null;
      }

      // Validate required fields
      if (!_hasRequiredFields(eventJson)) {
        if (kDebugMode) {
          print('🚨 SafeEventParser: Missing required fields in event data');
          print('🚨 SafeEventParser: Available fields: ${eventJson.keys.toList()}');
        }
        return null;
      }

      // Debug: Check parsing success
      if (kDebugMode) {
        print('✅ SafeEventParser: Successfully parsing event: ${eventJson['title']}');
      }

      // Parse using fromBackendApi with additional safety
      return Event.fromBackendApi(eventJson);
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('🚨 SafeEventParser: Error parsing event: $e');
        print('🚨 SafeEventParser: Stack trace: $stackTrace');
        print('🚨 SafeEventParser: Event data: $eventData');
      }
      return null;
    }
  }

  /// Parse a list of events safely
  static List<Event> parseEventList(dynamic eventsData) {
    try {
      if (eventsData == null) {
        if (kDebugMode) {
          print('🚨 SafeEventParser: eventsData is null');
        }
        return [];
      }

      List<dynamic> eventsList;
      if (eventsData is List) {
        eventsList = eventsData;
      } else {
        if (kDebugMode) {
          print('🚨 SafeEventParser: eventsData is not a List. Type: ${eventsData.runtimeType}');
        }
        return [];
      }

      final List<Event> parsedEvents = [];
      
      for (int i = 0; i < eventsList.length; i++) {
        final event = parseEvent(eventsList[i]);
        if (event != null) {
          parsedEvents.add(event);
        } else {
          if (kDebugMode) {
            print('🚨 SafeEventParser: Failed to parse event at index $i');
          }
        }
      }

      if (kDebugMode) {
        print('✅ SafeEventParser: Parsed ${parsedEvents.length} events out of ${eventsList.length}');
      }

      return parsedEvents;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('🚨 SafeEventParser: Error parsing event list: $e');
        print('🚨 SafeEventParser: Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Check if event JSON has required fields
  static bool _hasRequiredFields(Map<String, dynamic> json) {
    // Check for title
    if (json['title'] == null || json['title'].toString().isEmpty) {
      if (kDebugMode) {
        print('🚨 SafeEventParser: Missing required field: title');
      }
      return false;
    }
    
    // Check for id or objectID (Algolia uses objectID)
    final hasId = json['id'] != null && json['id'].toString().isNotEmpty;
    final hasObjectId = json['objectID'] != null && json['objectID'].toString().isNotEmpty;
    
    if (!hasId && !hasObjectId) {
      if (kDebugMode) {
        print('🚨 SafeEventParser: Missing required field: id or objectID');
      }
      return false;
    }
    
    // If we have objectID but not id, copy it over
    if (hasObjectId && !hasId) {
      json['id'] = json['objectID'];
    }
    
    return true;
  }

  /// Create a fallback event when parsing fails
  static Event createFallbackEvent(String id) {
    return Event(
      id: id,
      title: 'Event Unavailable',
      description: 'This event could not be loaded properly.',
      imageUrl: '',
      category: 'general',
      tags: [],
      startDate: DateTime.now(),
      venue: Venue(
        id: id,
        name: 'Location TBA',
        address: 'Dubai',
        area: 'Dubai',
        city: 'Dubai',
        parkingAvailable: true,
        publicTransportAccess: true,
      ),
      pricing: Pricing(
        basePrice: 0,
        currency: 'AED',
        isRefundable: true,
      ),
      familySuitability: FamilySuitability(
        minAge: 0,
        maxAge: 100,
        strollerFriendly: true,
        babyChanging: false,
        nursingFriendly: false,
        kidMenuAvailable: false,
        educationalContent: false,
      ),
      highlights: [],
      included: [],
      accessibility: [],
      whatToBring: [],
      importantInfo: [],
      organizerInfo: OrganizerInfo(
        name: 'Unknown',
        verificationStatus: 'unverified',
      ),
      bookingRequired: false,
      isFeatured: false,
      isTrending: false,
      rating: 0.0,
      reviewCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      categories: [],
    );
  }
}