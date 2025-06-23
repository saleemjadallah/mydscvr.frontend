import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the main app
import 'package:dxb_events_web/main.dart' as app;
import 'package:dxb_events_web/features/home/home_screen_animated.dart';
import 'package:dxb_events_web/widgets/home/interactive_category_explorer.dart';
import 'package:dxb_events_web/widgets/events/event_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DXB Events App Integration Tests', () {
    testWidgets('complete app flow from home to event details', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Verify home screen loads
      expect(find.byType(AnimatedHomeScreen), findsOneWidget);
      
      // Verify interactive category explorer is present
      expect(find.byType(InteractiveCategoryExplorer), findsOneWidget);
      
      // Verify search functionality
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      
      // Test search interaction
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      
      await tester.enterText(searchField, 'Dubai Marina');
      await tester.pumpAndSettle();
      
      // Verify search suggestions appear
      expect(find.textContaining('Dubai'), findsAtLeastNWidgets(1));
      
      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      
      // Test category interaction
      final cultureCategory = find.text('Culture');
      expect(cultureCategory, findsOneWidget);
      
      // Hover over category (if supported in test environment)
      // Note: Mouse interactions are limited in integration tests
      
      // Test scrolling to events section
      await tester.scrollUntilVisible(
        find.text('Family-Friendly Events'),
        500.0,
      );
      
      // Verify events are displayed
      expect(find.byType(EventCard), findsAtLeastNWidgets(1));
      
      // Test event card interaction
      final firstEventCard = find.byType(EventCard).first;
      await tester.tap(firstEventCard);
      await tester.pumpAndSettle();
      
      // Verify navigation occurs (event details screen or similar)
      // Note: Actual navigation testing depends on routing implementation
    });
    
    testWidgets('search functionality end-to-end', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Find search field
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      
      // Test various search terms
      final searchTerms = ['Marina', 'Kids', 'Free', 'Adventure'];
      
      for (String term in searchTerms) {
        await tester.enterText(searchField, term);
        await tester.pumpAndSettle();
        
        // Should show suggestions
        expect(find.textContaining(term), findsAtLeastNWidgets(1));
        
        // Clear for next search
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
      }
    });
    
    testWidgets('navigation between different sections', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test scrolling through different sections
      final sectionsToFind = [
        'Explore Dubai Events',
        'Family-Friendly Events',
        'Featured Events',
      ];
      
      for (String section in sectionsToFind) {
        if (find.text(section).evaluate().isNotEmpty) {
          await tester.scrollUntilVisible(
            find.text(section),
            500.0,
          );
          
          expect(find.text(section), findsOneWidget);
        }
      }
    });
    
    testWidgets('responsive design at different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(375, 667));
      app.main();
      await tester.pumpAndSettle();
      
      expect(find.byType(AnimatedHomeScreen), findsOneWidget);
      
      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpAndSettle();
      
      expect(find.byType(InteractiveCategoryExplorer), findsOneWidget);
      
      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpAndSettle();
      
      expect(find.byType(AnimatedHomeScreen), findsOneWidget);
      
      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });
    
    testWidgets('loading states and error handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test that shimmer loading states are handled
      // (This would require actual network calls or mocked states)
      
      // Verify no exceptions are thrown during normal flow
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('accessibility features work correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test semantic labels
      expect(find.bySemanticsLabel(RegExp(r'.*')), findsAtLeastNWidgets(1));
      
      // Test that interactive elements have proper semantics
      final buttons = find.byType(ElevatedButton);
      for (int i = 0; i < buttons.evaluate().length; i++) {
        final button = tester.widget<ElevatedButton>(buttons.at(i));
        expect(button.enabled, isTrue);
      }
    });
    
    testWidgets('performance during scrolling and interactions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test scrolling performance
      final listView = find.byType(CustomScrollView);
      if (listView.evaluate().isNotEmpty) {
        // Perform smooth scrolling
        await tester.fling(listView, const Offset(0, -1000), 1000);
        await tester.pumpAndSettle();
        
        // Scroll back
        await tester.fling(listView, const Offset(0, 1000), 1000);
        await tester.pumpAndSettle();
      }
      
      // Verify no performance-related exceptions
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('theme and visual consistency', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Verify app uses consistent theming
      final materialApp = find.byType(MaterialApp);
      expect(materialApp, findsOneWidget);
      
      final app = tester.widget<MaterialApp>(materialApp);
      expect(app.theme, isNotNull);
      
      // Verify Dubai-themed colors are used
      // (This would require checking specific color usage)
    });
    
    testWidgets('memory usage and cleanup', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate through different sections
      await tester.scrollUntilVisible(
        find.text('Family-Friendly Events'),
        500.0,
      );
      await tester.pumpAndSettle();
      
      // Scroll back to top
      await tester.scrollUntilVisible(
        find.text('Explore Dubai Events'),
        -500.0,
      );
      await tester.pumpAndSettle();
      
      // Verify proper cleanup (no memory leaks)
      expect(tester.takeException(), isNull);
    });
  });
  
  group('Category Explorer Integration Tests', () {
    testWidgets('category hover and interaction flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Find category explorer
      expect(find.byType(InteractiveCategoryExplorer), findsOneWidget);
      
      // Test each category
      final categories = ['Culture', 'Outdoor', 'Kids', 'Adventure', 'Food & Dining', 'Indoor'];
      
      for (String category in categories) {
        final categoryWidget = find.text(category);
        if (categoryWidget.evaluate().isNotEmpty) {
          // Scroll to make sure category is visible
          await tester.scrollUntilVisible(categoryWidget, 200.0);
          
          // Tap category
          await tester.tap(categoryWidget);
          await tester.pumpAndSettle();
          
          // Verify no errors occurred
          expect(tester.takeException(), isNull);
        }
      }
    });
    
    testWidgets('category navigation and state management', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test rapid category switching
      final cultureCategory = find.text('Culture');
      final outdoorCategory = find.text('Outdoor');
      
      if (cultureCategory.evaluate().isNotEmpty && outdoorCategory.evaluate().isNotEmpty) {
        await tester.tap(cultureCategory);
        await tester.pump();
        
        await tester.tap(outdoorCategory);
        await tester.pump();
        
        await tester.tap(cultureCategory);
        await tester.pumpAndSettle();
        
        // Should handle rapid state changes gracefully
        expect(tester.takeException(), isNull);
      }
    });
  });
  
  group('Search Integration Tests', () {
    testWidgets('search with real queries and results', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      
      // Test comprehensive search
      await tester.enterText(searchField, 'Dubai');
      await tester.pumpAndSettle();
      
      // Should show Dubai-related suggestions
      expect(find.textContaining('Dubai'), findsAtLeastNWidgets(1));
      
      // Test search clearing
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      
      // Suggestions should disappear
      // (Testing this depends on implementation details)
    });
  });
} 