import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Typography system for DXB Events platform
/// Features fun, readable fonts with personality for family-friendly experiences
class AppTypography {
  /// Main text theme with playful and accessible fonts
  static TextTheme get textTheme => TextTheme(
    // Headlines - Playful and bold for capturing attention
    displayLarge: GoogleFonts.comfortaa(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
    ),
    displayMedium: GoogleFonts.comfortaa(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
    ),
    displaySmall: GoogleFonts.comfortaa(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      height: 1.2,
    ),

    // Headlines for cards and sections
    headlineLarge: GoogleFonts.comfortaa(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.comfortaa(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.comfortaa(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),

    // Body text - Clear and readable
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.4,
    ),

    // Labels for buttons and UI elements
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      height: 1.4,
      letterSpacing: 0.5,
    ),

    // Title text for app bars and headers
    titleLarge: GoogleFonts.comfortaa(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.comfortaa(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    titleSmall: GoogleFonts.comfortaa(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
  );

  // Static getters for direct access to text styles
  static TextStyle get displayLarge => textTheme.displayLarge!;
  static TextStyle get displayMedium => textTheme.displayMedium!;
  static TextStyle get displaySmall => textTheme.displaySmall!;
  static TextStyle get headlineLarge => textTheme.headlineLarge!;
  static TextStyle get headlineMedium => textTheme.headlineMedium!;
  static TextStyle get headlineSmall => textTheme.headlineSmall!;
  static TextStyle get bodyLarge => textTheme.bodyLarge!;
  static TextStyle get bodyMedium => textTheme.bodyMedium!;
  static TextStyle get bodySmall => textTheme.bodySmall!;
  static TextStyle get labelLarge => textTheme.labelLarge!;
  static TextStyle get labelMedium => textTheme.labelMedium!;
  static TextStyle get labelSmall => textTheme.labelSmall!;
  static TextStyle get titleLarge => textTheme.titleLarge!;
  static TextStyle get titleMedium => textTheme.titleMedium!;
  static TextStyle get titleSmall => textTheme.titleSmall!;
}

/// Custom text styles for specific components and use cases
class CustomStyles {
  /// Hero section title with dramatic effect
  static TextStyle get heroTitle => GoogleFonts.comfortaa(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
    shadows: [
      const Shadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        color: Color.fromRGBO(0, 0, 0, 0.25),
      ),
    ],
  );

  /// Button text style
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Navigation label style
  static TextStyle get navigationLabel => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Input field label style
  static TextStyle get inputLabel => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Error message style
  static TextStyle get errorText => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    height: 1.4,
  );

  /// Card subtitle style
  static TextStyle get cardSubtitle => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Floating action button text
  static TextStyle get fabText => GoogleFonts.comfortaa(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  /// Overline text for categories and tags
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.2,
    letterSpacing: 1.5,
  );

  // Private constructor to prevent instantiation
  CustomStyles._();
}

/// Extension for easy text style modifications
extension TextStyleExtension on TextStyle {
  /// Apply a color while keeping other properties
  TextStyle colored(Color color) => copyWith(color: color);

  /// Apply a different weight while keeping other properties
  TextStyle weighted(FontWeight weight) => copyWith(fontWeight: weight);

  /// Apply a different size while keeping other properties
  TextStyle sized(double size) => copyWith(fontSize: size);

  /// Apply opacity while keeping other properties
  TextStyle withOpacity(double opacity) => copyWith(
        color: color?.withOpacity(opacity) ?? Colors.black.withOpacity(opacity),
      );
} 