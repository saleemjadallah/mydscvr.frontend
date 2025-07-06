import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../models/search.dart';
import '../api/dio_config.dart';
import '../api/api_client.dart' show ApiClient;
import 'api_provider.dart';
import 'preferences_provider.dart';

/// State class for events list with loading and error states
class EventsState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const EventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  EventsState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return EventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Events notifier for managing events state
class EventsNotifier extends StateNotifier<EventsState> {
  final ApiClient _apiClient;
  final Ref _ref;

  EventsNotifier(this._apiClient, this._ref) : super(const EventsState());

  /// Apply family-friendly filtering to a list of events
  List<Event> _applyFamilyFriendlyFilter(List<Event> events, bool shouldFilter) {
    return applyFamilyFriendlyFilter(events, shouldFilter);
  }

  /// Load events with optional filters
  Future<void> loadEvents({
    String? category,
    String? location,
    String? area,
    String? date,
    double? priceMax,
    double? priceMin,
    int? ageMin,
    int? ageMax,
    bool? familyFriendly,
    bool? freeOnly,
    bool? featured,
    String? sortBy,
    String? sortOrder,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const EventsState(isLoading: true);
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getEvents(
        category: category,
        location: location,
        date: date,
        priceMax: priceMax?.toInt(),
        page: refresh ? 1 : state.currentPage,
      );

      if (response.isSuccess && response.data != null) {
        final eventsList = response.data!.map((eventData) => Event.fromBackendApi(eventData)).toList();
        
        // Apply family-friendly filtering if user preference is enabled
        final preferences = _ref.read(preferencesProvider);
        final filteredEvents = _applyFamilyFriendlyFilter(eventsList, preferences.familyFriendlyOnly);
        
        final newEvents = refresh ? filteredEvents : [...state.events, ...filteredEvents];
        
        state = state.copyWith(
          events: newEvents,
          isLoading: false,
          hasMore: eventsList.length >= 20, // Assuming 20 is the page size
          currentPage: refresh ? 2 : state.currentPage + 1,
        );
      } else {
        throw Exception(response.message ?? 'Failed to load events');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more events (pagination)
  Future<void> loadMore({
    String? category,
    String? location,
    String? area,
    String? date,
    double? priceMax,
    double? priceMin,
    int? ageMin,
    int? ageMax,
    bool? familyFriendly,
    bool? freeOnly,
    bool? featured,
    String? sortBy,
    String? sortOrder,
  }) async {
    return loadEvents(
      category: category,
      location: location,
      area: area,
      date: date,
      priceMax: priceMax,
      priceMin: priceMin,
      ageMin: ageMin,
      ageMax: ageMax,
      familyFriendly: familyFriendly,
      freeOnly: freeOnly,
      featured: featured,
      sortBy: sortBy,
      sortOrder: sortOrder,
      refresh: false,
    );
  }

  /// Refresh events list
  Future<void> refresh({
    String? category,
    String? location,
    String? area,
    String? date,
    double? priceMax,
    double? priceMin,
    int? ageMin,
    int? ageMax,
    bool? familyFriendly,
    bool? freeOnly,
    bool? featured,
    String? sortBy,
    String? sortOrder,
  }) async {
    return loadEvents(
      category: category,
      location: location,
      area: area,
      date: date,
      priceMax: priceMax,
      priceMin: priceMin,
      ageMin: ageMin,
      ageMax: ageMax,
      familyFriendly: familyFriendly,
      freeOnly: freeOnly,
      featured: featured,
      sortBy: sortBy,
      sortOrder: sortOrder,
      refresh: true,
    );
  }

  /// Get specific event by ID
  Future<Event> getEventById(String eventId) async {
    try {
      final response = await _apiClient.getEventById(eventId);
      if (response.isSuccess && response.data != null) {
        return Event.fromBackendApi(response.data!);
      } else {
        throw Exception(response.message ?? 'Failed to load event');
      }
    } catch (e) {
      throw Exception('Failed to load event: ${_getErrorMessage(e)}');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}

/// Helper function to check if an event is family-friendly (can be used across providers)
bool isEventFamilyFriendly(Event event) {
  // Conservative approach - only filter out clearly inappropriate content
  
  // If familyScore exists and is very low, filter out
  if (event.familyScore != null && event.familyScore! < 60) {
    return false;
  }
  
  // If age minimum is too high (for teens/adults only), filter out
  if (event.familySuitability.minAge != null && event.familySuitability.minAge! > 12) {
    return false;
  }
  
  // Filter out specific categories that are clearly not family-friendly
  final adultCategories = [
    'nightlife', 'bars', 'clubs', 'adult', 'mature', 
    'dating', 'casino', 'gambling', 'wine tasting', 'brewery'
  ];
  
  for (final category in event.categories) {
    if (adultCategories.any((adult) => 
        category.toLowerCase().contains(adult.toLowerCase()))) {
      return false;
    }
  }
  
  // If event has age restrictions mentioning 18+, 21+, etc.
  if (event.ageRestrictions?.toLowerCase().contains(RegExp(r'\b(18|21)\+')) == true) {
    return false;
  }
  
  // Default to family-friendly if no exclusion criteria met
  return true;
}

/// Helper function to apply family-friendly filtering to a list of events
List<Event> applyFamilyFriendlyFilter(List<Event> events, bool shouldFilter) {
  if (!shouldFilter) return events;
  return events.where(isEventFamilyFriendly).toList();
}

/// Provider for events state management
final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventsNotifier(apiClient, ref);
});

/// Provider for featured events
final featuredEventsProvider = FutureProvider<List<Event>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final preferences = ref.watch(preferencesProvider);
  
  try {
    final response = await apiClient.getEvents(page: 1);
    if (response.isSuccess && response.data != null) {
      final featuredEvents = response.data!
          .map((eventData) => Event.fromBackendApi(eventData))
          .where((event) => event.isFeatured)
          .toList();
      
      // Apply family-friendly filtering if enabled
      final filteredEvents = applyFamilyFriendlyFilter(featuredEvents, preferences.familyFriendlyOnly);
      
      return filteredEvents.take(10).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load featured events');
    }
  } catch (e) {
    throw Exception('Failed to load featured events: $e');
  }
});

/// Provider for trending events
final trendingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final preferences = ref.watch(preferencesProvider);
  
