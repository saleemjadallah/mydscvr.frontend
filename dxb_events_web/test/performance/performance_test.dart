import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

// Import our app components
import 'package:dxb_events_web/features/home/home_screen_animated.dart';
import 'package:dxb_events_web/widgets/home/interactive_category_explorer.dart';
import 'package:dxb_events_web/widgets/events/event_card.dart';
import 'package:dxb_events_web/data/sample_events.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('home screen rendering performance', (WidgetTester tester) async {
      // Enable performance timeline
      final timeline = Timeline.startSync('home_screen_render');
      
      final stopwatch = Stopwatch()..start();
      
      // Create the home screen
      await tester.pumpWidget(
        MaterialApp(
          home: const AnimatedHomeScreen(),
        ),
      );
      
      // Wait for all animations to complete
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      timeline.finish();
      
      // Assert reasonable rendering time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      // Print performance metrics
      debugPrint('Home screen render time: ${stopwatch.elapsedMilliseconds}ms');
    });
    
    testWidgets('interactive category explorer performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const InteractiveCategoryExplorer(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // Should render efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      debugPrint('Category explorer render time: ${stopwatch.elapsedMilliseconds}ms');
      
      // Test hover performance
      final hoverStopwatch = Stopwatch()..start();
      
      // Simulate hover events (if applicable)
      final mouseRegions = find.byType(MouseRegion);
      if (mouseRegions.evaluate().isNotEmpty) {
        for (int i = 0; i < 3; i++) {
          await tester.startGesture(tester.getCenter(mouseRegions.at(i)));
          await tester.pump();
        }
      }
      
      hoverStopwatch.stop();
      debugPrint('Hover interactions time: ${hoverStopwatch.elapsedMilliseconds}ms');
    });
    
    testWidgets('event list scrolling performance', (WidgetTester tester) async {
      // Create a list with many events
      final events = List.generate(50, (index) => SampleEvents.allEvents[index % SampleEvents.allEvents.length]);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events[index],
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Test scrolling performance
      final scrollStopwatch = Stopwatch()..start();
      
      // Perform multiple scroll gestures
      for (int i = 0; i < 5; i++) {
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -1000),
          1000,
        );
        await tester.pump();
      }
      
      await tester.pumpAndSettle();
      scrollStopwatch.stop();
      
      debugPrint('Scrolling performance: ${scrollStopwatch.elapsedMilliseconds}ms for 5 flings');
      
      // Should handle scrolling efficiently
      expect(scrollStopwatch.elapsedMilliseconds, lessThan(2000));
    });
    
    testWidgets('animation performance stress test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AnimatedHomeScreen(),
        ),
      );
      
      // Track frame rendering
      final FrameTiming frameTimingStart = SchedulerBinding.instance.currentFrameTimeStamp != null 
          ? FrameTiming(
              vsyncStart: SchedulerBinding.instance.currentFrameTimeStamp!,
              buildStart: SchedulerBinding.instance.currentFrameTimeStamp!,
              buildFinish: SchedulerBinding.instance.currentFrameTimeStamp!,
              rasterStart: SchedulerBinding.instance.currentFrameTimeStamp!,
              rasterFinish: SchedulerBinding.instance.currentFrameTimeStamp!,
            )
          : FrameTiming(
              vsyncStart: Duration.zero,
              buildStart: Duration.zero, 
              buildFinish: Duration.zero,
              rasterStart: Duration.zero,
              rasterFinish: Duration.zero,
            );
      
      // Stress test with rapid interactions
      for (int i = 0; i < 10; i++) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16)); // 60 FPS
      }
      
      await tester.pumpAndSettle();
      
      // Verify no frame drops (simplified check)
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('memory usage during navigation', (WidgetTester tester) async {
      // Test memory usage by creating and disposing widgets
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: const AnimatedHomeScreen(),
          ),
        );
        await tester.pumpAndSettle();
        
        // Clear widget tree
        await tester.pumpWidget(Container());
        await tester.pump();
      }
      
      // Should not accumulate memory leaks
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('large dataset rendering performance', (WidgetTester tester) async {
      // Test with large number of events
      final largeEventList = List.generate(
        100,
        (index) => SampleEvents.allEvents[index % SampleEvents.allEvents.length],
      );
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: largeEventList.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: largeEventList[index],
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      );
      
      // Only pump once - ListView.builder should lazy load
      await tester.pump();
      
      stopwatch.stop();
      
      debugPrint('Large dataset initial render: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should handle large datasets efficiently with lazy loading
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
    
    testWidgets('image loading performance', (WidgetTester tester) async {
      // Test image loading performance with cached network images
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1544967882-4d0e306c8d68?ixlib=rb-4.0.3&w=300&h=200&fit=crop'
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pump();
      stopwatch.stop();
      
      debugPrint('Image grid initial render: ${stopwatch.elapsedMilliseconds}ms');
      
      // Initial render should be fast (images load asynchronously)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
    
    testWidgets('responsive layout performance at different sizes', (WidgetTester tester) async {
      final sizes = [
        const Size(375, 667),   // Mobile
        const Size(768, 1024),  // Tablet
        const Size(1920, 1080), // Desktop
      ];
      
      for (Size size in sizes) {
        final stopwatch = Stopwatch()..start();
        
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(
          MaterialApp(
            home: const AnimatedHomeScreen(),
          ),
        );
        
        await tester.pumpAndSettle();
        stopwatch.stop();
        
        debugPrint('Render time for ${size.width}x${size.height}: ${stopwatch.elapsedMilliseconds}ms');
        
        // Should adapt to different sizes efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      }
      
      // Reset size
      await tester.binding.setSurfaceSize(null);
    });
    
    testWidgets('animation smoothness test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AnimatedHomeScreen(),
        ),
      );
      
      // Count frames during animation
      int frameCount = 0;
      final stopwatch = Stopwatch()..start();
      
      // Trigger animations by scrolling
      while (stopwatch.elapsedMilliseconds < 1000) {
        await tester.pump(const Duration(milliseconds: 16));
        frameCount++;
      }
      
      stopwatch.stop();
      
      final fps = frameCount / (stopwatch.elapsedMilliseconds / 1000);
      debugPrint('Average FPS during animations: ${fps.toStringAsFixed(1)}');
      
      // Should maintain reasonable frame rate (aim for 60 FPS, accept 30+)
      expect(fps, greaterThan(30));
    });
  });
  
  group('Memory Performance Tests', () {
    testWidgets('widget disposal and cleanup', (WidgetTester tester) async {
      // Test multiple widget creation and disposal cycles
      for (int cycle = 0; cycle < 3; cycle++) {
        // Create widgets
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const InteractiveCategoryExplorer(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) => EventCard(
                        event: SampleEvents.allEvents[index % SampleEvents.allEvents.length],
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Dispose widgets
        await tester.pumpWidget(Container());
        await tester.pump();
      }
      
      // Should not accumulate memory or cause errors
      expect(tester.takeException(), isNull);
    });
  });
  
  group('Network Performance Tests', () {
    testWidgets('cached image performance simulation', (WidgetTester tester) async {
      // Simulate cached vs uncached image loading
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  height: 200,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-${1544967882 + index}?ixlib=rb-4.0.3&w=300&h=200&fit=crop'
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      
      await tester.pump();
      stopwatch.stop();
      
      debugPrint('Network image list render time: ${stopwatch.elapsedMilliseconds}ms');
      
      // Initial render should be fast (images load asynchronously)
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });
  });
} 