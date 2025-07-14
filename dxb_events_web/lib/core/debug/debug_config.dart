/// Debug configuration for the app
class DebugConfig {
  static bool isDebugMode = false;
  
  /// Log method calls for debugging
  static void logMethodCall(String methodName) {
    if (isDebugMode) {
      print('🔍 DEBUG: $methodName called');
    }
  }
  
  /// Log general debug messages
  static void log(String message) {
    if (isDebugMode) {
      print('🔍 DEBUG: $message');
    }
  }
}