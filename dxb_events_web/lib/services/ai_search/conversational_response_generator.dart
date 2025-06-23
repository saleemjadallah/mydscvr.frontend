import '../api/perplexity_client.dart';
import '../../models/ai_search.dart';

class ConversationalResponseGenerator {
  final PerplexityClient perplexity;
  
  ConversationalResponseGenerator(this.perplexity);
  
  Future<ConversationalResponse> generateResponse(
    String originalQuery,
    List<RankedEvent> results,
    QueryIntent intent,
  ) async {
    final mainResponse = await _generateMainResponse(originalQuery, results, intent);
    final practicalTips = await _generatePracticalTips(intent, results);
    final followUpSuggestions = await _generateFollowUpSuggestions(originalQuery, intent);
    final keyHighlights = _extractKeyHighlights(results);
    
    return ConversationalResponse(
      mainResponse: mainResponse,
      keyHighlights: keyHighlights,
      practicalTips: practicalTips,
      followUpSuggestions: followUpSuggestions,
    );
  }
  
  Future<String> _generateMainResponse(
    String originalQuery,
    List<RankedEvent> results,
    QueryIntent intent,
  ) async {
    if (results.isEmpty) {
      return _generateNoResultsResponse(originalQuery, intent);
    }
    
    final responsePrompt = """
    Generate a warm, helpful response for a Dubai family's event search.
    
    Original Query: "$originalQuery"
    
    Family Context:
    - Age groups: ${intent.ageGroups.join(', ')}
    - Budget preference: ${intent.budget ?? 'flexible'}
    - Areas of interest: ${intent.areas.join(', ')}
    - Activity types: ${intent.activityTypes.join(', ')}
    
    Top Results Found:
    ${results.take(3).map((e) => '''
    - ${e.event.title} (${e.score}% match)
      Location: ${e.event.venue.area}
      Price: ${e.event.pricing.basePrice == 0 ? 'FREE' : 'AED ${e.event.pricing.basePrice}'}
      Ages: ${e.event.familySuitability.minAge ?? 0}-${e.event.familySuitability.maxAge ?? 99} years
      Why it matches: ${e.reasoning}
    ''').join('\n')}
    
    Generate a friendly response (150-200 words) that:
    1. Acknowledges their specific needs
    2. Highlights the best matches with reasons
    3. Shows excitement about the options
    4. Uses a warm, parent-to-parent tone
    5. Mentions Dubai-specific context
    """;
    
    try {
      return await perplexity.generateResponse(responsePrompt);
    } catch (e) {
      return _generateFallbackResponse(originalQuery, results);
    }
  }
  
  String _generateNoResultsResponse(String query, QueryIntent intent) {
    return """
    I understand you're looking for activities in Dubai, but I couldn't find perfect matches for "$query" right now. 
    
    Let me suggest a few things:
    - Try broadening your search area (Dubai has so many hidden gems!)
    - Consider flexible timing - weekdays often have great family deals
    - Check if there are similar activities in nearby areas like Dubai Marina or JBR
    
    Dubai's family scene is always evolving, so new activities are added regularly. Would you like me to suggest some popular alternatives?
    """;
  }
  
  String _generateFallbackResponse(String query, List<RankedEvent> results) {
    if (results.isEmpty) {
      return "I found some interesting options for your search, though they might not be perfect matches. Dubai has so many family activities - let me help you explore what's available!";
    }
    
    final topEvent = results.first;
    return """
    Great news! I found some wonderful options for your family. 
    
    The top match is ${topEvent.event.title} in ${topEvent.event.venue.area} - it's ${topEvent.event.pricing.basePrice == 0 ? 'completely free' : 'priced at AED ${topEvent.event.pricing.basePrice}'} and perfect for ages ${topEvent.event.familySuitability.minAge ?? 0}-${topEvent.event.familySuitability.maxAge ?? 99}.
    
    Dubai's family scene offers so many possibilities - I've found ${results.length} options that could work for you!
    """;
  }
  
