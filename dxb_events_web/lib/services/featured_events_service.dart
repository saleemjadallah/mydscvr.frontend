import 'dart:math';
import '../models/event.dart';
import '../models/api_response.dart';
import 'events_service.dart';

/// Service for calculating and managing Featured Events using the dynamic smart algorithm
class FeaturedEventsService {
  final EventsService _eventsService;
  
  // Algorithm weights as specified
  static const double _familySuitabilityWeight = 0.25;
  static const double _trendingWeight = 0.20;
  static const double _timeRelevanceWeight = 0.20;
  static const double _qualityWeight = 0.15;
  static const double _diversityWeight = 0.10;
  static const double _premiumBoostWeight = 0.10;

  FeaturedEventsService(this._eventsService);

  /// Calculate the featured score for an event
  double calculateFeaturedScore(Event event, {
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? environmentalFactors,
    List<Event>? currentFeaturedEvents,
  }) {
    final familySuitabilityScore = _calculateFamilySuitabilityScore(event, userContext);
    final trendingScore = _calculateTrendingScore(event);
    final timeRelevanceScore = _calculateTimeRelevanceScore(event, environmentalFactors);
    final qualityScore = _calculateQualityScore(event);
    final diversityScore = _calculateDiversityScore(event, currentFeaturedEvents);
    final premiumBoost = _calculatePremiumBoost(event);

    final totalScore = (
      familySuitabilityScore * _familySuitabilityWeight +
      trendingScore * _trendingWeight +
      timeRelevanceScore * _timeRelevanceWeight +
      qualityScore * _qualityWeight +
      diversityScore * _diversityWeight +
      premiumBoost * _premiumBoostWeight
    );

    return totalScore.clamp(0.0, 100.0);
  }

