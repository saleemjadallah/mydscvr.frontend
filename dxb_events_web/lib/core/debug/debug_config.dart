import 'package:flutter/foundation.dart';

/// Debug configuration and utilities
class DebugConfig {
  /// Enable enhanced error reporting in debug mode
  static void initialize() {
    if (kDebugMode) {
      // Enable enhanced error reporting
      FlutterError.onError = (FlutterErrorDetails details) {
        // Print detailed error information
        print('🚨 =================FLUTTER ERROR================');
        print('🚨 Exception: ${details.exception}');
        print('🚨 Library: ${details.library}');
        print('🚨 Context: ${details.context}');
        print('🚨 Stack trace: ${details.stack}');
        print('🚨 =============================================');
        
        // Call default error handler
        FlutterError.presentError(details);
      };

      // Set up zone error handling for async errors
      runZonedGuarded(
        () {},
        (error, stack) {
          print('🚨 =================ZONE ERROR=================');
          print('🚨 Error: $error');
          print('🚨 Stack trace: $stack');
          print('🚨 =============================================');
        },
      );
    }
  }

  /// Log provider state changes for debugging
  static void logProviderChange(String providerName, dynamic state) {
    if (kDebugMode) {
      print('🔄 Provider [$providerName]: $state');
    }
  }

  /// Log API calls for debugging
  static void logApiCall(String method, String url, dynamic data) {
    if (kDebugMode) {
      print('🌐 API [$method] $url: $data');
    }
  }

  /// Log recursive call detection
  static final Map<String, int> _callCounts = {};
  static void logMethodCall(String methodName) {
    if (kDebugMode) {
      _callCounts[methodName] = (_callCounts[methodName] ?? 0) + 1;
      if (_callCounts[methodName]! > 10) {
        print('🚨 POTENTIAL INFINITE LOOP DETECTED: $methodName called ${_callCounts[methodName]} times');
      }
    }
  }

  /// Reset call counts
  static void resetCallCounts() {
    _callCounts.clear();
  }
}

/// Mixin for widgets to detect rebuild loops
mixin DebugRebuildMixin<T extends StatefulWidget> on State<T> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      _buildCount++;
      if (_buildCount > 100) {
        print('🚨 EXCESSIVE REBUILDS DETECTED in ${widget.runtimeType}: $_buildCount rebuilds');
      }
    }
    return buildInternal(context);
  }

  Widget buildInternal(BuildContext context);
}

/// Wrapper to catch and log errors
class SafeWidget extends StatelessWidget {
  final Widget child;
  final String widgetName;

  const SafeWidget({
    Key? key,
    required this.child,
    required this.widgetName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('🚨 Error in $widgetName: $error');
        print('🚨 Stack trace: $stackTrace');
      }
      
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red.withOpacity(0.1),
        child: Text(
          'Error in $widgetName',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

// Import necessary packages
import 'dart:async';
import 'package:flutter/material.dart';