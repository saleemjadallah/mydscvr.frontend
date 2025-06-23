import 'package:flutter/material.dart';

/// A beautiful bubble-styled container with soft shadows and curved elements
/// Perfect for creating the playful, family-friendly aesthetic of DXB Events
class BubbleDecoration extends StatelessWidget {
  /// The child widget to be wrapped in the bubble decoration
  final Widget child;

  /// Custom bubble color (defaults to white)
  final Color? bubbleColor;

  /// Border radius for the bubble (defaults to 20)
  final double borderRadius;

  /// Custom shadows for the bubble
  final List<BoxShadow>? shadows;

  /// Optional gradient for the bubble background
  final Gradient? gradient;

  /// Optional border for the bubble
  final Border? border;

  /// Margin around the bubble
  final EdgeInsetsGeometry? margin;

  /// Padding inside the bubble
  final EdgeInsetsGeometry? padding;

  /// Width of the bubble
  final double? width;

  /// Height of the bubble
  final double? height;

  const BubbleDecoration({
    Key? key,
    required this.child,
    this.bubbleColor,
    this.borderRadius = 20,
    this.shadows,
    this.gradient,
    this.border,
    this.margin,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (bubbleColor ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: shadows ?? [
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
      ),
      child: child,
    );
  }
}

/// Preset bubble decorations for common use cases
class BubblePresets {
  /// Card-style bubble for content containers
  static BubbleDecoration card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) =>
      BubbleDecoration(
        borderRadius: 24,
        padding: padding ?? const EdgeInsets.all(20),
        margin: margin,
        child: child,
      );

  /// Small bubble for chips and badges
  static BubbleDecoration chip({
    required Widget child,
    Color? color,
  }) =>
      BubbleDecoration(
        borderRadius: 16,
        bubbleColor: color ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        child: child,
      );

  /// Floating bubble for overlays and floating elements
  static BubbleDecoration floating({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) =>
      BubbleDecoration(
        borderRadius: 20,
        padding: padding ?? const EdgeInsets.all(16),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
        ],
        child: child,
      );

  /// Subtle bubble for subtle emphasis
  static BubbleDecoration subtle({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) =>
      BubbleDecoration(
        borderRadius: 16,
        padding: padding ?? const EdgeInsets.all(12),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        child: child,
      );

  /// Gradient bubble with beautiful color transitions
  static BubbleDecoration gradient({
    required Widget child,
    required Gradient gradientColors,
    EdgeInsetsGeometry? padding,
    double borderRadius = 20,
  }) =>
      BubbleDecoration(
        borderRadius: borderRadius,
        gradient: gradientColors,
        padding: padding ?? const EdgeInsets.all(16),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        child: child,
      );

  // Private constructor
  BubblePresets._();
}

/// Extension for easy bubble decoration on any widget
extension BubbleExtension on Widget {
  /// Wrap this widget in a bubble decoration
  Widget bubble({
    Color? color,
    double borderRadius = 20,
    List<BoxShadow>? shadows,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) =>
      BubbleDecoration(
        bubbleColor: color,
        borderRadius: borderRadius,
        shadows: shadows,
        padding: padding,
        margin: margin,
        child: this,
      );

  /// Wrap this widget in a card-style bubble
  Widget bubbleCard({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) =>
      BubblePresets.card(
        padding: padding,
        margin: margin,
        child: this,
      );

  /// Wrap this widget in a floating bubble
  Widget bubbleFloating({
    EdgeInsetsGeometry? padding,
  }) =>
      BubblePresets.floating(
        padding: padding,
        child: this,
      );

  /// Wrap this widget in a subtle bubble
  Widget bubbleSubtle({
    EdgeInsetsGeometry? padding,
  }) =>
      BubblePresets.subtle(
        padding: padding,
        child: this,
      );
} 