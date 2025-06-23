import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Comprehensive text styles for the DXB Events app
/// Following Material Design typography with Dubai-inspired modifications
class AppTextStyles {
  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  // Subtitle Styles
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Body Text Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Button Text Styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.3,
  );

  // Caption and Label Styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
  );

  // Specialized Styles for Events App

  // Event Title Styles
  static const TextStyle eventTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle eventTitleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // Event Description
  static const TextStyle eventDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Price Styles
  static const TextStyle priceText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.dubaiGold,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.dubaiGold,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.dubaiGold,
  );

  // Badge and Tag Styles
  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const TextStyle tag = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  // Status Styles
  static const TextStyle statusActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.activeStatus,
  );

  static const TextStyle statusInactive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.inactiveStatus,
  );

  static const TextStyle statusPending = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.pendingStatus,
  );

  // Date and Time Styles
  static const TextStyle dateTime = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle dateTimeLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Rating and Review Styles
  static const TextStyle rating = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.dubaiGold,
  );

  static const TextStyle reviewCount = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  // Category Styles
  static const TextStyle category = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static const TextStyle categoryLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  // Location Styles
  static const TextStyle location = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle locationLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Hero Text Styles
  static const TextStyle heroTitle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    height: 1.1,
    letterSpacing: -1.0,
    color: Colors.white,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Colors.white,
  );

  // Error and Success Message Styles
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  static const TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );

  static const TextStyle warningText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
  );

  static const TextStyle infoText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.info,
  );

  // Link Styles
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.dubaiTeal,
    decoration: TextDecoration.underline,
  );

  static const TextStyle linkLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.dubaiTeal,
    decoration: TextDecoration.underline,
  );

  // Input and Form Styles
  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  // Age Range Styles
  static const TextStyle ageRange = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Feature Badge Styles
  static const TextStyle featuredBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle trendingBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // Private constructor to prevent instantiation
  AppTextStyles._();
}

/// Extension for creating text styles with different colors
extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }

  TextStyle withOpacity(double opacity) {
    return copyWith(color: color?.withOpacity(opacity));
  }

  TextStyle withWeight(FontWeight weight) {
    return copyWith(fontWeight: weight);
  }

  TextStyle withSize(double size) {
    return copyWith(fontSize: size);
  }
} 