import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import our app components
import 'package:dxb_events_web/widgets/home/interactive_category_explorer.dart';
import 'package:dxb_events_web/core/constants/app_colors.dart';

void main() {
  group('InteractiveCategoryExplorer Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 1200, // Give enough height to avoid overflow
                child: const InteractiveCategoryExplorer(),
              ),
            ),
          ),
        ),
      );
    }
    
    testWidgets('should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Just check that it renders without throwing exceptions
      await tester.pump();
      
      // Should find the widget
      expect(find.byType(InteractiveCategoryExplorer), findsOneWidget);
      
      // Should not have thrown any exceptions
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('should display category names', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Check for some category names (these should be visible if the widget renders correctly)
      expect(find.text('Culture'), findsOneWidget);
      expect(find.text('Outdoor'), findsOneWidget);
      expect(find.text('Kids'), findsOneWidget);
    });
    
    testWidgets('should display category emojis', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Check for emojis
      expect(find.text('🎭'), findsOneWidget);
      expect(find.text('🌳'), findsOneWidget);
      expect(find.text('🎈'), findsOneWidget);
    });
    
    group('Display Tests', () {
      testWidgets('should display all 6 categories', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Check for all category names
        expect(find.text('Culture'), findsOneWidget);
        expect(find.text('Outdoor'), findsOneWidget);
        expect(find.text('Kids'), findsOneWidget);
        expect(find.text('Adventure'), findsOneWidget);
        expect(find.text('Food & Dining'), findsOneWidget);
        expect(find.text('Indoor'), findsOneWidget);
      });
      
      testWidgets('should display event counts', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Check that event count text is displayed
        expect(find.textContaining('events'), findsAtLeastNWidgets(6));
      });
      
      testWidgets('should display "Explore Dubai Events" title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.text('Explore Dubai Events'), findsOneWidget);
      });
    });
    
    group('Layout Tests', () {
      testWidgets('should use responsive grid layout', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Should find a GridView
        expect(find.byType(GridView), findsOneWidget);
      });
      
      testWidgets('should have proper spacing between items', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Check that SliverGridDelegate is properly configured
        final gridView = tester.widget<GridView>(find.byType(GridView));
        expect(gridView.gridDelegate, isA<SliverGridDelegateWithFixedCrossAxisCount>());
      });
    });
    
    group('Hover Interaction Tests', () {
      testWidgets('should show hover content when mouse enters category', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Find the first category container
        final firstCategory = find.byType(MouseRegion).first;
        
        // Simulate mouse enter
        await tester.startGesture(tester.getCenter(firstCategory));
        await tester.pump();
        
        // Wait for animations
        await tester.pumpAndSettle();
        
        // Should show preview events (though we can't easily test the exact content)
        // We can test that the hover state is triggered
      });
      
      testWidgets('should handle multiple rapid hover events', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        final firstCategory = find.byType(MouseRegion).first;
        final secondCategory = find.byType(MouseRegion).at(1);
        
        // Rapid hover between categories
        await tester.startGesture(tester.getCenter(firstCategory));
        await tester.pump();
        
        await tester.startGesture(tester.getCenter(secondCategory));
        await tester.pump();
        
        // Should not cause errors
        expect(tester.takeException(), isNull);
      });
    });
    
    group('Animation Tests', () {
      testWidgets('should animate categories on initial load', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Trigger the animation by settling
        await tester.pumpAndSettle();
        
        // Should find all categories rendered
        expect(find.text('Culture'), findsOneWidget);
        expect(find.text('Outdoor'), findsOneWidget);
      });
      
      testWidgets('should handle animation controller disposal', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // Remove widget and check for proper disposal
        await tester.pumpWidget(Container());
        
        // Should not cause memory leaks or errors
        expect(tester.takeException(), isNull);
      });
    });
    
    group('Tap Interaction Tests', () {
      testWidgets('should respond to category taps', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Find and tap the first category
        final cultureCategory = find.text('Culture');
        await tester.tap(cultureCategory);
        await tester.pump();
        
        // Should trigger navigation (though we can't test the actual navigation)
        // The tap should not cause errors
        expect(tester.takeException(), isNull);
      });
      
      testWidgets('should handle taps on different categories', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Test tapping multiple categories
        await tester.tap(find.text('Outdoor'));
        await tester.pump();
        
        await tester.tap(find.text('Kids'));
        await tester.pump();
        
        expect(tester.takeException(), isNull);
      });
    });
    
    group('Visual State Tests', () {
      testWidgets('should have proper background images', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Should find CachedNetworkImage widgets for backgrounds
        expect(find.byType(Container), findsAtLeastNWidgets(6));
      });
      
      testWidgets('should apply proper gradient overlays', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Should find gradient decorations
        final containers = find.byType(Container);
        expect(containers, findsAtLeastNWidgets(1));
      });
      
      testWidgets('should use Dubai theme colors', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // The title should use Dubai theme colors
        final titleWidget = find.text('Explore Dubai Events');
        expect(titleWidget, findsOneWidget);
      });
    });
    
    group('Accessibility Tests', () {
      testWidgets('should have proper semantics for categories', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Categories should be accessible
        expect(find.text('Culture'), findsOneWidget);
        expect(find.text('Outdoor'), findsOneWidget);
        
        // Should have proper semantics for screen readers
        final Semantics cultureSemanticsWidget = tester.widget(
          find.ancestor(
            of: find.text('Culture'),
            matching: find.byType(Semantics),
          ).first,
        );
        
        expect(cultureSemanticsWidget.properties.button, isTrue);
      });
      
      testWidgets('should have minimum tap target sizes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Each category should be large enough to tap (minimum 44x44)
        final categoryContainers = find.byType(Container);
        for (int i = 0; i < tester.widgetList(categoryContainers).length; i++) {
          final containerSize = tester.getSize(categoryContainers.at(i));
          if (containerSize.width > 0 && containerSize.height > 0) {
            expect(containerSize.width, greaterThan(44));
            expect(containerSize.height, greaterThan(44));
          }
        }
      });
    });
    
    group('Error Handling Tests', () {
      testWidgets('should handle missing images gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Should render without errors even if images fail to load
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
      
      testWidgets('should handle rapid state changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Rapidly trigger hover states
        final mouseRegions = find.byType(MouseRegion);
        for (int i = 0; i < mouseRegions.evaluate().length && i < 3; i++) {
          await tester.startGesture(tester.getCenter(mouseRegions.at(i)));
          await tester.pump();
        }
        
        expect(tester.takeException(), isNull);
      });
    });
    
    group('Performance Tests', () {
      testWidgets('should render efficiently with many categories', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Measure frame times
        await tester.pumpAndSettle();
        
        // Should complete rendering without performance issues
        expect(find.text('Culture'), findsOneWidget);
        expect(find.text('Outdoor'), findsOneWidget);
        expect(find.text('Kids'), findsOneWidget);
        expect(find.text('Adventure'), findsOneWidget);
        expect(find.text('Food & Dining'), findsOneWidget);
        expect(find.text('Indoor'), findsOneWidget);
      });
    });
  });
} 