  /// 1. Family-Centric Suitability Score (25% weight)
  double _calculateFamilySuitabilityScore(Event event, Map<String, dynamic>? userContext) {
    double score = 0.0;

    // Age Range Coverage (broad age ranges get higher scores)
    final minAge = event.familySuitability.minAge ?? 0;
    final maxAge = event.familySuitability.maxAge ?? 99;
    final ageRange = maxAge - minAge;
    
    if (ageRange >= 90) { // 0-99 or very broad
      score += 25.0;
    } else if (ageRange >= 40) { // Good family coverage
      score += 20.0;
    } else if (ageRange >= 20) { // Moderate coverage
      score += 15.0;
    } else {
      score += 10.0; // Limited age range
    }

    // Family Amenities
    if (event.venue.parkingAvailable) score += 15.0;
    if (event.familySuitability.strollerFriendly) score += 15.0;
    if (event.familySuitability.babyChanging) score += 10.0;
    if (event.familySuitability.nursingFriendly) score += 10.0;

    // Safety & Venue Quality (implied by rating and venue tier)
    if (event.rating >= 4.5) score += 15.0;
    else if (event.rating >= 4.0) score += 10.0;

    // Duration (2-4 hours is ideal for families)
    final duration = event.duration;
    if (duration.inHours >= 2 && duration.inHours <= 4) {
      score += 10.0;
    } else if (duration.inHours >= 1 && duration.inHours <= 6) {
      score += 5.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// 2. Trending & Social Proof Score (20% weight)
  double _calculateTrendingScore(Event event) {
    double score = 0.0;

    // High Engagement (rating-based)
    if (event.rating >= 4.5) {
      score += 30.0;
    } else if (event.rating >= 4.0) {
      score += 20.0;
    } else if (event.rating >= 3.5) {
      score += 10.0;
    }

    // Review Count (social proof)
    if (event.reviewCount >= 100) {
      score += 25.0;
    } else if (event.reviewCount >= 50) {
      score += 20.0;
    } else if (event.reviewCount >= 20) {
      score += 15.0;
    } else if (event.reviewCount >= 10) {
      score += 10.0;
    }

    // Trending indicator
    if (event.isTrending) {
      score += 25.0;
    }

    // Booking velocity (estimated from available slots vs max capacity)
    if (event.availableSlots != null && event.maxCapacity != null) {
      final filledRatio = 1.0 - (event.availableSlots! / event.maxCapacity!);
      if (filledRatio >= 0.8) score += 20.0; // High demand
      else if (filledRatio >= 0.6) score += 15.0;
      else if (filledRatio >= 0.4) score += 10.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// 3. Time Relevance Score (20% weight)
  double _calculateTimeRelevanceScore(Event event, Map<String, dynamic>? environmentalFactors) {
    double score = 0.0;
    final now = DateTime.now();
    final eventDate = event.startDate;

    // Weekend Priority (Friday-Saturday)
    final isWeekend = eventDate.weekday == DateTime.friday || eventDate.weekday == DateTime.saturday;
    if (isWeekend) {
      score += 30.0;
    } else if (eventDate.weekday == DateTime.sunday) {
      score += 20.0; // Sunday also good for families
    }

    // Seasonal Appropriateness
    final isIndoor = _isIndoorEvent(event);
    final eventHour = eventDate.hour;
    final currentMonth = now.month;
    
    // Summer months (May-September) in Dubai
    if (currentMonth >= 5 && currentMonth <= 9) {
      if (isIndoor && eventHour >= 11 && eventHour <= 18) {
        score += 25.0; // Perfect indoor timing for summer
      } else if (!isIndoor && (eventHour >= 19 || eventHour <= 10)) {
        score += 20.0; // Good outdoor timing for summer
      }
    } else {
      // Winter months - outdoor activities preferred
      if (!isIndoor && eventHour >= 16 && eventHour <= 22) {
        score += 25.0; // Perfect outdoor timing for winter
      } else if (isIndoor) {
        score += 15.0;
      }
    }

    // Last-minute availability (today/tomorrow events)
    final daysUntil = eventDate.difference(now).inDays;
    if (daysUntil == 0) { // Today
      score += 20.0;
    } else if (daysUntil == 1) { // Tomorrow
      score += 15.0;
    } else if (daysUntil <= 7) { // This week
      score += 10.0;
    }

    // School holiday alignment (estimated)
    if (_isSchoolHoliday(eventDate)) {
      score += 15.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// 4. Quality & Premium Indicators Score (15% weight)
  double _calculateQualityScore(Event event) {
    double score = 0.0;

    // Venue Quality (premium locations)
    final premiumAreas = [
      'Dubai Mall', 'City Walk', 'JBR', 'Marina', 'Downtown Dubai',
      'Business Bay', 'DIFC', 'Palm Jumeirah', 'Bluewaters'
    ];
    
    if (premiumAreas.any((area) => 
        event.venue.area.toLowerCase().contains(area.toLowerCase()) ||
        event.venue.name.toLowerCase().contains(area.toLowerCase()))) {
      score += 30.0;
    }

    // Event Type Quality
    if (event.familySuitability.educationalContent) score += 20.0;
    if (event.tags.contains('cultural') || event.tags.contains('heritage')) score += 15.0;
    if (event.tags.contains('unique') || event.tags.contains('exclusive')) score += 15.0;

    // Price-Value Balance (AED 50-200 range is optimal)
    final price = event.pricing.basePrice;
    if (price >= 50 && price <= 200) {
      score += 20.0;
    } else if (price >= 25 && price <= 300) {
      score += 15.0;
    } else if (price == 0) { // Free events
      score += 25.0; // High value
    }

    // Exclusivity (limited capacity)
    if (event.maxCapacity != null && event.maxCapacity! <= 50) {
      score += 15.0;
    } else if (event.maxCapacity != null && event.maxCapacity! <= 100) {
      score += 10.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// 5. Diversity & Discovery Score (10% weight)
  double _calculateDiversityScore(Event event, List<Event>? currentFeaturedEvents) {
    double score = 50.0; // Base score
    
    if (currentFeaturedEvents == null || currentFeaturedEvents.isEmpty) {
      return score;
    }

    // Category balance
    final featuredCategories = currentFeaturedEvents.map((e) => e.category).toSet();
    if (!featuredCategories.contains(event.category)) {
      score += 25.0; // New category adds diversity
    }

    // Geographic spread
    final featuredAreas = currentFeaturedEvents.map((e) => e.venue.area).toSet();
    if (!featuredAreas.contains(event.venue.area)) {
      score += 15.0; // New area adds diversity
    }

    // Indoor/Outdoor balance
    final isIndoor = _isIndoorEvent(event);
    final featuredIndoorCount = currentFeaturedEvents.where(_isIndoorEvent).length;
    final featuredOutdoorCount = currentFeaturedEvents.length - featuredIndoorCount;
    
    if (isIndoor && featuredIndoorCount < featuredOutdoorCount) {
      score += 10.0;
    } else if (!isIndoor && featuredOutdoorCount < featuredIndoorCount) {
      score += 10.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// 6. Premium Boost Score (10% weight)
  double _calculatePremiumBoost(Event event) {
    double score = 0.0;

    // Sponsored/Featured flag
    if (event.isFeatured) {
      score += 40.0;
    }

    // Partner events (identified by specific organizers)
    final premiumOrganizers = [
      'Dubai Municipality', 'Dubai Tourism', 'Emirates', 'Expo',
      'Dubai Opera', 'Global Village', 'IMG Worlds'
    ];
    
    if (premiumOrganizers.any((org) => 
        event.organizerInfo.name.toLowerCase().contains(org.toLowerCase()))) {
      score += 30.0;
    }

    // High-quality venue partnerships
    if (event.venue.amenities != null && event.venue.amenities!.isNotEmpty) {
      score += 20.0;
    }

    // Verified organizer
    if (event.organizerInfo.isVerified) {
      score += 10.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Get featured events using the backend enhanced algorithm
  Future<ApiResponse<List<Event>>> getFeaturedEvents({
    int limit = 12,
    Map<String, dynamic>? userContext,
    Map<String, dynamic>? environmentalFactors,
  }) async {
    try {
      print('🔄 FeaturedEventsService: Starting to fetch featured events from backend...');
      print('🔄 FeaturedEventsService: Limit requested: $limit');
      
      // Use the backend featured events endpoint (with enhanced algorithm)
      final response = await _eventsService.getFeaturedEventsFromBackend(
        limit: limit,
      );

      print('🔄 FeaturedEventsService: Backend API response isSuccess: ${response.isSuccess}');
      
      if (!response.isSuccess || response.data == null) {
        print('🚨 FeaturedEventsService: Failed to fetch events - ${response.error}');
        return ApiResponse.error('Failed to fetch events for scoring: ${response.error}');
      }

      final events = response.data!;
      print('🔄 FeaturedEventsService: Fetched ${events.length} events from API');
      
      if (events.isEmpty) {
        print('🚨 FeaturedEventsService: No events returned from API');
        return ApiResponse.success(<Event>[]);
      }

      final scoredEvents = <ScoredEvent>[];
      int successfullyScored = 0;
      int failedToScore = 0;

      // Calculate scores for all events
      for (int i = 0; i < events.length; i++) {
        try {
          final event = events[i];
          print('🔄 FeaturedEventsService: Scoring event ${i + 1}/${events.length}: "${event.title}"');
          
          final score = calculateFeaturedScore(
            event,
            userContext: userContext,
            environmentalFactors: environmentalFactors,
            currentFeaturedEvents: scoredEvents.map((se) => se.event).toList(),
          );
          
          print('🔄 FeaturedEventsService: Event "${event.title}" scored: $score');
          scoredEvents.add(ScoredEvent(event: event, score: score));
          successfullyScored++;
        } catch (e, stackTrace) {
          print('🚨 FeaturedEventsService: Error scoring event ${i + 1}: $e');
          print('🚨 FeaturedEventsService: Stack trace: $stackTrace');
          failedToScore++;
        }
      }

      print('🔄 FeaturedEventsService: Successfully scored: $successfullyScored events');
      print('🔄 FeaturedEventsService: Failed to score: $failedToScore events');

      if (scoredEvents.isEmpty) {
        print('🚨 FeaturedEventsService: No events were successfully scored');
        return ApiResponse.success(<Event>[]);
      }

      // Sort by score descending
      scoredEvents.sort((a, b) => b.score.compareTo(a.score));
      print('🔄 FeaturedEventsService: Top 5 scored events:');
      for (int i = 0; i < 5 && i < scoredEvents.length; i++) {
        print('🔄   ${i + 1}. "${scoredEvents[i].event.title}" - Score: ${scoredEvents[i].score}');
      }

      // Apply business rules for geographic and category balance
      final balancedEvents = _applyBalancingRules(scoredEvents, limit);
      print('🔄 FeaturedEventsService: After balancing: ${balancedEvents.length} events selected');

      // Apply duplicate filtering based on title similarity
      final deduplicatedEvents = _removeDuplicatesByTitle(balancedEvents);
      print('🔄 FeaturedEventsService: After deduplication: ${deduplicatedEvents.length} events selected');

      final finalEvents = deduplicatedEvents.map((se) => se.event).toList();
      print('✅ FeaturedEventsService: Returning ${finalEvents.length} featured events');
      
      return ApiResponse.success(finalEvents);
    } catch (e, stackTrace) {
      print('🚨 FeaturedEventsService: Critical error in getFeaturedEvents: $e');
      print('🚨 FeaturedEventsService: Stack trace: $stackTrace');
      return ApiResponse.error('Error calculating featured events: $e');
    }
  }

  /// Apply business rules for balanced featured events
  List<ScoredEvent> _applyBalancingRules(List<ScoredEvent> scoredEvents, int limit) {
    final selectedEvents = <ScoredEvent>[];
    final usedCategories = <String>{};
    final usedAreas = <String>{};

    // First pass: select highest scoring events while maintaining some diversity
    for (final scoredEvent in scoredEvents) {
      if (selectedEvents.length >= limit) break;

      final event = scoredEvent.event;
      final category = event.category;
      final area = event.venue.area;

      // Always include top 3 highest scoring events regardless of diversity
      if (selectedEvents.length < 3) {
        selectedEvents.add(scoredEvent);
        usedCategories.add(category);
        usedAreas.add(area);
        continue;
      }

      // For remaining slots, prefer diverse categories and areas
      final categoryOverused = usedCategories.where((c) => c == category).length >= 3;
      final areaOverused = usedAreas.where((a) => a == area).length >= 2;

      if (!categoryOverused && !areaOverused) {
        selectedEvents.add(scoredEvent);
        usedCategories.add(category);
        usedAreas.add(area);
      }
    }

    // Second pass: fill remaining slots if needed
    if (selectedEvents.length < limit) {
      for (final scoredEvent in scoredEvents) {
        if (selectedEvents.length >= limit) break;
        
        if (!selectedEvents.contains(scoredEvent)) {
          selectedEvents.add(scoredEvent);
        }
      }
    }

    return selectedEvents;
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
    
    // Default assumption based on Dubai climate - most events are indoor
    return true;
  }

  /// Helper method to estimate school holidays
  bool _isSchoolHoliday(DateTime date) {
    final month = date.month;
    final day = date.day;
    
    // UAE school holidays (approximate)
    // Summer break: July-August
    if (month == 7 || month == 8) return true;
    
    // Winter break: mid-December to early January
    if ((month == 12 && day >= 15) || (month == 1 && day <= 7)) return true;
    
    // Spring break: March-April
    if (month == 3 && day >= 20 || month == 4 && day <= 10) return true;
    
    return false;
  }

  /// Remove duplicate events based on title similarity
  List<ScoredEvent> _removeDuplicatesByTitle(List<ScoredEvent> events) {
    final List<ScoredEvent> deduplicatedEvents = [];
    final Set<String> seenTitles = <String>{};
    
    for (final scoredEvent in events) {
      final event = scoredEvent.event;
      final normalizedTitle = _normalizeTitle(event.title);
      
      // Check if we've seen a similar title before
      bool isDuplicate = false;
      for (final seenTitle in seenTitles) {
        if (_calculateTitleSimilarity(normalizedTitle, seenTitle) > 0.85) {
          print('🔄 FeaturedEventsService: Duplicate detected - "${event.title}" similar to existing event');
          isDuplicate = true;
          break;
        }
      }
      
      if (!isDuplicate) {
        deduplicatedEvents.add(scoredEvent);
        seenTitles.add(normalizedTitle);
      }
    }
    
    return deduplicatedEvents;
  }
  
  /// Normalize title for comparison by removing common variations
  String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'\b(live|at|in|the|a|an|and|or|&)\b'), '') // Remove common words
        .trim();
  }
  
  /// Calculate similarity between two normalized titles
  double _calculateTitleSimilarity(String title1, String title2) {
    if (title1.isEmpty || title2.isEmpty) return 0.0;
    
    // Simple word-based similarity
    final words1 = title1.split(' ').where((w) => w.isNotEmpty).toSet();
    final words2 = title2.split(' ').where((w) => w.isNotEmpty).toSet();
    
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;
    
    return union > 0 ? intersection / union : 0.0;
  }

  /// Refresh featured events (to be called every 30 minutes during peak hours)
  Future<void> refreshFeaturedEvents() async {
    // This would typically update a cache or notify providers
    // Implementation depends on your caching strategy
  }
}

/// Helper class to store events with their calculated scores
class ScoredEvent {
  final Event event;
  final double score;

  ScoredEvent({required this.event, required this.score});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoredEvent && other.event.id == event.id;
  }

  @override
  int get hashCode => event.id.hashCode;
}

/// Context classes for user and environmental data
class UserContext {
  final List<int>? childrenAges;
  final String? preferredArea;
  final double? budgetMin;
  final double? budgetMax;
  final List<String>? previousCategories;
  final List<String>? savedEventIds;

  UserContext({
    this.childrenAges,
    this.preferredArea,
    this.budgetMin,
    this.budgetMax,
    this.previousCategories,
    this.savedEventIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'childrenAges': childrenAges,
      'preferredArea': preferredArea,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'previousCategories': previousCategories,
      'savedEventIds': savedEventIds,
    };
  }
}

class EnvironmentalFactors {
  final double? temperature;
  final String? weatherCondition;
  final bool? isSandstorm;
  final String? trafficCondition;
  final DateTime timestamp;

  EnvironmentalFactors({
    this.temperature,
    this.weatherCondition,
    this.isSandstorm,
    this.trafficCondition,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'weatherCondition': weatherCondition,
      'isSandstorm': isSandstorm,
      'trafficCondition': trafficCondition,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 