import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import our app components
import 'package:dxb_events_web/widgets/events/event_card.dart';
import 'package:dxb_events_web/data/sample_events.dart';

void main() {
  group('EventCard Widget Tests', () {
    testWidgets('should display event title from sample data', (WidgetTester tester) async {
      // Use actual sample event from our app
      final sampleEvent = SampleEvents.sampleEvents.first;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: SizedBox(
              width: 400,
              height: 600,
              child: EventCard(
                event: sampleEvent,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Wait for the widget to render
      await tester.pump();
      
      // Verify that the event title is present somewhere in the widget
      expect(find.text(sampleEvent.title), findsOneWidget);
    });
    
    testWidgets('should display venue area from sample data', (WidgetTester tester) async {
      final sampleEvent = SampleEvents.sampleEvents.first;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: SizedBox(
              width: 400,
              height: 600,
              child: EventCard(
                event: sampleEvent,
              ),
            ),
          ),
        ),
      );
      
      await tester.pump();
      
      // Should find the venue area
      expect(find.text(sampleEvent.venue.area), findsOneWidget);
    });
    
    testWidgets('should create EventCard widget without errors', (WidgetTester tester) async {
      final sampleEvent = SampleEvents.sampleEvents.first;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: SizedBox(
              width: 400,
              height: 600,
              child: EventCard(
                event: sampleEvent,
              ),
            ),
          ),
        ),
      );
      
      await tester.pump();
      
      // The main test is that it doesn't crash
      expect(tester.takeException(), isNull);
    });
  });
} 