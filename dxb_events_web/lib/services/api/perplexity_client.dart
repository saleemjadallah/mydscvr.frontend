import 'package:dio/dio.dart';
import 'dart:convert';

class PerplexityClient {
  final Dio _dio;
  final String _apiKey;
  
  PerplexityClient({required String apiKey}) 
      : _apiKey = apiKey,
        _dio = Dio() {
    _dio.options.baseUrl = 'https://api.perplexity.ai';
    _dio.options.headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }
  
  Future<Map<String, dynamic>> generateStructuredResponse(String prompt) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': 'llama-3.1-sonar-large-128k-online',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert assistant for Dubai family activities. Always respond with valid JSON when requested.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 1024,
        'temperature': 0.1,
      });
      
      final content = response.data['choices'][0]['message']['content'];
      
      // Clean up response and extract JSON
      final cleanedContent = _extractJsonFromResponse(content);
      return jsonDecode(cleanedContent);
    } catch (e) {
      throw PerplexityApiException('Failed to generate structured response: $e');
    }
  }
  
  Future<String> generateResponse(String prompt) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': 'llama-3.1-sonar-large-128k-online',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful assistant specializing in Dubai family activities. Provide warm, practical advice for parents and families.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 512,
        'temperature': 0.3,
      });
      
      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      throw PerplexityApiException('Failed to generate response: $e');
    }
  }
  
  String _extractJsonFromResponse(String content) {
    // Try to find JSON in the response
    final jsonStart = content.indexOf('{');
    final jsonEnd = content.lastIndexOf('}');
    
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return content.substring(jsonStart, jsonEnd + 1);
    }
    
    // If no JSON found, try to create a basic response
    return '{"error": "No valid JSON found in response"}';
  }
}

class PerplexityApiException implements Exception {
  final String message;
  PerplexityApiException(this.message);
  
  @override
  String toString() => 'PerplexityApiException: $message';
}