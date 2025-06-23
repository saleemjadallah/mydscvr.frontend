import 'package:flutter/material.dart';

/// Dubai-inspired color palette for the DXB Events platform
/// Features vibrant, family-friendly colors with beautiful gradients
class AppColors {
  // Primary Dubai Colors - Inspired by the city's golden skyline and ocean views
  static const Color dubaiGold = Color(0xFFD4AF37);
  static const Color dubaiTeal = Color(0xFF17A2B8);
  static const Color dubaiCoral = Color(0xFFFF6B6B);
  static const Color dubaiPurple = Color(0xFF6C5CE7);

  // Background and Surface Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);

  // System Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF4299E1);

  // Stunning Gradients for hero sections and backgrounds
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF7B7B), Color(0xFFFFA726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF134E5E), Color(0xFF71B280)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient royalGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenGradient = LinearGradient(
    colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF9A8B), Color(0xFFA890FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF2EBAC4), Color(0xFF0575E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFAB77FF), Color(0xFF6E45E2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Elevation and Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.1);
  static Color shadowMedium = Colors.black.withOpacity(0.15);
  static Color shadowHeavy = Colors.black.withOpacity(0.25);

  // Glass morphism colors
  static Color glassLight = Colors.white.withOpacity(0.1);
  static Color glassMedium = Colors.white.withOpacity(0.2);
  static Color glassDark = Colors.black.withOpacity(0.1);

  // Gradient overlays for images
  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x88000000),
    ],
  );

  static const LinearGradient imageOverlayLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x44000000),
    ],
  );

  // Interactive states
  static Color hoverLight = Colors.black.withOpacity(0.04);
  static Color hoverMedium = Colors.black.withOpacity(0.08);
  static Color pressedLight = Colors.black.withOpacity(0.12);

  // Border colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E0);
  static const Color borderDark = Color(0xFFA0AEC0);

  // Category-specific colors
  static const Color kidsCategory = Color(0xFFFF6B6B);
  static const Color musicCategory = Color(0xFF6C5CE7);
  static const Color artsCategory = Color(0xFFD4AF37);
  static const Color sportsCategory = Color(0xFF17A2B8);
  static const Color foodCategory = Color(0xFFFF9F43);
  static const Color cultureCategory = Color(0xFF5F27CD);
  static const Color outdoorCategory = Color(0xFF00D2D3);
  static const Color educationCategory = Color(0xFF54A0FF);

  // Event type colors
  static const Color freeEvent = Color(0xFF48BB78);
  static const Color paidEvent = Color(0xFFED8936);
  static const Color premiumEvent = Color(0xFF9F7AEA);

  // Age group colors
  static const Color infantsColor = Color(0xFFFD79A8);
  static const Color toddlersColor = Color(0xFFFFAB00);
  static const Color preschoolColor = Color(0xFF00B894);
  static const Color schoolAgeColor = Color(0xFF6C5CE7);
  static const Color teenagersColor = Color(0xFF5F27CD);
  static const Color allAgesColor = Color(0xFF00CEC9);

  // Status colors
  static const Color activeStatus = Color(0xFF10AC84);
  static const Color inactiveStatus = Color(0xFF8395A7);
  static const Color pendingStatus = Color(0xFFF79F1F);
  static const Color expiredStatus = Color(0xFFEE5A24);

  // Shadows and overlays
  static const Color shadow = Color(0x1A000000); // Black with 10% opacity
  static const Color overlay = Color(0x33000000);

  // Private constructor to prevent instantiation
  AppColors._();
}

/// Extension for creating scaled gradients with opacity
extension GradientExtension on LinearGradient {
  LinearGradient scale(double opacity) {
    return LinearGradient(
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
      begin: begin,
      end: end,
    );
  }
} 