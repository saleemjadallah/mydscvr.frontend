/// Test file to verify AI search integration works with backend
import 'dart:convert';
import 'package:flutter/material.dart';
import 'models/ai_search_response.dart';
import 'models/event.dart';
import 'services/events_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Search Test',
      home: const AISearchTestScreen(),
    );
  }
}

class AISearchTestScreen extends StatefulWidget {
  const AISearchTestScreen({super.key});

  @override
  State<AISearchTestScreen> createState() => _AISearchTestScreenState();
}

class _AISearchTestScreenState extends State<AISearchTestScreen> {
  final EventsService _eventsService = EventsService();
  final TextEditingController _queryController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _testAISearch() async {
    if (_queryController.text.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _result = 'Searching...';
    });

    try {
      final response = await _eventsService.aiSearch(
        query: _queryController.text.trim(),
        page: 1,
        perPage: 5,
      );

      if (response.isSuccess && response.data != null) {
        final aiResult = response.data!;
        
        setState(() {
          _result = '''
✅ AI Search Success!

🤖 AI Response: ${aiResult.aiResponse}

📊 Results: ${aiResult.events.length} events found
📈 Total Events: ${aiResult.total}
⏱️ Processing Time: ${aiResult.processingTimeMs}ms
🔬 AI Enabled: ${aiResult.aiEnabled}

🎯 Query Analysis:
- Intent: ${aiResult.queryAnalysis.intent}
- Time Period: ${aiResult.queryAnalysis.timePeriod ?? 'Not specified'}
- Categories: ${aiResult.queryAnalysis.categories.join(', ')}
- Keywords: ${aiResult.queryAnalysis.keywords.join(', ')}
- Confidence: ${(aiResult.queryAnalysis.confidence * 100).toStringAsFixed(1)}%

💡 Suggestions:
${aiResult.suggestions.map((s) => '• $s').join('\n')}

🎪 Events with AI Scores:
${aiResult.events.take(3).map((e) => '''
📍 ${e.title}
   🎯 AI Score: ${e.aiScore ?? 'N/A'}
   💭 AI Reasoning: ${e.aiReasoning ?? 'N/A'}
   ✨ AI Highlights: ${e.aiHighlights?.join(', ') ?? 'N/A'}
   📅 ${e.startDate.toString().substring(0, 10)}
   🏷️ ${e.displayPrice}
''').join('\n')}
          ''';
        });
      } else {
        setState(() {
          _result = '❌ Error: ${response.error}';
        });
      }
    } catch (e) {
      setState(() {
        _result = '💥 Exception: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Search Integration Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: 'Enter search query',
                hintText: 'e.g., "family activities this weekend"',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _testAISearch(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAISearch,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Test AI Search'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Enter a query and tap "Test AI Search" to see results...' : _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}