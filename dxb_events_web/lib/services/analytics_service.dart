import 'dart:html' as html;
import 'dart:js' as js;

class AnalyticsService {
  static bool _luckyOrangeInitialized = false;
  static bool _isDebugMode = true; // Set to false in production

  /// Initialize all analytics services after Flutter app loads
  static Future<void> initialize() async {
    await _initializeLuckyOrange();
  }

  /// Initialize Lucky Orange analytics with proper timing
  static Future<void> _initializeLuckyOrange() async {
    if (_luckyOrangeInitialized) return;

    try {
      // Wait a bit more for Flutter to fully settle
      await Future.delayed(const Duration(seconds: 1));

      // Create and inject Lucky Orange script
      final script = html.ScriptElement()
        ..async = true
        ..defer = true
        ..src = 'https://tools.luckyorange.com/core/lo.js?site-id=fe966133';

      // Add load and error handlers
      script.onLoad.listen((_) {
        _luckyOrangeInitialized = true;
        if (_isDebugMode) {
          print('🍊 Lucky Orange successfully loaded via Flutter service');
        }
      });

      script.onError.listen((_) {
        if (_isDebugMode) {
          print('❌ Lucky Orange failed to load via Flutter service');
        }
      });

      // Inject into head
      html.document.head?.append(script);

      if (_isDebugMode) {
        print('🍊 Lucky Orange script injected via Flutter service');
      }
    } catch (e) {
      if (_isDebugMode) {
        print('❌ Error initializing Lucky Orange: $e');
      }
    }
  }

  /// Track custom events in Lucky Orange
  static void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    try {
      if (js.context.hasProperty('LO')) {
        // Use Lucky Orange's event tracking API
        js.context.callMethod('eval', [
          '''
          if (window.LO && window.LO.events) {
            window.LO.events.track('$eventName', ${properties != null ? _mapToJson(properties) : '{}'});
          }
          '''
        ]);
        
        if (_isDebugMode) {
          print('🍊 Lucky Orange event tracked: $eventName');
        }
      }
    } catch (e) {
      if (_isDebugMode) {
        print('❌ Error tracking Lucky Orange event: $e');
      }
    }
  }

  /// Identify user in Lucky Orange
  static void identifyUser(String userId, [Map<String, dynamic>? userData]) {
    try {
      if (js.context.hasProperty('LO')) {
        js.context.callMethod('eval', [
          '''
          if (window.LO && window.LO.visitor) {
            window.LO.visitor.identify('$userId', ${userData != null ? _mapToJson(userData) : '{}'});
          }
          '''
        ]);
        
        if (_isDebugMode) {
          print('🍊 Lucky Orange user identified: $userId');
        }
      }
    } catch (e) {
      if (_isDebugMode) {
        print('❌ Error identifying Lucky Orange user: $e');
      }
    }
  }

  /// Convert Dart Map to JSON string for JavaScript
  static String _mapToJson(Map<String, dynamic> map) {
    return map.entries
        .map((e) => '"${e.key}": "${e.value}"')
        .join(', ');
  }

  /// Check if Lucky Orange is loaded and ready
  static bool get isLuckyOrangeReady {
    try {
      return js.context.hasProperty('LO') && _luckyOrangeInitialized;
    } catch (e) {
      return false;
    }
  }
} 