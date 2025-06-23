import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing API without family_friendly parameter...');
  
  try {
    // Test without family_friendly
    final response1 = await http.get(
      Uri.parse('http://localhost:3002/api/events/?page=1&per_page=10&sort_by=start_date'),
    );
    
    print('Response without family_friendly: ${response1.statusCode}');
    if (response1.statusCode == 200) {
      final data = json.decode(response1.body);
      print('Success! Got ${data['events'].length} events');
      print('Total events: ${data['pagination']['total']}');
    } else {
      print('Error: ${response1.body}');
    }
    
    print('\n---\n');
    
    // Test with family_friendly=true (this was causing 422 error)
    final response2 = await http.get(
      Uri.parse('http://localhost:3002/api/events/?page=1&per_page=10&sort_by=start_date&family_friendly=true'),
    );
    
    print('Response with family_friendly=true: ${response2.statusCode}');
    if (response2.statusCode == 200) {
      final data = json.decode(response2.body);
      print('Success! Got ${data['events'].length} events');
    } else {
      print('Error: ${response2.body}');
    }
    
  } catch (e) {
    print('Exception: $e');
  }
} 