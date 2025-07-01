import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/events_service.dart';
import '../models/ai_search.dart';
import '../models/event.dart';

// Events service provider
final eventsServiceProvider = Provider<EventsService>((ref) {
  return EventsService();
});

// AI search state notifier using pure backend approach
class AISearchNotifier extends StateNotifier<AsyncValue<AISearchResponse?>> {
  final EventsService _eventsService;
  
  AISearchNotifier(this._eventsService) : super(const AsyncValue.data(null));
  
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      // Try to use the smartSearch endpoint first
      dynamic eventsResponse;
      
      try {
        eventsResponse = await _eventsService.smartSearch(
          query: query,
          page: 1,
          perPage: 20,
        );
      } catch (e) {
        // If smart search fails, fall back to regular events with enhanced filtering
        final queryLower = query.toLowerCase();
        String? category;
        String? dateFrom;
        String? dateTo;
        
        // Handle time-based queries
        if (queryLower.contains('today') || queryLower.contains('happening today')) {
          final today = DateTime.now();
          dateFrom = today.toIso8601String().split('T')[0];
          dateTo = dateFrom;
        } else if (queryLower.contains('this weekend') || queryLower.contains('weekend')) {
          final now = DateTime.now();
          final daysUntilSaturday = (6 - now.weekday) % 7;
          final saturday = now.add(Duration(days: daysUntilSaturday));
          final sunday = saturday.add(const Duration(days: 1));
          dateFrom = saturday.toIso8601String().split('T')[0];
          dateTo = sunday.toIso8601String().split('T')[0];
        } else if (queryLower.contains('this week')) {
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          dateFrom = startOfWeek.toIso8601String().split('T')[0];
          dateTo = endOfWeek.toIso8601String().split('T')[0];
        } else if (queryLower.contains('next week')) {
          final now = DateTime.now();
          final startOfNextWeek = now.add(Duration(days: 8 - now.weekday));
          final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
          dateFrom = startOfNextWeek.toIso8601String().split('T')[0];
          dateTo = endOfNextWeek.toIso8601String().split('T')[0];
        }
        
        // Try to detect category from query
        if (queryLower.contains('food') || queryLower.contains('brunch') || queryLower.contains('dining')) {
          category = 'food_and_dining';
        } else if (queryLower.contains('indoor')) {
          category = 'indoor_activities';
        } else if (queryLower.contains('outdoor')) {
          category = 'outdoor_activities';
        } else if (queryLower.contains('kids') || queryLower.contains('family')) {
          category = 'kids_and_family';
        } else if (queryLower.contains('water') || queryLower.contains('beach')) {
          category = 'water_sports';
        }
        
        eventsResponse = await _eventsService.getEventsWithTotal(
          category: category,
          dateFrom: dateFrom,
          dateTo: dateTo,
          page: 1,
          perPage: 50, // Get more events to filter locally
        );
      }
      
