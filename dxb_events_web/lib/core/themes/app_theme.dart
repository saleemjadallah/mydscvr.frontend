import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'app_typography.dart';

/// Main theme configuration for DXB Events platform
/// Creates a vibrant, family-friendly design system with Dubai inspiration
class AppTheme {
  /// Light theme - Primary theme for the app
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    
    // Color scheme based on Dubai-inspired colors
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dubaiTeal,
      brightness: Brightness.light,
      primary: AppColors.dubaiTeal,
      secondary: AppColors.dubaiCoral,
      tertiary: AppColors.dubaiGold,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),

    // Background color
    scaffoldBackgroundColor: AppColors.background,

    // App bar theme with Dubai style
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: CustomStyles.heroTitle.copyWith(
        fontSize: 20,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    ),

    // Beautiful elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: CustomStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: AppColors.shadowMedium,
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: CustomStyles.button.copyWith(
          color: AppColors.dubaiTeal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: const BorderSide(
          color: AppColors.dubaiTeal,
          width: 2,
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: CustomStyles.button.copyWith(
          color: AppColors.dubaiTeal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    // Card theme with soft shadows
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Beautiful input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.dubaiTeal,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      labelStyle: CustomStyles.inputLabel,
      hintStyle: CustomStyles.inputLabel.copyWith(
        color: AppColors.textSecondary,
      ),
      errorStyle: CustomStyles.errorText,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 20,
      selectedItemColor: AppColors.dubaiTeal,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: CustomStyles.navigationLabel.copyWith(
        color: AppColors.dubaiTeal,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: CustomStyles.navigationLabel.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: const IconThemeData(
        size: 28,
        color: AppColors.dubaiTeal,
      ),
      unselectedIconTheme: IconThemeData(
        size: 24,
        color: AppColors.textSecondary,
      ),
    ),

    // Typography theme
    textTheme: AppTypography.textTheme,

    // Icon theme
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),

    // Chip theme for tags and filters
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      disabledColor: AppColors.borderLight,
      selectedColor: AppColors.dubaiTeal,
      secondarySelectedColor: AppColors.dubaiCoral,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      labelStyle: AppTypography.textTheme.labelMedium,
      secondaryLabelStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: Colors.white,
      ),
      brightness: Brightness.light,
      elevation: 2,
      pressElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Divider theme
    dividerTheme: DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 1,
    ),

    // FloatingActionButton theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.dubaiTeal,
      foregroundColor: Colors.white,
      elevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Drawer theme
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.surface,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    ),

    // Dialog theme
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: AppTypography.textTheme.headlineSmall,
      contentTextStyle: AppTypography.textTheme.bodyMedium,
    ),

    // BottomSheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      constraints: const BoxConstraints(
        maxWidth: 640,
      ),
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ),
  );

  /// Dark theme - Alternative theme for night mode
  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dubaiTeal,
      brightness: Brightness.dark,
      primary: AppColors.dubaiTeal,
      secondary: AppColors.dubaiCoral,
      tertiary: AppColors.dubaiGold,
      surface: const Color(0xFF2D2D2D),
      error: AppColors.error,
    ),
  );

  // Private constructor to prevent instantiation
  AppTheme._();
}

/// Custom theme extensions for special components
class AppThemeExtensions {
  /// Gradient decorations for hero sections
  static BoxDecoration get heroGradientDecoration => const BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      );

  /// Ocean gradient decoration
  static BoxDecoration get oceanGradientDecoration => const BoxDecoration(
        gradient: AppColors.oceanGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      );

  /// Card decoration with beautiful shadow
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      );

  /// Floating bubble decoration
  static BoxDecoration bubbleDecoration({
    Color? color,
    double borderRadius = 20,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      );

  // Private constructor
  AppThemeExtensions._();
} 