import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'features/home/home_screen_minimal.dart';

// Ultra-minimal router for debugging type casting
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MinimalHomeScreen(),
    ),
  ],
);

/// Ultra-minimal main for debugging
void main() {
  usePathUrlStrategy();
  
  runApp(
    ProviderScope(
      child: MaterialApp.router(
        title: 'Debug Mode - Type Casting Fix',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
      ),
    ),
  );
}