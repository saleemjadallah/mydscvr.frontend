import 'package:flutter/foundation.dart';
import '../models/event.dart';
import 'super_search_service.dart';

/// Specialized service for Algolia event tracking across the app
/// 
/// This service provides a centralized way to track user interactions
/// for Algolia's AI features including NeuralSearch, Dynamic Re-Ranking,
/// and Personalization.
class AlgoliaEventTrackingService {
  static final AlgoliaEventTrackingService _instance = AlgoliaEventTrackingService._internal();
  factory AlgoliaEventTrackingService() => _instance;
  AlgoliaEventTrackingService._internal();

  late final SuperSearchService _searchService;
  
  // Store current search context for accurate tracking
  String? _currentQuery;
  List<Event>? _currentSearchResults;
  EventTrackingInfo? _currentTrackingInfo;

  /// Initialize the tracking service
  void initialize(SuperSearchService searchService) {
    _searchService = searchService;
  }

  /// Update search context when new search is performed
  void updateSearchContext({
    required String query,
    required List<Event> searchResults,
    EventTrackingInfo? trackingInfo,
  }) {
    _currentQuery = query;
    _currentSearchResults = searchResults;
    _currentTrackingInfo = trackingInfo;
    
    if (kDebugMode) {
      print('🔍 Updated search context: query="$query", results=${searchResults.length}, queryId=${trackingInfo?.queryId}');
    }
  }

