import '../api/perplexity_client.dart';
import '../events_service.dart';
import '../../models/ai_search.dart';
import '../../models/event.dart';
import 'query_analyzer.dart';
import 'ai_ranking_service.dart';
import 'conversational_response_generator.dart';

class IntelligentSearchEngine {
  final PerplexityClient _perplexityClient;
  final EventsService _eventsService;
  final QueryAnalyzer _queryAnalyzer;
  final AIRankingService _rankingService;
  final ConversationalResponseGenerator _responseGenerator;
  
  IntelligentSearchEngine({
    required PerplexityClient perplexityClient,
    required EventsService eventsService,
  }) : _perplexityClient = perplexityClient,
       _eventsService = eventsService,
       _queryAnalyzer = QueryAnalyzer(perplexityClient),
       _rankingService = AIRankingService(perplexityClient),
       _responseGenerator = ConversationalResponseGenerator(perplexityClient);

  Future<AISearchResponse> processIntelligentSearch(String query) async {
    try {
      // Step 1: Analyze the query to understand intent
      final queryIntent = await _queryAnalyzer.analyzeQueryIntent(query);
      
      // Step 2: Get events from the backend based on basic filters
      final events = await _getRelevantEvents(queryIntent);
      
      // Step 3: Use AI to rank events based on query and intent
      final rankedEvents = await _rankingService.rankEvents(query, events, queryIntent);
      
      // Step 4: Generate conversational response
      final conversationalResponse = await _responseGenerator.generateResponse(
        query, 
        rankedEvents, 
        queryIntent
      );
      
      // Step 5: Generate follow-up suggestions
      final suggestions = await _queryAnalyzer.generateFollowUpQuestions(query, queryIntent);
      
      return AISearchResponse(
        results: rankedEvents,
        aiResponse: conversationalResponse.mainResponse,
        intent: queryIntent,
        suggestions: suggestions,
      );
      
    } catch (e) {
      // Return fallback response if AI processing fails
      return _createFallbackResponse(query);
    }
  }
  
  Future<List<Event>> _getRelevantEvents(QueryIntent intent) async {
    // Start with all events
    final response = await _eventsService.getEvents();
    var events = response.data ?? <Event>[];
    
    // Apply basic filters based on intent
    events = _applyBasicFilters(events, intent);
    
    // Limit to reasonable number for AI processing
    return events.take(50).toList();
  }
  
  List<Event> _applyBasicFilters(List<Event> events, QueryIntent intent) {
    var filteredEvents = events;
    
    // Filter by budget if specified
    if (intent.budget != null) {
      filteredEvents = filteredEvents.where((event) {
        switch (intent.budget) {
          case 'free':
            return event.pricing.basePrice == 0;
          case 'budget':
            return event.pricing.basePrice <= 100;
          case 'premium':
            return event.pricing.basePrice > 100;
          default:
            return true;
        }
      }).toList();
    }
    
    // Filter by area if specified
    if (intent.areas.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final eventArea = event.venue.area.toLowerCase();
        return intent.areas.any((area) =>
          eventArea.contains(area.toLowerCase()) ||
          area.toLowerCase().contains(eventArea)
        );
      }).toList();
    }
    
    // Filter by activity type if specified
    if (intent.activityTypes.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final eventCategories = event.categories.map((c) => c.toLowerCase()).toList();
        return intent.activityTypes.any((type) =>
          eventCategories.any((category) =>
            category.contains(type.toLowerCase()) ||
            type.toLowerCase().contains(category)
          )
        );
      }).toList();
    }
    
    // Filter by age appropriateness if specified
    if (intent.ageGroups.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        return _isEventAgeAppropriate(event, intent.ageGroups);
      }).toList();
    }
    
    // Sort by family score to prioritize family-friendly events
    filteredEvents.sort((a, b) => (b.familyScore ?? 0).compareTo(a.familyScore ?? 0));
    
    return filteredEvents;
  }
  
  bool _isEventAgeAppropriate(Event event, List<String> ageGroups) {
    for (final ageGroup in ageGroups) {
      final range = _parseAgeGroup(ageGroup);
      if (range != null) {
        // Check if there's overlap between requested age range and event age range
        if (!(range['max']! < (event.familySuitability.minAge ?? 0) || 
              range['min']! > (event.familySuitability.maxAge ?? 99))) {
          return true;
        }
      }
    }
    return ageGroups.isEmpty; // If no age groups specified, include all events
  }
  
  Map<String, int>? _parseAgeGroup(String ageGroup) {
    // Handle common age group patterns
    final patterns = {
      'toddler': {'min': 1, 'max': 3},
      'toddlers': {'min': 1, 'max': 3},
      'baby': {'min': 0, 'max': 1},
      'babies': {'min': 0, 'max': 1},
      'preschool': {'min': 3, 'max': 5},
      'kids': {'min': 3, 'max': 12},
      'children': {'min': 3, 'max': 12},
      'teenagers': {'min': 13, 'max': 17},
      'teens': {'min': 13, 'max': 17},
      'adults': {'min': 18, 'max': 99},
    };
    
    final lowerAgeGroup = ageGroup.toLowerCase();
    
    // Check for exact pattern matches
    for (final pattern in patterns.entries) {
      if (lowerAgeGroup.contains(pattern.key)) {
        return pattern.value;
      }
    }
    
    // Parse numeric ranges like "3-5", "6-12"
    final regex = RegExp(r'(\d+)-(\d+)');
    final match = regex.firstMatch(ageGroup);
    if (match != null) {
      return {
        'min': int.parse(match.group(1)!),
        'max': int.parse(match.group(2)!),
      };
    }
    
    // Parse single ages like "4", "8"
    final singleAge = int.tryParse(ageGroup);
    if (singleAge != null) {
      return {
        'min': singleAge,
        'max': singleAge + 2, // Assume 2-year range
      };
    }
    
    return null;
  }
  
  AISearchResponse _createFallbackResponse(String query) {
    return AISearchResponse(
      results: const [],
      aiResponse: """
      I'm having trouble processing your search right now, but I'm here to help! 
      
      Dubai has so many amazing family activities - try searching for specific things like:
      - "Beach activities for kids"
      - "Indoor activities Dubai Mall"
      - "Free family events this weekend"
      
      You can also browse our categories to discover great options for your family!
      """,
      intent: QueryIntent.empty(),
      suggestions: [
        'Beach activities for families',
        'Indoor entertainment in Dubai',
        'Free weekend activities',
        'Kids workshops and classes',
      ],
    );
  }
  
  // Quick search suggestions for autocomplete
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    return await _queryAnalyzer.generateSearchSuggestions(partialQuery);
  }
  
  // Get popular search examples
  List<String> getPopularSearches() {
    return [
      "Beach activities for toddlers this weekend",
      "Indoor workshops for 6-8 year olds under AED 50",
      "Educational activities near Dubai Mall",
      "Free outdoor activities for families",
      "Evening activities for teenagers",
      "Stroller-friendly activities in Dubai Marina",
    ];
  }
}