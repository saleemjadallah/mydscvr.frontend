// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dxb_events_web/main.dart';

void main() {
  testWidgets('DXB Events app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DXBEventsApp(),
      ),
    );

    // Wait for initial frame to render
    await tester.pump();
    
    // Give it a few more frames for initial setup
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Verify that our app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Should find the main app wrapper
    expect(find.byType(MainAppWrapper), findsOneWidget);
  });
}