  /// Track click on search result
  Future<void> trackSearchResultClick(Event event) async {
    if (_currentQuery == null || _currentSearchResults == null) {
      if (kDebugMode) {
        print('⚠️ Cannot track click: no search context available');
      }
      return;
    }

    final position = _currentSearchResults!.indexWhere((e) => e.id == event.id) + 1;
    
    if (position > 0) {
      try {
        final result = await _searchService.trackClickEvent(
          query: _currentQuery!,
          eventId: event.id,
          position: position,
          queryId: _currentTrackingInfo?.queryId,
          userToken: _currentTrackingInfo?.userToken,
        );
        
        if (result.isSuccess && kDebugMode) {
          print('✅ Click tracked for "${event.title}" at position $position');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to track click: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('⚠️ Event "${event.title}" not found in current search results');
      }
    }
  }

  /// Track when user views event details
  Future<void> trackEventDetailsViewed(Event event) async {
    try {
      final result = await _searchService.trackConversionEvent(
        eventId: event.id,
        eventName: 'Event Details Viewed',
        queryId: _currentTrackingInfo?.queryId,
        userToken: _currentTrackingInfo?.userToken,
      );
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Event details view tracked for "${event.title}"');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track event details view: $e');
      }
    }
  }

  /// Track when user bookmarks an event
  Future<void> trackEventBookmarked(Event event) async {
    try {
      final result = await _searchService.trackConversionEvent(
        eventId: event.id,
        eventName: 'Event Bookmarked',
        queryId: _currentTrackingInfo?.queryId,
        userToken: _currentTrackingInfo?.userToken,
      );
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Event bookmark tracked for "${event.title}"');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track event bookmark: $e');
      }
    }
  }

  /// Track when user shares an event
  Future<void> trackEventShared(Event event) async {
    try {
      final result = await _searchService.trackConversionEvent(
        eventId: event.id,
        eventName: 'Event Shared',
        queryId: _currentTrackingInfo?.queryId,
        userToken: _currentTrackingInfo?.userToken,
      );
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Event share tracked for "${event.title}"');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track event share: $e');
      }
    }
  }

  /// Track when user adds event to calendar
  Future<void> trackEventAddedToCalendar(Event event) async {
    try {
      final result = await _searchService.trackConversionEvent(
        eventId: event.id,
        eventName: 'Event Added to Calendar',
        queryId: _currentTrackingInfo?.queryId,
        userToken: _currentTrackingInfo?.userToken,
      );
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Add to calendar tracked for "${event.title}"');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track add to calendar: $e');
      }
    }
  }

  /// Track when user views search results (automatically called)
  Future<void> trackSearchResultsViewed(List<Event> events) async {
    try {
      final eventIds = events.map((e) => e.id).toList();
      final result = await _searchService.trackViewEvent(
        eventIds: eventIds,
        eventName: 'Search Results Viewed',
        userToken: _currentTrackingInfo?.userToken,
      );
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Search results view tracked for ${events.length} events');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track search results view: $e');
      }
    }
  }

  /// Track when user views category/area page (browse behavior)
  Future<void> trackCategoryViewed(String category, List<Event> events) async {
    try {
      final eventIds = events.map((e) => e.id).toList();
      final result = await _searchService.trackViewEvent(
        eventIds: eventIds,
        eventName: 'Category Viewed: $category',
        userToken: _currentTrackingInfo?.userToken,
      );
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Category "$category" view tracked for ${events.length} events');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track category view: $e');
      }
    }
  }

  /// Track when user filters search results
  Future<void> trackFilterApplied(String filterType, String filterValue) async {
    try {
      // Create a pseudo-event for filter tracking
      final result = await _searchService.trackViewEvent(
        eventIds: [], // Empty for filter events
        eventName: 'Filter Applied: $filterType = $filterValue',
        userToken: _currentTrackingInfo?.userToken,
      );
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Filter applied tracked: $filterType = $filterValue');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track filter application: $e');
      }
    }
  }

  /// Track when user performs any custom action
  Future<void> trackCustomAction({
    required String actionName,
    Event? event,
    Map<String, String>? additionalData,
  }) async {
    try {
      if (event != null) {
        // Track as conversion if event is involved
        final result = await _searchService.trackConversionEvent(
          eventId: event.id,
          eventName: actionName,
          queryId: _currentTrackingInfo?.queryId,
          userToken: _currentTrackingInfo?.userToken,
        );
        
        if (result.isSuccess && kDebugMode) {
          print('✅ Custom action "$actionName" tracked for "${event.title}"');
        }
      } else {
        // Track as view event for general actions
        final result = await _searchService.trackViewEvent(
          eventIds: [],
          eventName: actionName,
          userToken: _currentTrackingInfo?.userToken,
        );
        
        if (result.isSuccess && kDebugMode) {
          print('✅ Custom action "$actionName" tracked');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to track custom action "$actionName": $e');
      }
    }
  }

  /// Set authenticated user for enhanced personalization
  Future<bool> setAuthenticatedUser(String userId) async {
    try {
      final result = await _searchService.setAuthenticatedUserToken(userId);
      
      if (result.isSuccess && kDebugMode) {
        print('✅ Authenticated user set for enhanced personalization');
      }
      
      return result.isSuccess;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to set authenticated user: $e');
      }
      return false;
    }
  }

  /// Get current tracking status for debugging
  Map<String, dynamic> getTrackingStatus() {
    return {
      'hasSearchContext': _currentQuery != null,
      'currentQuery': _currentQuery,
      'searchResultsCount': _currentSearchResults?.length ?? 0,
      'queryId': _currentTrackingInfo?.queryId,
      'userToken': _currentTrackingInfo?.userToken,
      'searchTracked': _currentTrackingInfo?.searchTracked ?? false,
      'viewTracked': _currentTrackingInfo?.viewTracked ?? false,
    };
  }

  /// Clear current search context (call when navigating away from search)
  void clearSearchContext() {
    _currentQuery = null;
    _currentSearchResults = null;
    _currentTrackingInfo = null;
    
    if (kDebugMode) {
      print('🧹 Search context cleared');
    }
  }

  /// Utility method to safely track any event without throwing errors
  Future<void> _safeTrack(Future<void> Function() trackingFunction) async {
    try {
      await trackingFunction();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Tracking error (safely handled): $e');
      }
      // Silently handle errors to not disrupt user experience
    }
  }
} 