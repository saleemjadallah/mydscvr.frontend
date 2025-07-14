import 'dart:math';
import '../models/event.dart';
import '../models/api_response.dart';
import 'events_service.dart';

/// Service for calculating and managing Smart Trending Events
/// Updates weekly every Monday with fresh algorithm-based trending scores
class TrendingEventsService {
  final EventsService _eventsService;
  
  // Algorithm weights for trending calculation
  static const double _ratingWeight = 0.40;      // Rating has highest impact
  static const double _recencyWeight = 0.25;     // How recently added/updated
  static const double _priceWeight = 0.20;       // Free events get bonus
  static const double _socialProofWeight = 0.15; // Trending indicator bonus

  TrendingEventsService(this._eventsService);

  /// Get trending events using the smart algorithm (refreshes weekly on Mondays)
  /// Now uses firecrawl-extracted events for higher quality results
  Future<ApiResponse<List<TrendingEventData>>> getSmartTrendingEvents({
    int limit = 10,
    bool useFirecrawlOnly = true, // Default to firecrawl events for quality
  }) async {
    try {
      print('🔥 TrendingEventsService: Starting to calculate trending events...');
      print('🔥 TrendingEventsService: Algorithm refresh date: ${_getLastMondayDate()}');
      print('🔥 TrendingEventsService: Using firecrawl-only events: $useFirecrawlOnly');
      
      // Get events - prefer firecrawl for higher quality
      final response = useFirecrawlOnly 
          ? await _eventsService.getFirecrawlEvents(
              limit: 100, // Get more events for good selection
              sortBy: 'start_date', // Get diverse events by date
            )
          : await _eventsService.getEvents(
              perPage: 100, // Fallback to all events
            );

      if (!response.isSuccess || response.data == null) {
        print('🚨 TrendingEventsService: Failed to fetch events - ${response.error}');
        return ApiResponse.error('Failed to fetch events: ${response.error}');
      }

      final events = response.data!;
      print('🔥 TrendingEventsService: Fetched ${events.length} events from API');
      
      if (events.isEmpty) {
        print('🚨 TrendingEventsService: No events available');
        return ApiResponse.success(<TrendingEventData>[]);
      }

      final scoredEvents = <TrendingEventData>[];
      
      // Calculate trending scores for all events
      for (int i = 0; i < events.length; i++) {
        try {
          final event = events[i];
          final score = _calculateTrendingScore(event);
          final simulatedInterested = _generateSimulatedInterestCount(event, score);
          final timeAgo = _generateSimulatedTimeAgo(event, score);
          
          scoredEvents.add(TrendingEventData(
            event: event,
            trendingScore: score,
            interestedCount: simulatedInterested,
            timeAgo: timeAgo,
            weeklyRank: i + 1, // Will be updated after sorting
          ));
          
          print('🔥 TrendingEventsService: Event "${event.title}" scored: $score (${simulatedInterested} interested)');
        } catch (e) {
          print('🚨 TrendingEventsService: Error scoring event ${i + 1}: $e');
          continue;
        }
      }

      if (scoredEvents.isEmpty) {
        print('🚨 TrendingEventsService: No events were successfully scored');
        return ApiResponse.success(<TrendingEventData>[]);
      }

      // Sort by trending score descending
      scoredEvents.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
      
      // NEW: Rotate the top events for variability on each load
      final topCount = (limit * 3).clamp(3, scoredEvents.length);
      var topEvents = scoredEvents.take(topCount).toList();
      
      // Rotate based on current minute for per-session changes
      final now = DateTime.now();
      final rotationOffset = (now.minute + now.second) % topEvents.length;
      
      final rotated = topEvents.sublist(rotationOffset) + topEvents.sublist(0, rotationOffset);
      
      // Take the first 'limit' from rotated list
      final selectedEvents = rotated.take(limit).toList();
      
      // Update ranks
      for (int i = 0; i < selectedEvents.length; i++) {
        selectedEvents[i] = selectedEvents[i].copyWith(weeklyRank: i + 1);
      }
      
      // Apply diversity if needed
      // final selectedEvents = _applyDiversityRules(rotatedScoredEvents, limit);
      
      print('🔥 TrendingEventsService: Top 5 trending events:');
      for (int i = 0; i < 5 && i < selectedEvents.length; i++) {
        final item = selectedEvents[i];
        print('🔥   ${i + 1}. "${item.event.title}" - Score: ${item.trendingScore} (${item.interestedCount} interested)');
      }

      print('✅ TrendingEventsService: Returning ${selectedEvents.length} trending events');
      return ApiResponse.success(selectedEvents);
    } catch (e, stackTrace) {
      print('🚨 TrendingEventsService: Critical error: $e');
      print('🚨 TrendingEventsService: Stack trace: $stackTrace');
      return ApiResponse.error('Error calculating trending events: $e');
    }
  }

