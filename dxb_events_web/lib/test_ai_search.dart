import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api/perplexity_client.dart';
import 'services/ai_search/query_analyzer.dart';
import 'models/ai_search.dart';

void main() {
  testAISearch();
}

void testAISearch() async {
  print('Testing AI Search Implementation...');
  
  try {
    // Create a mock Perplexity client for testing
    final perplexityClient = MockPerplexityClient();
    final queryAnalyzer = QueryAnalyzer(perplexityClient);
    
    // Test query analysis
    final testQuery = "Indoor activities for my 4-year-old on a rainy weekend under AED 100";
    print('Analyzing query: $testQuery');
    
    final intent = await queryAnalyzer.analyzeQueryIntent(testQuery);
    print('Query intent analyzed:');
    print('- Age groups: ${intent.ageGroups}');
    print('- Budget: ${intent.budget}');
    print('- Areas: ${intent.areas}');
    print('- Activity types: ${intent.activityTypes}');
    print('- Keywords: ${intent.keywords}');
    
    // Test search suggestions
    final suggestions = await queryAnalyzer.generateSearchSuggestions("beach activities");
    print('\nSearch suggestions for "beach activities":');
    for (final suggestion in suggestions) {
      print('- $suggestion');
    }
    
    print('\nAI Search implementation test completed successfully!');
    
  } catch (e) {
    print('Error testing AI search: $e');
  }
}

// Mock implementation for testing without real API calls
class MockPerplexityClient implements PerplexityClient {
  @override
  String get apiKey => 'mock-key';
  
  @override
  Future<Map<String, dynamic>> generateStructuredResponse(String prompt) async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Return mock analysis based on the prompt content
    if (prompt.contains('Indoor activities for my 4-year-old')) {
      return {
        "ageGroups": ["3-5"],
        "budget": "budget",
        "areas": [],
        "activityTypes": ["indoor"],
        "timeOfDay": null,
        "keywords": ["indoor", "4-year-old", "rainy", "weekend"]
      };
    }
    
    if (prompt.contains('beach activities')) {
      return {
        "suggestions": [
          "Beach activities for toddlers this weekend",
          "Beach sports for kids under AED 50",
          "Family-friendly beach clubs in Dubai",
          "Beach picnic spots for families",
          "Water activities at Dubai beaches"
        ]
      };
    }
    
    return {};
  }
  
  @override
  Future<String> generateResponse(String prompt) async {
    await Future.delayed(Duration(milliseconds: 300));
    return "This is a mock response for testing purposes.";
  }
}