      if (eventsResponse.isSuccess && eventsResponse.data != null) {
        var events = eventsResponse.data!.events;
        
        // If we used the fallback method, filter events locally based on query
        if (events.length > 20) {
          final queryLower = query.toLowerCase();
          events = events.where((event) {
            final titleMatch = event.title.toLowerCase().contains(queryLower);
            final descriptionMatch = (event.description ?? '').toLowerCase().contains(queryLower);
            final categoryMatch = (event.category ?? '').toLowerCase().contains(queryLower);
            final venueMatch = event.venue.name.toLowerCase().contains(queryLower) ||
                               event.venue.area.toLowerCase().contains(queryLower);
            final tagMatch = event.tags.any((tag) => tag.toLowerCase().contains(queryLower));
            
            return titleMatch || descriptionMatch || categoryMatch || venueMatch || tagMatch;
          }).take(20).toList();
        }
        
        // Generate AI-style response based on search results
        final aiResponse = _generateSmartResponse(query, events);
        
        // Create ranked events with simple scoring
        final rankedEvents = <RankedEvent>[];
        for (final event in events) {
          rankedEvents.add(RankedEvent(
            event: event,
            score: _calculateRelevanceScore(query, event).toInt(),
            reasoning: _generateBasicReasoning(query, event),
          ));
        }
        
        // Sort by relevance score
        rankedEvents.sort((a, b) => b.score.compareTo(a.score));
        
        // Generate smart suggestions based on results
        final suggestions = _generateSmartSuggestions(query, events);
        
        final searchResponse = AISearchResponse(
          results: rankedEvents,
          aiResponse: aiResponse,
          intent: QueryIntent.empty(),
          suggestions: suggestions,
        );
        
        state = AsyncValue.data(searchResponse);
      } else {
        // Create fallback response
        final fallbackResponse = AISearchResponse(
          results: const [],
          aiResponse: _createFallbackMessage(query),
          intent: QueryIntent.empty(),
          suggestions: _getPopularSearches(),
        );
        state = AsyncValue.data(fallbackResponse);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  String _generateSmartResponse(String query, List<Event> events) {
    if (events.isEmpty) {
      return _createFallbackMessage(query);
    }
    
    final lowerQuery = query.toLowerCase();
    final eventCount = events.length;
    
    // Generate contextual response based on query type
    if (lowerQuery.contains('today') || lowerQuery.contains('happening today')) {
      return "Perfect timing! I found $eventCount exciting events happening today in Dubai. From cultural experiences to family fun, there's something happening right now!";
    } else if (lowerQuery.contains('this weekend') || lowerQuery.contains('weekend')) {
      return "Weekend sorted! I found $eventCount events perfect for your weekend plans. Make the most of your time off!";
    } else if (lowerQuery.contains('this week')) {
      return "Your week just got better! I discovered $eventCount events happening this week in Dubai. Plan your perfect weekday adventures!";
    } else if (lowerQuery.contains('next week')) {
      return "Planning ahead! I found $eventCount events happening next week. Book your spot for these upcoming amazing experiences!";
    } else if (lowerQuery.contains('brunch')) {
      return "I found $eventCount amazing brunch experiences in Dubai! From beachfront venues to rooftop brunches, Dubai offers incredible dining experiences for every taste and budget.";
    } else if (lowerQuery.contains('family') || lowerQuery.contains('kids')) {
      return "Perfect! I discovered $eventCount family-friendly activities. These events are designed to create wonderful memories for both kids and adults.";
    } else if (lowerQuery.contains('free')) {
      return "Great news! I found $eventCount free events happening in Dubai. Enjoy amazing experiences without spending a dirham!";
    } else if (lowerQuery.contains('indoor')) {
      return "Stay cool! I found $eventCount indoor activities perfect for escaping Dubai's heat while having amazing experiences.";
    } else if (lowerQuery.contains('outdoor')) {
      return "Adventure awaits! I discovered $eventCount outdoor activities. Dubai's weather is perfect for these exciting experiences.";
    } else {
      return "I found $eventCount events matching '$query'. Dubai offers incredible experiences for every interest!";
    }
  }
  
  double _calculateRelevanceScore(String query, Event event) {
    final queryLower = query.toLowerCase();
    final titleLower = event.title.toLowerCase();
    final descriptionLower = (event.description ?? '').toLowerCase();
    final categoryLower = (event.category ?? '').toLowerCase();
    final tagsLower = event.tags.map((t) => t.toLowerCase()).toList();
    
    double score = 0;
    
    // Title matching (highest weight)
    if (titleLower.contains(queryLower)) {
      score += 10.0;
    } else if (queryLower.split(' ').any((word) => titleLower.contains(word))) {
      score += 5.0;
    }
    
    // Category matching
    if (categoryLower.contains(queryLower) || queryLower.contains(categoryLower)) {
      score += 7.0;
    }
    
    // Tag matching
    for (final tag in tagsLower) {
      if (tag.contains(queryLower) || queryLower.contains(tag)) {
        score += 6.0;
        break;
      }
    }
    
    // Description matching
    if (descriptionLower.contains(queryLower)) {
      score += 3.0;
    }
    
    // Venue matching
    final venueLower = event.venue.name.toLowerCase();
    if (venueLower.contains(queryLower)) {
      score += 4.0;
    }
    
    // Family score bonus for family queries
    if ((queryLower.contains('family') || queryLower.contains('kids')) && 
        event.familyScore != null && event.familyScore! > 70) {
      score += 5.0;
    }
    
    // Free event bonus for free queries
    if (queryLower.contains('free') && event.isFree) {
      score += 8.0;
    }
    
    return score;
  }
  
  String _generateBasicReasoning(String query, Event event) {
    final queryLower = query.toLowerCase();
    final reasons = <String>[];
    
    // Check title match
    if (event.title.toLowerCase().contains(queryLower)) {
      reasons.add("Title directly matches your search");
    }
    
    // Check category
    if (event.category != null && event.category!.toLowerCase().contains(queryLower)) {
      reasons.add("Perfect category match");
    }
    
    // Check tags
    if (event.tags.any((tag) => tag.toLowerCase().contains(queryLower))) {
      reasons.add("Tagged with relevant keywords");
    }
    
    // Check special attributes
    if (queryLower.contains('free') && event.isFree) {
      reasons.add("Free entry!");
    }
    
    if ((queryLower.contains('family') || queryLower.contains('kids')) && 
        event.familyScore != null && event.familyScore! > 70) {
      reasons.add("Highly rated for families");
    }
    
    if (queryLower.contains('indoor') && 
        (event.tags.contains('indoor') || event.category?.contains('indoor') == true)) {
      reasons.add("Indoor activity - beat the heat!");
    }
    
    // Add venue info
    if (event.venue.area.isNotEmpty) {
      reasons.add("Located in ${event.venue.area}");
    }
    
    return reasons.isEmpty 
        ? "Matches your search criteria" 
        : reasons.join(" • ");
  }
  
  List<String> _generateSmartSuggestions(String query, List<Event> events) {
    final suggestions = <String>[];
    final queryLower = query.toLowerCase();
    
    // Add related category suggestions
    final categories = events.map((e) => e.category).where((c) => c != null).toSet();
    for (final category in categories.take(2)) {
      final formattedCategory = category!.replaceAll('_', ' ').split(' ')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
      suggestions.add("More $formattedCategory events");
    }
    
    // Add area-based suggestions
    final areas = events.map((e) => e.venue.area).where((a) => a.isNotEmpty).toSet();
    for (final area in areas.take(2)) {
      suggestions.add("Events in $area");
    }
    
    // Add time-based suggestions (prioritize these)
    if (!queryLower.contains('today')) {
      suggestions.add("Events happening today");
    }
    
    if (!queryLower.contains('weekend') && !queryLower.contains('this weekend')) {
      suggestions.add("This weekend's activities");
    }
    
    if (!queryLower.contains('this week')) {
      suggestions.add("Events this week");
    }
    
    if (!queryLower.contains('next week')) {
      suggestions.add("Next week's events");
    }
    
    // Add price-based suggestions
    if (!queryLower.contains('free') && events.any((e) => e.isFree)) {
      suggestions.add("Free events in Dubai");
    }
    
    if (!queryLower.contains('budget') && !queryLower.contains('cheap')) {
      suggestions.add("Budget-friendly activities");
    }
    
    // Add family and age-specific suggestions
    if (!queryLower.contains('family') && !queryLower.contains('kids')) {
      suggestions.add("Family-friendly events");
    }
    
    // Add popular searches based on context
    if (queryLower.contains('indoor') || queryLower.contains('outdoor')) {
      suggestions.addAll([
        queryLower.contains('indoor') ? "Outdoor adventures" : "Indoor activities",
        "Beach activities",
        "Cultural experiences",
      ]);
    } else {
      suggestions.addAll([
        "Indoor activities",
        "Outdoor adventures", 
        "Kids workshops",
        "Cultural experiences",
      ]);
    }
    
    // Remove duplicates and limit
    return suggestions.toSet().take(6).toList();
  }
  
  String _createFallbackMessage(String query) {
    return "I couldn't find specific events matching '$query', but Dubai has many amazing activities to explore! Try searching for categories like 'indoor activities', 'family events', or 'weekend brunch'.";
  }
  
  List<String> _getPopularSearches() {
    return [
      "Events happening today",
      "This weekend's activities", 
      "Free family events",
      "Indoor kids activities",
      "Weekend brunch deals",
      "Beach and water sports",
      "Cultural experiences",
      "Budget-friendly activities",
    ];
  }
  
  List<String> getPopularSearches() => _getPopularSearches();
}

// AI search provider
final aiSearchProvider = StateNotifierProvider<AISearchNotifier, AsyncValue<AISearchResponse?>>((ref) {
  final eventsService = ref.watch(eventsServiceProvider);
  return AISearchNotifier(eventsService);
});