  /// Calculate trending score using smart algorithm
  double _calculateTrendingScore(Event event) {
    double score = 0.0;

    // 1. Rating Score (40% weight) - Rating × 20 (max 100 points)
    final ratingScore = (event.rating * 20).clamp(0.0, 100.0);
    score += ratingScore * _ratingWeight;

    // 2. Recency Score (25% weight) - Events added/updated recently
    final recencyScore = _calculateRecencyScore(event);
    score += recencyScore * _recencyWeight;

    // 3. Price Score (20% weight) - Free events get significant bonus
    final priceScore = _calculatePriceScore(event);
    score += priceScore * _priceWeight;

    // 4. Social Proof Score (15% weight) - Trending indicators and review count
    final socialScore = _calculateSocialProofScore(event);
    score += socialScore * _socialProofWeight;

    // Weekly randomization factor (small) to prevent same events always appearing
    final randomFactor = Random(event.id.hashCode + DateTime.now().millisecondsSinceEpoch).nextDouble() * 5; // Max 5 points
    score += randomFactor;

    return score.clamp(0.0, 100.0);
  }

  /// Calculate recency score based on when event was likely added/updated
  double _calculateRecencyScore(Event event) {
    final now = DateTime.now();
    final eventDate = event.startDate;
    
    // For events very close to start date, assume they were added recently
    final daysUntilEvent = eventDate.difference(now).inDays;
    
    if (daysUntilEvent <= 7) {
      return 90.0; // Events happening very soon are "trending"
    } else if (daysUntilEvent <= 14) {
      return 70.0; // Events in next 2 weeks
    } else if (daysUntilEvent <= 21) {
      return 50.0; // Events in next 3 weeks
    } else {
      return 30.0; // Events further out
    }
  }

  /// Calculate price score - free events get significant bonus
  double _calculatePriceScore(Event event) {
    if (event.isFree) {
      return 100.0; // Maximum score for free events
    } else if (event.pricing.basePrice <= 50) {
      return 70.0; // Affordable events
    } else if (event.pricing.basePrice <= 100) {
      return 50.0; // Moderately priced
    } else if (event.pricing.basePrice <= 200) {
      return 30.0; // Premium events
    } else {
      return 10.0; // Expensive events (less trending appeal)
    }
  }

