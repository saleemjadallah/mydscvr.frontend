import '../api/perplexity_client.dart';
import '../../models/ai_search.dart';

part 'query_analyzer.g.dart';

class QueryAnalyzer {
  final PerplexityClient perplexity;
  
  QueryAnalyzer(this.perplexity);
  
  Future<QueryIntent> analyzeQueryIntent(String query) async {
    final analysisPrompt = """
    Analyze this Dubai family event search query and extract structured information:
    
    Query: "$query"
    
    Return JSON with this exact structure:
    {
      "ageGroups": ["3-5", "6-12"],
      "budget": "budget",
      "areas": ["Dubai Marina", "Downtown"],
      "activityTypes": ["outdoor", "educational"],
      "timeOfDay": "morning",
      "keywords": ["beach", "kids", "fun"]
    }
    
    Guidelines:
    - ageGroups: Extract age ranges mentioned (e.g., "toddler" = "0-2", "kids" = "3-12", "teenagers" = "13-17")
    - budget: "free" if free/budget mentioned, "premium" if luxury/expensive mentioned, null otherwise
    - areas: Dubai locations mentioned (Dubai Marina, Downtown, JBR, DIFC, etc.)
    - activityTypes: ["outdoor", "indoor", "educational", "sports", "creative", "cultural", "food"]
    - timeOfDay: "morning", "afternoon", "evening", or null
    - keywords: Important search terms from the query
    """;
    
    try {
      final analysis = await perplexity.generateStructuredResponse(analysisPrompt);
      return QueryIntent.fromJson(analysis);
    } catch (e) {
      // Return empty intent if analysis fails
      return QueryIntent.empty();
    }
  }
  
  Future<List<String>> generateSearchSuggestions(String partialQuery) async {
    if (partialQuery.trim().length < 3) {
      return _getDefaultSuggestions();
    }
    
    final suggestionsPrompt = """
    Based on this partial query: "$partialQuery"
    
    Generate 5 smart search suggestions for Dubai family activities.
    
    Return JSON array of strings like:
    ["Beach activities for toddlers this weekend", "Indoor workshops for 6-8 year olds", ...]
    
    Make suggestions:
    - Specific and actionable
    - Family-focused for Dubai
    - Include age ranges, locations, or activity types
    - Complete the user's likely intent
    """;
    
    try {
      final response = await perplexity.generateStructuredResponse(suggestionsPrompt);
      if (response is Map && response.containsKey('suggestions')) {
        return List<String>.from(response['suggestions']);
      } else if (response is List) {
        return List<String>.from(response as List);
      }
      return _getDefaultSuggestions();
    } catch (e) {
      return _getDefaultSuggestions();
    }
  }
  
  List<String> _getDefaultSuggestions() {
    return [
      "Beach activities for toddlers this weekend",
      "Indoor workshops for 6-8 year olds under AED 50",
      "Educational activities near Dubai Mall",
      "Free outdoor activities for families",
      "Weekend activities for teenagers",
    ];
  }
  
  Future<List<String>> generateFollowUpQuestions(String originalQuery, QueryIntent intent) async {
    final followUpPrompt = """
    User searched for: "$originalQuery"
    
    Based on their search, generate 3-4 helpful follow-up questions they might want to ask next.
    
    Context:
    - Age groups interested in: ${intent.ageGroups.join(', ')}
    - Budget preference: ${intent.budget ?? 'not specified'}
    - Areas: ${intent.areas.join(', ')}
    - Activity types: ${intent.activityTypes.join(', ')}
    
    Return JSON array of follow-up questions like:
    ["What about similar activities next week?", "Are there indoor alternatives?", ...]
    
    Make questions:
    - Natural and conversational
    - Related but different from original query
    - Dubai-specific
    - Family-focused
    """;
    
    try {
      final response = await perplexity.generateStructuredResponse(followUpPrompt);
      if (response is Map && response.containsKey('questions')) {
        return List<String>.from(response['questions']);
      } else if (response is List) {
        return List<String>.from(response as List);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}