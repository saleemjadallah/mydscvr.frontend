import 'package:flutter_test/flutter_test.dart';
import 'package:dxb_events_web/data/sample_events.dart';
import 'package:dxb_events_web/models/event.dart';

void main() {
  group('Sample Events Data Tests', () {
    test('should have sample events available', () {
      final events = SampleEvents.sampleEvents;
      
      expect(events, isNotEmpty);
      expect(events.length, greaterThan(0));
    });
    
    test('should have valid event properties', () {
      final event = SampleEvents.sampleEvents.first;
      
      expect(event.id, isNotEmpty);
      expect(event.title, isNotEmpty);
      expect(event.description, isNotEmpty);
      expect(event.venue.name, isNotEmpty);
      expect(event.venue.area, isNotEmpty);
      expect(event.pricing.currency, equals('AED'));
      expect(event.rating, greaterThan(0));
      expect(event.rating, lessThanOrEqualTo(5));
    });
    
    test('should have Dubai Aquarium as first event', () {
      final event = SampleEvents.sampleEvents.first;
      
      expect(event.title, contains('Dubai Aquarium'));
      expect(event.venue.area, equals('Downtown Dubai'));
      expect(event.pricing.basePrice, equals(149));
    });
    
    test('should have all events with valid pricing', () {
      final events = SampleEvents.sampleEvents;
      
      for (final event in events) {
        expect(event.pricing.basePrice, greaterThanOrEqualTo(0));
        expect(event.pricing.currency, isNotEmpty);
        expect(event.displayPrice, isNotEmpty);
      }
    });
    
    test('should have events with family suitability data', () {
      final events = SampleEvents.sampleEvents;
      
      for (final event in events) {
        expect(event.familySuitability, isNotNull);
        expect(event.familySuitability.strollerFriendly, isA<bool>());
        expect(event.familySuitability.babyChanging, isA<bool>());
      }
    });
  });
} 