  /// Calculate social proof score
  double _calculateSocialProofScore(Event event) {
    double score = 0.0;

    // Trending indicator bonus
    if (event.isTrending) {
      score += 60.0;
    }

    // Review count social proof
    if (event.reviewCount >= 50) {
      score += 30.0;
    } else if (event.reviewCount >= 20) {
      score += 20.0;
    } else if (event.reviewCount >= 10) {
      score += 15.0;
    } else if (event.reviewCount >= 5) {
      score += 10.0;
    }

    // High rating with reviews gets extra boost
    if (event.rating >= 4.5 && event.reviewCount >= 10) {
      score += 10.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Generate realistic "interested" count based on trending score
  int _generateSimulatedInterestCount(Event event, double trendingScore) {
    // Use event ID hash to ensure each event gets a unique seed
    final eventSeed = event.id.hashCode.abs();
    final random = Random(DateTime.now().millisecondsSinceEpoch + eventSeed);
    
    // Vary range based on trending score for more realistic distribution
    int baseMin, baseMax;
    if (trendingScore >= 0.8) {
      // High trending: 700-900 interested
      baseMin = 70; baseMax = 90;
    } else if (trendingScore >= 0.6) {
      // Medium trending: 600-800 interested  
      baseMin = 60; baseMax = 80;
    } else {
      // Lower trending: 500-700 interested
      baseMin = 50; baseMax = 70;
    }
    
    final range = baseMax - baseMin;
    final baseCount = random.nextInt(range) + baseMin;
    final total = baseCount * 10; // Results in multiples of 10
    
    return total;
  }

  /// Generate realistic "time ago" based on event and score
  String _generateSimulatedTimeAgo(Event event, double trendingScore) {
    final timeOptions = [
      '1 hr ago',
      '2 hrs ago',
      '3 hrs ago',
    ];
    
    // Randomly select from the 3 options for new app realism
    final random = Random(event.id.hashCode + DateTime.now().millisecondsSinceEpoch);
    final selectedIndex = random.nextInt(timeOptions.length);
    
    return timeOptions[selectedIndex];
  }

  /// Apply diversity rules to avoid all events from same category/area
  List<TrendingEventData> _applyDiversityRules(List<TrendingEventData> scoredEvents, int limit) {
    final selectedEvents = <TrendingEventData>[];
    final usedCategories = <String>{};
    final usedAreas = <String>{};

    // First pass: select highest scoring events with some diversity
    for (final item in scoredEvents) {
      if (selectedEvents.length >= limit) break;

      final category = item.event.category;
      final area = item.event.venue.area;

      // Always include top 2 highest scoring events regardless of diversity
      if (selectedEvents.length < 2) {
        selectedEvents.add(item);
        usedCategories.add(category);
        usedAreas.add(area);
        continue;
      }

      // For remaining slots, prefer diverse categories and areas
      final categoryOverused = usedCategories.where((c) => c == category).length >= 2;
      final areaOverused = usedAreas.where((a) => a == area).length >= 2;

      if (!categoryOverused && !areaOverused) {
        selectedEvents.add(item);
        usedCategories.add(category);
        usedAreas.add(area);
      }
    }

    // Second pass: fill remaining slots if needed
    if (selectedEvents.length < limit) {
      for (final item in scoredEvents) {
        if (selectedEvents.length >= limit) break;
        
        if (!selectedEvents.contains(item)) {
          selectedEvents.add(item);
        }
      }
    }

    return selectedEvents;
  }

  /// Get date of last Monday (when algorithm refreshes)
  DateTime _getLastMondayDate() {
    final now = DateTime.now();
    final daysFromMonday = (now.weekday - 1) % 7;
    return now.subtract(Duration(days: daysFromMonday));
  }

  /// Get number of weeks since epoch (for weekly consistency)
  int _getWeeksSinceEpoch() {
    final epoch = DateTime(2024, 1, 1); // Start of 2024
    final now = DateTime.now();
    return now.difference(epoch).inDays ~/ 7;
  }

  /// Check if trending data should refresh (every Monday)
  bool shouldRefreshTrendingData() {
    final now = DateTime.now();
    return now.weekday == 1; // Monday
  }
}

/// Data class for trending event with calculated metrics
class TrendingEventData {
  final Event event;
  final double trendingScore;
  final int interestedCount;
  final String timeAgo;
  final int weeklyRank;

  const TrendingEventData({
    required this.event,
    required this.trendingScore,
    required this.interestedCount,
    required this.timeAgo,
    required this.weeklyRank,
  });

  TrendingEventData copyWith({
    Event? event,
    double? trendingScore,
    int? interestedCount,
    String? timeAgo,
    int? weeklyRank,
  }) {
    return TrendingEventData(
      event: event ?? this.event,
      trendingScore: trendingScore ?? this.trendingScore,
      interestedCount: interestedCount ?? this.interestedCount,
      timeAgo: timeAgo ?? this.timeAgo,
      weeklyRank: weeklyRank ?? this.weeklyRank,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendingEventData && other.event.id == event.id;
  }

  @override
  int get hashCode => event.id.hashCode;
} 