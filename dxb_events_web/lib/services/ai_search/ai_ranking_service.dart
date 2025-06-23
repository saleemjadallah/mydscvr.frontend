import '../api/perplexity_client.dart';
import '../../models/ai_search.dart';
import '../../models/event.dart';

part 'ai_ranking_service.g.dart';

class AIRankingService {
  final PerplexityClient perplexity;
  
  AIRankingService(this.perplexity);
  
  Future<List<RankedEvent>> rankEvents(
    String originalQuery,
    List<Event> events,
    QueryIntent intent,
  ) async {
    if (events.isEmpty) return [];
    
    // Score events using AI
    final scoredEvents = await _scoreEventRelevance(originalQuery, events, intent);
    
    // Apply family-specific ranking factors
    final familyRanked = _applyFamilyRankingFactors(scoredEvents, intent);
    
    // Sort by final score
    familyRanked.sort((a, b) => b.score.compareTo(a.score));
    
    return familyRanked;
  }
  
  Future<List<RankedEvent>> _scoreEventRelevance(
    String query,
    List<Event> events,
    QueryIntent intent,
  ) async {
    // Create a simplified prompt for better reliability
    final scoringPrompt = """
    Score these Dubai events for relevance to this family query: "$query"
    
    Family Context:
    - Budget: ${intent.budget ?? 'not specified'}
    - Areas of interest: ${intent.areas.join(', ')}
    - Activity types: ${intent.activityTypes.join(', ')}
    - Age groups: ${intent.ageGroups.join(', ')}
    
    Events (first 10):
    ${events.take(10).map((e) => {
      'id': e.id,
      'title': e.title,
      'area': e.venue.area,
      'price': e.pricing.basePrice,
      'ageRange': '${e.familySuitability.minAge ?? 0}-${e.familySuitability.maxAge ?? 99}',
      'categories': e.categories.take(3).toList(),
    }).toList()}
    
    Return JSON array with scores (0-100):
    [
      {
        "eventId": "event_id",
        "score": 85,
        "reasoning": "Great match because..."
      }
    ]
    """;
    
    try {
      final response = await perplexity.generateStructuredResponse(scoringPrompt);
      final scores = <RankedEvent>[];
      
      if (response is List) {
        for (final scoreData in response as List) {
          if (scoreData is Map<String, dynamic>) {
            final eventId = scoreData['eventId'] as String?;
            final score = scoreData['score'] as int? ?? 50;
            final reasoning = scoreData['reasoning'] as String? ?? 'AI analysis';
            
            final event = events.firstWhere(
              (e) => e.id == eventId,
              orElse: () => events.first,
            );
            
            scores.add(RankedEvent(
              event: event,
              score: score,
              reasoning: reasoning,
            ));
          }
        }
      }
      
      // Fill in any missing events with default scores
      for (final event in events) {
        if (!scores.any((s) => s.event.id == event.id)) {
          scores.add(RankedEvent(
            event: event,
            score: _calculateBasicScore(event, intent),
            reasoning: 'Basic compatibility score',
          ));
        }
      }
      
      return scores;
    } catch (e) {
      // Fallback to basic scoring if AI fails
      return events.map((event) => RankedEvent(
        event: event,
        score: _calculateBasicScore(event, intent),
        reasoning: 'Fallback scoring due to AI error',
      )).toList();
    }
  }
  
  List<RankedEvent> _applyFamilyRankingFactors(
    List<RankedEvent> rankedEvents,
    QueryIntent intent,
  ) {
    return rankedEvents.map((rankedEvent) {
      int bonus = 0;
      
      // Age appropriateness bonus
      if (_isAgeAppropriate(rankedEvent.event, intent.ageGroups)) {
        bonus += 15;
      }
      
      // Budget match bonus
      if (_isBudgetMatch(rankedEvent.event, intent.budget)) {
        bonus += 10;
      }
      
      // Location preference bonus
      if (_isLocationMatch(rankedEvent.event, intent.areas)) {
        bonus += 10;
      }
      
      // Activity type match bonus
      if (_isActivityTypeMatch(rankedEvent.event, intent.activityTypes)) {
        bonus += 10;
      }
      
      // High family score bonus
      if ((rankedEvent.event.familyScore ?? 0) > 80) {
        bonus += 5;
      }
      
      // Free event bonus for budget-conscious families
      if (intent.budget == 'free' && rankedEvent.event.pricing.basePrice == 0) {
        bonus += 15;
      }
      
      final finalScore = (rankedEvent.score + bonus).clamp(0, 100);
      
      return RankedEvent(
        event: rankedEvent.event,
        score: finalScore,
        reasoning: rankedEvent.reasoning,
      );
    }).toList();
  }
  
  int _calculateBasicScore(Event event, QueryIntent intent) {
    int score = 50; // Base score
    
    // Age appropriateness
    if (_isAgeAppropriate(event, intent.ageGroups)) {
      score += 20;
    }
    
    // Budget compatibility
    if (_isBudgetMatch(event, intent.budget)) {
      score += 15;
    }
    
    // Location match
    if (_isLocationMatch(event, intent.areas)) {
      score += 10;
    }
    
    // Activity type match
    if (_isActivityTypeMatch(event, intent.activityTypes)) {
      score += 15;
    }
    
    // Family score factor
    score += ((event.familyScore ?? 0) * 0.2).round();
    
    return score.clamp(0, 100);
  }
  
  bool _isAgeAppropriate(Event event, List<String> ageGroups) {
    if (ageGroups.isEmpty) return true;
    
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
    return false;
  }
  
  bool _isBudgetMatch(Event event, String? budget) {
    if (budget == null) return true;
    
    final eventPrice = event.pricing.basePrice;
    
    switch (budget) {
      case 'free':
        return eventPrice == 0;
      case 'budget':
        return eventPrice <= 100;
      case 'premium':
        return true; // No upper limit for premium
      default:
        return true;
    }
  }
  
  bool _isLocationMatch(Event event, List<String> areas) {
    if (areas.isEmpty) return true;
    
    final eventArea = event.venue.area.toLowerCase();
    return areas.any((area) => 
      eventArea.contains(area.toLowerCase()) || 
      area.toLowerCase().contains(eventArea)
    );
  }
  
  bool _isActivityTypeMatch(Event event, List<String> activityTypes) {
    if (activityTypes.isEmpty) return true;
    
    final eventCategories = event.categories.map((c) => c.toLowerCase()).toList();
    return activityTypes.any((type) =>
      eventCategories.any((category) => 
        category.contains(type.toLowerCase()) || 
        type.toLowerCase().contains(category)
      )
    );
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
}