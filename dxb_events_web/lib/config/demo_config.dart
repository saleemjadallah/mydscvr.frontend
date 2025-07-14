/// Demo configuration for mydscvr.ai
/// This file controls whether the app shows ads or clean demo content
class DemoConfig {
  /// Set to true for demo mode (no ads), false for production mode (with ads)
  static const bool isDemo = false;
  
  /// Environment-based demo mode detection
  static bool get isDemoMode {
    // Check for build-time environment variable
    const String? demoEnv = String.fromEnvironment('DEMO_MODE');
    if (demoEnv != null) {
      return demoEnv.toLowerCase() == 'true';
    }
    
    // Check for URL-based demo mode (for web)
    if (identical(0, 0.0)) {
      // Web-specific check
      try {
        final uri = Uri.base;
        return uri.queryParameters['demo'] == 'true' || 
               uri.host.startsWith('demo.');
      } catch (e) {
        // Fallback if URI parsing fails
        return isDemo;
      }
    }
    
    // Default to compile-time constant
    return isDemo;
  }
  
  /// Get the appropriate ad widget based on demo mode
  static Widget getAdWidget({
    String? adSlot,
    double height = 250,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    String? title,
    String? subtitle,
    IconData? icon,
  }) {
    if (isDemoMode) {
      if (title != null || subtitle != null || icon != null) {
        return MarketingContentPlaceholder(
          height: height,
          margin: margin,
          title: title,
          subtitle: subtitle,
          icon: icon,
        );
      } else {
        return const CleanAdPlaceholder();
      }
    } else {
      // Production mode - show real ads
      if (adSlot != null) {
        return AdPlaceholder(
          adSlot: adSlot,
          height: height,
          margin: margin,
        );
      } else {
        return SimpleAdPlaceholder(
          height: height,
          margin: margin,
        );
      }
    }
  }
  
  /// Demo mode indicators
  static String get modeIndicator => isDemoMode ? 'DEMO' : 'LIVE';
  static String get version => isDemoMode ? 'Demo Version' : 'Production';
  
  /// Password protection settings for demo deployment
  /// These are injected from GitHub Secrets during build
  static const String demoUsername = String.fromEnvironment('DEMO_USERNAME', defaultValue: 'demo');
  static const String demoPassword = String.fromEnvironment('DEMO_PASSWORD', defaultValue: '');
  
  /// Demo site configuration
  static const String demoDomain = 'demo.mydscvr.ai';
  static const String productionDomain = 'mydscvr.ai';
}

// Import statements for the widgets
import 'package:flutter/material.dart';
import '../widgets/common/ad_placeholder.dart';