  Future<List<String>> _generatePracticalTips(
    QueryIntent intent,
    List<RankedEvent> results,
  ) async {
    if (results.isEmpty) {
      return _getDefaultDubaiTips();
    }
    
    final tipsPrompt = """
    Generate 3-4 practical tips for Dubai families planning these activities:
    
    Family Profile:
    - Age groups: ${intent.ageGroups.join(', ')}
    - Budget: ${intent.budget ?? 'flexible'}
    - Areas: ${intent.areas.join(', ')}
    
    Top Activities:
    ${results.take(3).map((e) => '- ${e.event.title} in ${e.event.venue.area}').join('\n')}
    
    Focus on Dubai-specific advice like:
    - Best times to visit (weather/crowds)
    - Parking and transportation in Dubai
    - What to bring for Dubai's climate
    - Money-saving tips for families
    - Nearby amenities (food courts, restrooms, etc.)
    
    Return practical, actionable tips as a JSON array.
    """;
    
    try {
      final response = await perplexity.generateStructuredResponse(tipsPrompt);
      if (response is Map && response.containsKey('tips')) {
        return List<String>.from(response['tips']);
      } else if (response is List) {
        return List<String>.from(response as List);
      }
      return _getDefaultDubaiTips();
    } catch (e) {
      return _getDefaultDubaiTips();
    }
  }
  
  Future<List<String>> _generateFollowUpSuggestions(
    String originalQuery,
    QueryIntent intent,
  ) async {
    final suggestionsPrompt = """
    Based on this family's search: "$originalQuery"
    
    Generate 3-4 follow-up search suggestions:
    
    Family context:
    - Ages: ${intent.ageGroups.join(', ')}
    - Preferences: ${intent.activityTypes.join(', ')}
    - Budget: ${intent.budget ?? 'flexible'}
    
    Create suggestions that are:
    - Related but different from original query
    - Specific and actionable
    - Family-focused for Dubai
    - Include variations (different times, areas, activities)
    
    Return as JSON array of search suggestions.
    """;
    
    try {
      final response = await perplexity.generateStructuredResponse(suggestionsPrompt);
      if (response is Map && response.containsKey('suggestions')) {
        return List<String>.from(response['suggestions']);
      } else if (response is List) {
        return List<String>.from(response as List);
      }
      return _getDefaultFollowUpSuggestions(intent);
    } catch (e) {
      return _getDefaultFollowUpSuggestions(intent);
    }
  }
  
  List<String> _extractKeyHighlights(List<RankedEvent> results) {
    final highlights = <String>[];
    
    if (results.isEmpty) return highlights;
    
    final topEvent = results.first;
    highlights.add('Top match: ${topEvent.event.title}');
    
    // Count free events
    final freeEvents = results.where((e) => e.event.pricing.basePrice == 0).length;
    if (freeEvents > 0) {
      highlights.add('$freeEvents FREE option${freeEvents > 1 ? 's' : ''}');
    }
    
    // Check area diversity
    final areas = results.take(5).map((e) => e.event.venue.area).toSet();
    if (areas.length <= 2) {
      highlights.add('All in ${areas.join(' & ')}');
    } else {
      highlights.add('Multiple areas available');
    }
    
    // Average score indication
    final avgScore = results.take(5).map((e) => e.score).reduce((a, b) => a + b) / 5;
    if (avgScore > 85) {
      highlights.add('Excellent matches found');
    } else if (avgScore > 70) {
      highlights.add('Great matches found');
    }
    
    // Age appropriateness
    final ageRanges = results.take(3).map((e) => 
      '${e.event.familySuitability.minAge ?? 0}-${e.event.familySuitability.maxAge ?? 99}'
    ).toSet();
    if (ageRanges.length == 1) {
      highlights.add('Perfect age range');
    }
    
    return highlights;
  }
  
  List<String> _getDefaultDubaiTips() {
    return [
      "Visit early morning or late afternoon to avoid Dubai's peak sun hours",
      "Most malls and indoor venues have excellent air conditioning and family facilities",
      "Many Dubai venues offer free parking - check their websites for details",
      "Bring water bottles and sun protection for outdoor activities",
      "Weekend mornings are often less crowded at popular family spots",
    ];
  }
  
  List<String> _getDefaultFollowUpSuggestions(QueryIntent intent) {
    final suggestions = <String>[];
    
    if (intent.activityTypes.contains('outdoor')) {
      suggestions.add('Indoor alternatives for hot Dubai days');
    } else if (intent.activityTypes.contains('indoor')) {
      suggestions.add('Outdoor activities for nice weather days');
    }
    
    if (intent.budget == 'free') {
      suggestions.add('Budget-friendly paid activities under AED 50');
    } else {
      suggestions.add('Free activities in the same area');
    }
    
    suggestions.add('Weekend family activities in Dubai');
    suggestions.add('Evening activities for families');
    
    return suggestions.take(4).toList();
  }
}

class ConversationalResponse {
  final String mainResponse;
  final List<String> keyHighlights;
  final List<String> practicalTips;
  final List<String> followUpSuggestions;

  const ConversationalResponse({
    required this.mainResponse,
    required this.keyHighlights,
    required this.practicalTips,
    required this.followUpSuggestions,
  });
}