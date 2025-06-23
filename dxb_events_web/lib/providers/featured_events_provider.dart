import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/api_response.dart';
import '../services/featured_events_service.dart';
import '../services/events_service.dart';

/// Provider for managing Featured Events state and refresh cycles
class FeaturedEventsProvider extends ChangeNotifier {
  final FeaturedEventsService _featuredEventsService;
  
  List<Event> _featuredEvents = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;
  Timer? _refreshTimer;
  
  // Refresh intervals
  static const Duration _peakHoursInterval = Duration(minutes: 30);
  static const Duration _offPeakInterval = Duration(hours: 2);
  
  // Peak hours: 8 AM to 10 PM
  static const int _peakHourStart = 8;
  static const int _peakHourEnd = 22;

  FeaturedEventsProvider() : _featuredEventsService = FeaturedEventsService(EventsService()) {
    _initializeRefreshCycle();
    loadFeaturedEvents();
  }

  // Getters
  List<Event> get featuredEvents => _featuredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;
  
  bool get hasFeaturedEvents => _featuredEvents.isNotEmpty;
  
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
    // Avoid frequent refreshes unless forced
    if (!forceRefresh && _lastRefresh != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefresh!);
      final minInterval = _isPeakHours ? _peakHoursInterval : _offPeakInterval;
      
      if (timeSinceLastRefresh < minInterval) {
        return; // Too soon to refresh
      }
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _featuredEventsService.getFeaturedEvents(
        limit: 12,
        userContext: userContext?.toMap(),
        environmentalFactors: environmentalFactors?.toMap(),
      );

      if (response.isSuccess && response.data != null) {
        _featuredEvents = response.data!;
        _lastRefresh = DateTime.now();
        _logFeaturedEventsUpdate();
      } else {
        _setError(response.error ?? 'Failed to load featured events');
      }
    } catch (e) {
      _setError('Unexpected error loading featured events: $e');
    } finally {
      _setLoading(false);
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
    return _featuredEvents.where((event) => event.category == category).toList();
  }

  /// Get featured events for a specific area
  List<Event> getFeaturedEventsByArea(String area) {
    return _featuredEvents.where((event) => 
      event.venue.area.toLowerCase().contains(area.toLowerCase())).toList();
  }

  /// Get featured events for today
  List<Event> getTodaysFeaturedEvents() {
    final today = DateTime.now();
    return _featuredEvents.where((event) {
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
    
    return _featuredEvents.where((event) {
      final eventDate = event.startDate;
      return eventDate.isAfter(friday) && eventDate.isBefore(sunday.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get free featured events
  List<Event> getFreeFeaturedEvents() {
    return _featuredEvents.where((event) => event.pricing.basePrice == 0).toList();
  }

  /// Get indoor featured events (useful during hot weather/sandstorms)
  List<Event> getIndoorFeaturedEvents() {
    return _featuredEvents.where((event) => _isIndoorEvent(event)).toList();
  }

  /// Get outdoor featured events (useful during pleasant weather)
  List<Event> getOutdoorFeaturedEvents() {
    return _featuredEvents.where((event) => !_isIndoorEvent(event)).toList();
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
      currentFeaturedEvents: _featuredEvents,
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
    
    final interval = _isPeakHours ? _peakHoursInterval : _offPeakInterval;
    
    _refreshTimer = Timer(interval, () {
      loadFeaturedEvents();
      _scheduleNextRefresh(); // Schedule the next refresh
    });
  }

  /// Update refresh schedule when peak hours change
  void _updateRefreshSchedule() {
    if (_refreshTimer != null) {
      _scheduleNextRefresh();
    }
  }

  /// Helper method to determine if an event is indoor (duplicate from service for provider use)
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

  /// Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
    print('🚨 FeaturedEventsProvider Error: $error');
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _logFeaturedEventsUpdate() {
    print('✨ Featured Events Updated: ${_featuredEvents.length} events loaded');
    if (_featuredEvents.isNotEmpty) {
      print('✨ Top Featured Event: ${_featuredEvents.first.title}');
      print('✨ Categories: ${_featuredEvents.map((e) => e.category).toSet().join(', ')}');
      print('✨ Areas: ${_featuredEvents.map((e) => e.venue.area).toSet().join(', ')}');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Extension to provide additional filtering methods
extension FeaturedEventsFiltering on FeaturedEventsProvider {
  /// Get featured events within a price range
  List<Event> getFeaturedEventsInPriceRange(double minPrice, double maxPrice) {
    return _featuredEvents.where((event) => 
      event.pricing.basePrice >= minPrice && event.pricing.basePrice <= maxPrice
    ).toList();
  }

  /// Get featured events suitable for specific age groups
  List<Event> getFeaturedEventsForAgeGroup(int minAge, int maxAge) {
    return _featuredEvents.where((event) {
      final eventMinAge = event.familySuitability.minAge ?? 0;
      final eventMaxAge = event.familySuitability.maxAge ?? 99;
      
      // Check if there's an overlap in age ranges
      return eventMinAge <= maxAge && eventMaxAge >= minAge;
    }).toList();
  }

  /// Get trending featured events
  List<Event> getTrendingFeaturedEvents() {
    return _featuredEvents.where((event) => event.isTrending).toList();
  }

  /// Get featured events with high ratings
  List<Event> getHighRatedFeaturedEvents({double minimumRating = 4.0}) {
    return _featuredEvents.where((event) => event.rating >= minimumRating).toList();
  }

  /// Get featured events with educational content
  List<Event> getEducationalFeaturedEvents() {
    return _featuredEvents.where((event) => event.familySuitability.educationalContent).toList();
  }

  /// Get featured events that are stroller friendly
  List<Event> getStrollerFriendlyFeaturedEvents() {
    return _featuredEvents.where((event) => event.familySuitability.strollerFriendly).toList();
  }
}

/// Analytics and insights extension
extension FeaturedEventsAnalytics on FeaturedEventsProvider {
  /// Get distribution of featured events by category
  Map<String, int> getCategoryDistribution() {
    final distribution = <String, int>{};
    for (final event in _featuredEvents) {
      distribution[event.category] = (distribution[event.category] ?? 0) + 1;
    }
    return distribution;
  }

  /// Get distribution of featured events by area
  Map<String, int> getAreaDistribution() {
    final distribution = <String, int>{};
    for (final event in _featuredEvents) {
      distribution[event.venue.area] = (distribution[event.venue.area] ?? 0) + 1;
    }
    return distribution;
  }

  /// Get average rating of featured events
  double getAverageRating() {
    if (_featuredEvents.isEmpty) return 0.0;
    final totalRating = _featuredEvents.fold(0.0, (sum, event) => sum + event.rating);
    return totalRating / _featuredEvents.length;
  }

  /// Get price range of featured events
  Map<String, double> getPriceRange() {
    if (_featuredEvents.isEmpty) return {'min': 0.0, 'max': 0.0};
    
    final prices = _featuredEvents.map((e) => e.pricing.basePrice).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }
} 