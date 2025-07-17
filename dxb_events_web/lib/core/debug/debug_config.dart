/// Debug configuration for the app
class DebugConfig {
  static bool isDebugMode = false;
  
  /// Log method calls for debugging
  static void logMethodCall(String methodName) {
    // Debug logging disabled for production
    if (isDebugMode) {
      // Only log in development builds
    }
  }
  
  /// Log general debug messages
  static void log(String message) {
    // Debug logging disabled for production
    if (isDebugMode) {
      // Only log in development builds
    }
  }
}