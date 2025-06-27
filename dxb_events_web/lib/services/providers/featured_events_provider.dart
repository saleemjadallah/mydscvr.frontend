import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../models/api_response.dart';
import '../featured_events_service.dart';
import '../events_service.dart';

/// State class for Featured Events
class FeaturedEventsState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final DateTime? lastRefresh;

  const FeaturedEventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.lastRefresh,
  });

  FeaturedEventsState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    DateTime? lastRefresh,
  }) {
    return FeaturedEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }

  bool get hasFeaturedEvents => events.isNotEmpty;
}

/// Featured Events Notifier for managing state
class FeaturedEventsNotifier extends StateNotifier<FeaturedEventsState> {
  final FeaturedEventsService _featuredEventsService;
  Timer? _refreshTimer;
  
  // Circuit breaker for preventing infinite loops
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 3;
  DateTime? _lastFailureTime;
  static const Duration _backoffDuration = Duration(minutes: 5);
  
  // Refresh intervals
  static const Duration _peakHoursInterval = Duration(minutes: 30);
  static const Duration _offPeakInterval = Duration(hours: 2);
  
  // Peak hours: 8 AM to 10 PM
  static const int _peakHourStart = 8;
  static const int _peakHourEnd = 22;

  FeaturedEventsNotifier(this._featuredEventsService) : super(const FeaturedEventsState()) {
    // Load events first, then start refresh cycle
    loadFeaturedEvents().then((_) {
      _initializeRefreshCycle();
    }).catchError((error) {
      print('🚫 FeaturedEventsProvider: Initial load failed, not starting refresh cycle: $error');
    });
  }

  /// Check if current time is during peak hours
  bool get _isPeakHours {
    final now = DateTime.now();
    return now.hour >= _peakHourStart && now.hour <= _peakHourEnd;
  }

  /// Load featured events with optional user context and environmental factors
  Future<void> loadFeaturedEvents({
    UserContext? userContext,
    EnvironmentalFactors? environmentalFactors,
    bool forceRefresh = false,
  }) async {
    print('🎯 FeaturedEventsNotifier: loadFeaturedEvents called (forceRefresh: $forceRefresh)');
    
    // Circuit breaker: check if we should skip this call
    if (!forceRefresh && _shouldSkipDueToFailures()) {
      print('🔄 FeaturedEventsNotifier: Skipping load due to circuit breaker ($_consecutiveFailures failures)');
      return;
    }
    
    // Avoid frequent refreshes unless forced
    if (!forceRefresh && state.lastRefresh != null) {
      final timeSinceLastRefresh = DateTime.now().difference(state.lastRefresh!);
      final minInterval = _isPeakHours ? _peakHoursInterval : _offPeakInterval;
      
      if (timeSinceLastRefresh < minInterval) {
        print('🎯 FeaturedEventsNotifier: Skipping refresh - too soon (${timeSinceLastRefresh.inMinutes}min < ${minInterval.inMinutes}min)');
        return; // Too soon to refresh
      }
    }

    print('🎯 FeaturedEventsNotifier: Starting to load featured events...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _featuredEventsService.getFeaturedEvents(
        limit: 12,
        userContext: userContext?.toMap(),
        environmentalFactors: environmentalFactors?.toMap(),
      );

      print('🎯 FeaturedEventsNotifier: Service response - isSuccess: ${response.isSuccess}');
      
      if (response.isSuccess && response.data != null) {
        // Reset failure count on success
        _consecutiveFailures = 0;
        _lastFailureTime = null;
        
        print('🎯 FeaturedEventsNotifier: Received ${response.data!.length} featured events');
        state = state.copyWith(
          events: response.data!,
          lastRefresh: DateTime.now(),
          isLoading: false,
          error: null,
        );
        _logFeaturedEventsUpdate();
      } else {
        _handleFailure();
        final error = response.error ?? 'Failed to load featured events';
        print('🚨 FeaturedEventsNotifier: Error loading featured events: $error');
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
      }
    } catch (e) {
      _handleFailure();
      final error = 'Unexpected error loading featured events: $e';
      print('🚨 FeaturedEventsNotifier: Exception: $error');
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }

  /// Load featured events for a specific user context
  Future<void> loadPersonalizedFeaturedEvents({
    List<int>? childrenAges,
    String? preferredArea,
    double? budgetMin,
    double? budgetMax,
    List<String>? previousCategories,
    List<String>? savedEventIds,
  }) async {
    final userContext = UserContext(
      childrenAges: childrenAges,
      preferredArea: preferredArea,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      previousCategories: previousCategories,
      savedEventIds: savedEventIds,
    );

    await loadFeaturedEvents(userContext: userContext);
  }

