import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dxb_events_web/core/constants/app_colors.dart';

void main() {
  group('App Colors Tests', () {
    test('should have valid Dubai brand colors', () {
      expect(AppColors.dubaiGold, isA<Color>());
      expect(AppColors.dubaiTeal, isA<Color>());
      expect(AppColors.dubaiCoral, isA<Color>());
      expect(AppColors.dubaiPurple, isA<Color>());
    });
    
    test('should have background and surface colors', () {
      expect(AppColors.background, isA<Color>());
      expect(AppColors.surface, isA<Color>());
      expect(AppColors.surfaceVariant, isA<Color>());
    });
    
    test('should have text colors', () {
      expect(AppColors.textPrimary, isA<Color>());
      expect(AppColors.textSecondary, isA<Color>());
      expect(AppColors.textTertiary, isA<Color>());
    });
    
    test('should have semantic colors', () {
      expect(AppColors.success, isA<Color>());
      expect(AppColors.warning, isA<Color>());
      expect(AppColors.error, isA<Color>());
      expect(AppColors.info, isA<Color>());
    });
    
    test('should have gradient definitions', () {
      expect(AppColors.sunsetGradient, isA<LinearGradient>());
      expect(AppColors.oceanGradient, isA<LinearGradient>());
      expect(AppColors.goldenGradient, isA<LinearGradient>());
    });
    
    test('gradient should have proper colors', () {
      final sunsetGradient = AppColors.sunsetGradient;
      expect(sunsetGradient.colors, isNotEmpty);
      expect(sunsetGradient.colors.length, greaterThanOrEqualTo(2));
    });
    
    test('should have category-specific colors', () {
      expect(AppColors.kidsCategory, isA<Color>());
      expect(AppColors.musicCategory, isA<Color>());
      expect(AppColors.artsCategory, isA<Color>());
      expect(AppColors.sportsCategory, isA<Color>());
    });
    
    test('should have age group colors', () {
      expect(AppColors.infantsColor, isA<Color>());
      expect(AppColors.toddlersColor, isA<Color>());
      expect(AppColors.allAgesColor, isA<Color>());
    });
  });
} 