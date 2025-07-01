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
      // Check if this is a time-based query for fallback logic
      final queryLower = query.toLowerCase();
      bool isWeekendQuery = queryLower.contains('weekend') || queryLower.contains('this weekend');
      
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
        String? category;
        
        // Handle time-based queries
        DateTime? dateFromObj;
        DateTime? dateToObj;
        
        // Enhanced time-based query detection
        final now = DateTime.now();
        
        if (queryLower.contains('today') || queryLower.contains('happening today')) {
          dateFromObj = DateTime(now.year, now.month, now.day);
          dateToObj = DateTime(now.year, now.month, now.day, 23, 59, 59);
        } else if (queryLower.contains('tomorrow') || queryLower.contains('happening tomorrow')) {
          final tomorrow = now.add(const Duration(days: 1));
          dateFromObj = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
          dateToObj = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);
        } else if (queryLower.contains('this weekend') || (queryLower.contains('weekend') && (queryLower.contains('this') || queryLower.contains('happening')))) {
          // Calculate days until Saturday (weekday 6)
          int daysUntilSaturday = (6 - now.weekday) % 7;
          if (daysUntilSaturday == 0 && now.hour >= 18) {
            daysUntilSaturday = 7;
          }
          final saturday = now.add(Duration(days: daysUntilSaturday));
          final sunday = saturday.add(const Duration(days: 1));
          dateFromObj = DateTime(saturday.year, saturday.month, saturday.day);
          dateToObj = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
        } else if (queryLower.contains('next weekend')) {
          int daysUntilSaturday = (6 - now.weekday) % 7;
          if (daysUntilSaturday <= 1) daysUntilSaturday += 7; // Next weekend
          final saturday = now.add(Duration(days: daysUntilSaturday));
          final sunday = saturday.add(const Duration(days: 1));
          dateFromObj = DateTime(saturday.year, saturday.month, saturday.day);
          dateToObj = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
        } else if (queryLower.contains('this week') || (queryLower.contains('week') && queryLower.contains('this'))) {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          dateFromObj = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          dateToObj = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
        } else if (queryLower.contains('next week') || (queryLower.contains('week') && queryLower.contains('next'))) {
          final startOfNextWeek = now.add(Duration(days: 8 - now.weekday));
          final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
          dateFromObj = DateTime(startOfNextWeek.year, startOfNextWeek.month, startOfNextWeek.day);
          dateToObj = DateTime(endOfNextWeek.year, endOfNextWeek.month, endOfNextWeek.day, 23, 59, 59);
        } else if (queryLower.contains('this month') || (queryLower.contains('month') && queryLower.contains('this'))) {
          dateFromObj = DateTime(now.year, now.month, 1);
          final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
          dateToObj = nextMonth.subtract(const Duration(days: 1)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
        } else if (queryLower.contains('next month') || (queryLower.contains('month') && queryLower.contains('next'))) {
          final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
          dateFromObj = nextMonth;
          final monthAfter = nextMonth.month == 12 ? DateTime(nextMonth.year + 1, 1, 1) : DateTime(nextMonth.year, nextMonth.month + 1, 1);
          dateToObj = monthAfter.subtract(const Duration(days: 1)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
        } else if (queryLower.contains('next few days') || queryLower.contains('coming days') || queryLower.contains('upcoming days')) {
          dateFromObj = DateTime(now.year, now.month, now.day);
          final nextFewDays = now.add(const Duration(days: 5));
          dateToObj = DateTime(nextFewDays.year, nextFewDays.month, nextFewDays.day, 23, 59, 59);
        } else if (queryLower.contains('coming up') || queryLower.contains('happening soon') || queryLower.contains('upcoming')) {
          dateFromObj = DateTime(now.year, now.month, now.day);
          final nextWeek = now.add(const Duration(days: 7));
          dateToObj = DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 23, 59, 59);
        } else if (_isSpecificDayQuery(queryLower)) {
          final dayRange = _calculateSpecificDayRange(queryLower, now);
          dateFromObj = dayRange['from'];
          dateToObj = dayRange['to'];
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
          dateFrom: dateFromObj,
          dateTo: dateToObj,
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
        // If smart search returned no events, try a broader fallback approach
        try {
          // For time-based queries, try without strict date filtering first
          final fallbackResponse = await _eventsService.getEventsWithTotal(
            page: 1,
            perPage: 20,
            sortBy: 'start_date', // Show upcoming events
          );
          
          if (fallbackResponse.isSuccess && fallbackResponse.data!.events.isNotEmpty) {
            var fallbackEvents = fallbackResponse.data!.events;
            
            // For weekend queries, prioritize weekend-friendly events
            if (isWeekendQuery) {
              // Filter for family-friendly or weekend-suitable events
              fallbackEvents = fallbackEvents.where((event) {
                final title = event.title.toLowerCase();
                final category = event.category?.toLowerCase() ?? '';
                final tags = event.tags.map((t) => t.toLowerCase()).toList();
                
                return event.familyScore != null && event.familyScore! > 60 ||
                       tags.any((tag) => ['family', 'weekend', 'kids', 'outdoor', 'brunch'].contains(tag)) ||
                       category.contains('family') ||
                       title.contains('family') ||
                       title.contains('brunch') ||
                       title.contains('weekend');
              }).take(10).toList();
            }
            
            // If we have some relevant events, show them with explanation
            if (fallbackEvents.isNotEmpty) {
              final responseMessage = isWeekendQuery 
                ? "I couldn't find events specifically for this weekend, but here are some great upcoming activities that would be perfect for your weekend plans!"
                : "I found ${fallbackEvents.length} great upcoming events in Dubai! Here are some amazing activities to explore.";
                
              final weekendSuggestionResponse = AISearchResponse(
                results: fallbackEvents.map((event) => RankedEvent(
                  event: event,
                  score: 75,
                  reasoning: isWeekendQuery 
                    ? "Great activity for your weekend plans" 
                    : "Upcoming event you might enjoy",
                )).toList(),
                aiResponse: responseMessage,
                intent: QueryIntent.empty(),
                suggestions: isWeekendQuery 
                  ? ["Next week's events", "Indoor activities", "Family-friendly events", "Free events in Dubai"]
                  : ["Indoor activities", "Outdoor adventures", "Family events", "This weekend's activities"],
              );
              state = AsyncValue.data(weekendSuggestionResponse);
              return;
            }
          }
        } catch (e) {
          // Continue to fallback message if this also fails
        }
        
        // Create final fallback response
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
    } else if (lowerQuery.contains('tomorrow') || lowerQuery.contains('happening tomorrow')) {
      return "Tomorrow looks exciting! I found $eventCount events happening tomorrow in Dubai. Perfect for planning your next day adventure!";
    } else if (lowerQuery.contains('this weekend') || (lowerQuery.contains('weekend') && (lowerQuery.contains('this') || lowerQuery.contains('happening')))) {
      return "Weekend sorted! I found $eventCount events perfect for your weekend plans. Make the most of your time off!";
    } else if (lowerQuery.contains('next weekend')) {
      return "Planning ahead for next weekend! I found $eventCount events that will make your future weekend absolutely amazing!";
    } else if (lowerQuery.contains('this week')) {
      return "Your week just got better! I discovered $eventCount events happening this week in Dubai. Plan your perfect weekday adventures!";
    } else if (lowerQuery.contains('next week')) {
      return "Planning ahead! I found $eventCount events happening next week. Book your spot for these upcoming amazing experiences!";
    } else if (lowerQuery.contains('this month')) {
      return "This month is packed with excitement! I found $eventCount events happening throughout this month. So many amazing experiences await!";
    } else if (lowerQuery.contains('next month')) {
      return "Next month looks incredible! I found $eventCount events to look forward to. Start planning your amazing experiences!";
    } else if (lowerQuery.contains('next few days') || lowerQuery.contains('coming days') || lowerQuery.contains('upcoming days')) {
      return "The next few days are full of possibilities! I found $eventCount events coming up soon. Your perfect activity is just around the corner!";
    } else if (lowerQuery.contains('coming up') || lowerQuery.contains('happening soon') || lowerQuery.contains('upcoming')) {
      return "Exciting times ahead! I found $eventCount upcoming events in Dubai. Get ready for some amazing experiences!";
    } else if (_isSpecificDayQuery(lowerQuery)) {
      final dayName = _extractDayName(lowerQuery);
      return "Perfect for $dayName! I found $eventCount events happening that day. Make it a day to remember!";
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
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('today') || lowerQuery.contains('happening today')) {
      return "I couldn't find events specifically for today, but there are many exciting activities coming up this week! Try searching for 'this week' or explore our categories like 'indoor activities' or 'family events'.";
    } else if (lowerQuery.contains('weekend') || lowerQuery.contains('this weekend')) {
      return "I couldn't find events specifically for this weekend, but there are many great activities available! Try searching for 'this week', 'next week', or explore categories like 'brunch events', 'family activities', or 'indoor experiences'.";
    } else if (lowerQuery.contains('this week')) {
      return "I couldn't find events specifically for this week, but Dubai has many ongoing activities! Try searching for 'next week' or explore categories like 'indoor activities', 'outdoor adventures', or 'cultural experiences'.";
    }
    
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
  
  // Helper function to detect specific day queries
  bool _isSpecificDayQuery(String query) {
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return dayNames.any((day) => query.contains(day)) || 
           query.contains('friday') || query.contains('saturday') || query.contains('sunday');
  }
  
  // Helper function to calculate date range for specific days
  Map<String, DateTime?> _calculateSpecificDayRange(String query, DateTime now) {
    final dayMap = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7
    };
    
    for (final entry in dayMap.entries) {
      if (query.contains(entry.key)) {
        final targetDay = entry.value;
        int daysUntilTarget = (targetDay - now.weekday) % 7;
        if (daysUntilTarget == 0) daysUntilTarget = 7; // Next occurrence if today
        
        final targetDate = now.add(Duration(days: daysUntilTarget));
        return {
          'from': DateTime(targetDate.year, targetDate.month, targetDate.day),
          'to': DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59),
        };
      }
    }
    
    return {'from': null, 'to': null};
  }
  
  // Helper function to extract day name from query
  String _extractDayName(String query) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayNamesLower = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    for (int i = 0; i < dayNamesLower.length; i++) {
      if (query.contains(dayNamesLower[i])) {
        return dayNames[i];
      }
    }
    return 'that day';
  }
}

// AI search provider
final aiSearchProvider = StateNotifierProvider<AISearchNotifier, AsyncValue<AISearchResponse?>>((ref) {
  final eventsService = ref.watch(eventsServiceProvider);
  return AISearchNotifier(eventsService);
});