  try {
    final response = await apiClient.getEvents(page: 1);
    if (response.isSuccess && response.data != null) {
      final trendingEvents = response.data!
          .map((eventData) => Event.fromBackendApi(eventData))
          .where((event) => event.isTrending)
          .toList();
      
      // Apply family-friendly filtering if enabled
      final filteredEvents = applyFamilyFriendlyFilter(trendingEvents, preferences.familyFriendlyOnly);
      
      return filteredEvents.take(10).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load trending events');
    }
  } catch (e) {
    throw Exception('Failed to load trending events: $e');
  }
});

/// Provider for weekend events
final weekendEventsProvider = FutureProvider<List<Event>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final preferences = ref.watch(preferencesProvider);
  
  try {
    final response = await apiClient.getEvents(page: 1);
    if (response.isSuccess && response.data != null) {
      final weekendEvents = response.data!
          .map((eventData) => Event.fromBackendApi(eventData))
          .where((event) => event.isThisWeekend)
          .toList();
      
      // Apply family-friendly filtering if enabled
      final filteredEvents = applyFamilyFriendlyFilter(weekendEvents, preferences.familyFriendlyOnly);
      
      return filteredEvents.take(20).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load weekend events');
    }
  } catch (e) {
    throw Exception('Failed to load weekend events: $e');
  }
});

/// Provider for events by category
final eventsByCategoryProvider = FutureProvider.family<List<Event>, String>((ref, category) async {
  final apiClient = ref.watch(apiClientProvider);
  final preferences = ref.watch(preferencesProvider);
  
  try {
    final response = await apiClient.getEvents(category: category);
    if (response.isSuccess && response.data != null) {
      final categoryEvents = response.data!
          .map((eventData) => Event.fromBackendApi(eventData))
          .toList();
      
      // Apply family-friendly filtering if enabled
      final filteredEvents = applyFamilyFriendlyFilter(categoryEvents, preferences.familyFriendlyOnly);
      
      return filteredEvents.take(20).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load events for category');
    }
  } catch (e) {
    throw Exception('Failed to load events for category $category: $e');
  }
});

/// Provider for single event details
final eventDetailsProvider = FutureProvider.family<Event, String>((ref, eventId) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.getEventById(eventId);
    if (response.isSuccess && response.data != null) {
      return Event.fromBackendApi(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to load event details');
    }
  } catch (e) {
    throw Exception('Failed to load event details: ${_getErrorMessage(e)}');
  }
});

/// Provider for event categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  // Return static categories for now
  return [
    'Arts & Culture',
    'Sports & Fitness',
    'Food & Dining',
    'Entertainment',
    'Educational',
    'Outdoor Activities',
    'Family Fun',
    'Health & Wellness',
    'Shopping',
    'Technology',
  ];
});

/// Provider for areas/locations
final areasProvider = FutureProvider<List<String>>((ref) async {
  // Return static areas for now
  return [
    'Dubai Marina',
    'Downtown Dubai',
    'Jumeirah',
    'Al Barsha',
    'DIFC',
    'JLT',
    'Dubai Mall',
    'Mall of the Emirates',
    'Dubai Hills',
    'Dubai Design District',
  ];
});

/// Helper function to extract error messages
String _getErrorMessage(dynamic error) {
  if (error is ApiException) {
    return error.message;
  }
  return error.toString();
} 