  /// Load featured events with weather context
  Future<void> loadWeatherAwareFeaturedEvents({
    double? temperature,
    String? weatherCondition,
    bool? isSandstorm,
    String? trafficCondition,
  }) async {
    final environmentalFactors = EnvironmentalFactors(
      temperature: temperature,
      weatherCondition: weatherCondition,
      isSandstorm: isSandstorm,
      trafficCondition: trafficCondition,
      timestamp: DateTime.now(),
    );

    await loadFeaturedEvents(environmentalFactors: environmentalFactors);
  }

  /// Get featured events for a specific category
  List<Event> getFeaturedEventsByCategory(String category) {
    return state.events.where((event) => event.category == category).toList();
  }

  /// Get featured events for a specific area
  List<Event> getFeaturedEventsByArea(String area) {
    return state.events.where((event) => 
      event.venue.area.toLowerCase().contains(area.toLowerCase())).toList();
  }

  /// Get featured events for today
  List<Event> getTodaysFeaturedEvents() {
    final today = DateTime.now();
    return state.events.where((event) {
      final eventDate = event.startDate;
      return eventDate.year == today.year &&
             eventDate.month == today.month &&
             eventDate.day == today.day;
    }).toList();
  }

  /// Get featured events for this weekend
  List<Event> getWeekendFeaturedEvents() {
    final now = DateTime.now();
    final friday = now.add(Duration(days: (5 - now.weekday) % 7));
    final sunday = friday.add(const Duration(days: 2));
    
    return state.events.where((event) {
      final eventDate = event.startDate;
      return eventDate.isAfter(friday) && eventDate.isBefore(sunday.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get free featured events
  List<Event> getFreeFeaturedEvents() {
    return state.events.where((event) => event.pricing.basePrice == 0).toList();
  }

  /// Get indoor featured events (useful during hot weather/sandstorms)
  List<Event> getIndoorFeaturedEvents() {
    return state.events.where((event) => _isIndoorEvent(event)).toList();
  }

  /// Get outdoor featured events (useful during pleasant weather)
  List<Event> getOutdoorFeaturedEvents() {
    return state.events.where((event) => !_isIndoorEvent(event)).toList();
  }

  /// Calculate and get the score for a specific event (for debugging/analytics)
  double getEventScore(Event event, {
    UserContext? userContext,
    EnvironmentalFactors? environmentalFactors,
  }) {
    return _featuredEventsService.calculateFeaturedScore(
      event,
      userContext: userContext?.toMap(),
      environmentalFactors: environmentalFactors?.toMap(),
      currentFeaturedEvents: state.events,
    );
  }

  /// Force refresh featured events
  Future<void> refresh({
    UserContext? userContext,
    EnvironmentalFactors? environmentalFactors,
  }) async {
    await loadFeaturedEvents(
      userContext: userContext,
      environmentalFactors: environmentalFactors,
      forceRefresh: true,
    );
  }

  /// Initialize automatic refresh cycle
  void _initializeRefreshCycle() {
    _scheduleNextRefresh();
  }

  /// Schedule the next automatic refresh
  void _scheduleNextRefresh() {
    _refreshTimer?.cancel();
    
    // Circuit breaker: If too many failures, don't schedule new refresh
    if (_shouldSkipDueToFailures()) {
      print('🚫 FeaturedEventsProvider: Skipping refresh due to circuit breaker');
      return;
    }
    
    // If circuit breaker is open, use longer interval
    Duration interval = _isPeakHours ? _peakHoursInterval : _offPeakInterval;
    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      interval = Duration(minutes: interval.inMinutes * 2); // Double the interval
    }
    
    _refreshTimer = Timer(interval, () {
      // Check if we should still refresh before making API call
      if (!_shouldSkipDueToFailures()) {
        loadFeaturedEvents().then((_) {
          // Only schedule next refresh if this call succeeded
          if (_consecutiveFailures < _maxConsecutiveFailures) {
            _scheduleNextRefresh();
          }
        }).catchError((error) {
          print('🚫 FeaturedEventsProvider: Stopping refresh cycle due to error: $error');
          // Don't schedule next refresh on error to break the loop
        });
      }
    });
  }
  
  /// Circuit breaker: check if we should skip API calls due to consecutive failures
  bool _shouldSkipDueToFailures() {
    if (_consecutiveFailures < _maxConsecutiveFailures) {
      return false;
    }
    
    if (_lastFailureTime == null) {
      return true;
    }
    
    final timeSinceLastFailure = DateTime.now().difference(_lastFailureTime!);
    return timeSinceLastFailure < _backoffDuration;
  }
  
  /// Handle API call failure - increment counter and set timestamp
  void _handleFailure() {
    _consecutiveFailures++;
    _lastFailureTime = DateTime.now();
    print('🔄 FeaturedEventsNotifier: Failure count: $_consecutiveFailures/$_maxConsecutiveFailures');
  }

  /// Clean up resources and stop timers
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    print('🧹 FeaturedEventsProvider: Disposed and cleaned up timers');
    super.dispose();
  }

  /// Helper method to determine if an event is indoor
  bool _isIndoorEvent(Event event) {
    final indoorKeywords = ['mall', 'center', 'centre', 'indoor', 'museum', 'gallery', 'theater', 'cinema'];
    final outdoorKeywords = ['beach', 'park', 'outdoor', 'garden', 'marina', 'creek'];
    
    final venueText = '${event.venue.name} ${event.venue.area} ${event.category}'.toLowerCase();
    final tags = event.tags.join(' ').toLowerCase();
    
    if (outdoorKeywords.any((keyword) => venueText.contains(keyword) || tags.contains(keyword))) {
      return false;
    }
    
    if (indoorKeywords.any((keyword) => venueText.contains(keyword) || tags.contains(keyword))) {
      return true;
    }
    
    return true; // Default to indoor for Dubai climate
  }

  void _logFeaturedEventsUpdate() {
    print('✨ Featured Events Updated: ${state.events.length} events loaded');
    if (state.events.isNotEmpty) {
      print('✨ Top Featured Event: ${state.events.first.title}');
      print('✨ Categories: ${state.events.map((e) => e.category).toSet().join(', ')}');
      print('✨ Areas: ${state.events.map((e) => e.venue.area).toSet().join(', ')}');
    }
  }

}

/// Featured Events Service Provider
final featuredEventsServiceProvider = Provider<FeaturedEventsService>((ref) {
  return FeaturedEventsService(EventsService());
});

/// Featured Events Provider
final featuredEventsProvider = StateNotifierProvider<FeaturedEventsNotifier, FeaturedEventsState>((ref) {
  final service = ref.watch(featuredEventsServiceProvider);
  return FeaturedEventsNotifier(service);
});

/// Filtered Events Providers
final todaysFeaturedEventsProvider = Provider<List<Event>>((ref) {
  final notifier = ref.watch(featuredEventsProvider.notifier);
  return notifier.getTodaysFeaturedEvents();
});

final weekendFeaturedEventsProvider = Provider<List<Event>>((ref) {
  final notifier = ref.watch(featuredEventsProvider.notifier);
  return notifier.getWeekendFeaturedEvents();
});

final freeFeaturedEventsProvider = Provider<List<Event>>((ref) {
  final notifier = ref.watch(featuredEventsProvider.notifier);
  return notifier.getFreeFeaturedEvents();
});

final indoorFeaturedEventsProvider = Provider<List<Event>>((ref) {
  final notifier = ref.watch(featuredEventsProvider.notifier);
  return notifier.getIndoorFeaturedEvents();
});

final outdoorFeaturedEventsProvider = Provider<List<Event>>((ref) {
  final notifier = ref.watch(featuredEventsProvider.notifier);
  return notifier.getOutdoorFeaturedEvents();
});

/// Featured Events Analytics Providers
final featuredEventsCategoryDistributionProvider = Provider<Map<String, int>>((ref) {
  final events = ref.watch(featuredEventsProvider).events;
  final distribution = <String, int>{};
  for (final event in events) {
    distribution[event.category] = (distribution[event.category] ?? 0) + 1;
  }
  return distribution;
});

final featuredEventsAreaDistributionProvider = Provider<Map<String, int>>((ref) {
  final events = ref.watch(featuredEventsProvider).events;
  final distribution = <String, int>{};
  for (final event in events) {
    distribution[event.venue.area] = (distribution[event.venue.area] ?? 0) + 1;
  }
  return distribution;
});

final featuredEventsAverageRatingProvider = Provider<double>((ref) {
  final events = ref.watch(featuredEventsProvider).events;
  if (events.isEmpty) return 0.0;
  final totalRating = events.fold(0.0, (sum, event) => sum + event.rating);
  return totalRating / events.length;
});

final featuredEventsPriceRangeProvider = Provider<Map<String, double>>((ref) {
  final events = ref.watch(featuredEventsProvider).events;
  if (events.isEmpty) return {'min': 0.0, 'max': 0.0};
  
  final prices = events.map((e) => e.pricing.basePrice).toList();
  return {
    'min': prices.reduce((a, b) => a < b ? a : b),
    'max': prices.reduce((a, b) => a > b ? a : b),
  };
}); 