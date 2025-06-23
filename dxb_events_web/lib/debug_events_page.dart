import 'package:flutter/material.dart';
import 'services/events_service.dart';
import 'models/event.dart';

class DebugEventsPage extends StatefulWidget {
  const DebugEventsPage({Key? key}) : super(key: key);

  @override
  State<DebugEventsPage> createState() => _DebugEventsPageState();
}

class _DebugEventsPageState extends State<DebugEventsPage> {
  final EventsService _eventsService = EventsService();
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  String _debugOutput = '';

  void _addDebugLog(String message) {
    setState(() {
      _debugOutput += '${DateTime.now().toIso8601String()}: $message\n';
    });
    print(message);
  }

  Future<void> _testApiCall() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _debugOutput = '';
    });

    _addDebugLog('🔍 Starting API test...');

    try {
      _addDebugLog('🔍 Calling EventsService.getEvents()...');
      final response = await _eventsService.getEvents(
        perPage: 20,
        sortBy: 'start_date',
      );

      _addDebugLog('🔍 Response received: isSuccess=${response.isSuccess}');
      
      if (response.isSuccess) {
        final events = response.data ?? [];
        _addDebugLog('🔍 Events loaded: ${events.length} events');
        
        setState(() {
          _events = events;
          _isLoading = false;
        });

        if (events.isNotEmpty) {
          _addDebugLog('🔍 First event: ${events.first.title}');
          _addDebugLog('🔍 First event date: ${events.first.startDate}');
        }
      } else {
        _addDebugLog('❌ API call failed: ${response.error}');
        setState(() {
          _error = response.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      _addDebugLog('❌ Exception occurred: $e');
      setState(() {
        _error = 'Exception: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events API Debug'),
        backgroundColor: const Color(0xFF0D7377),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testApiCall,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Test API Call'),
            ),
            const SizedBox(height: 16),
            
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'Events Count: ${_events.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Column(
                children: [
                  // Debug output
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _debugOutput.isEmpty ? 'No debug output yet' : _debugOutput,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Events list
                  Expanded(
                    flex: 2,
                    child: _events.isEmpty
                      ? const Center(child: Text('No events loaded'))
                      : ListView.builder(
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            return Card(
                              child: ListTile(
                                title: Text(event.title),
                                subtitle: Text('${event.startDate}'),
                                trailing: event.pricing.basePrice == 0
                                  ? const Chip(label: Text('Free'))
                                  : Text('${event.pricing.basePrice} AED'),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 