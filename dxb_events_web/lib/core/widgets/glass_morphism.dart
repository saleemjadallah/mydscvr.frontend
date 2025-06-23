import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Glass morphism widget for creating beautiful blurred glass effects
/// Perfect for modern, iOS-like interface elements in DXB Events
class GlassMorphism extends StatelessWidget {
  /// The child widget to be displayed inside the glass container
  final Widget child;

  /// Background color with opacity for the glass effect
  final Color? backgroundColor;

  /// Border radius for the glass container
  final BorderRadius? borderRadius;

  /// Border color and width
  final Border? border;

  /// Blur strength for the glass effect (higher = more blur)
  final double blur;

  /// Opacity of the glass effect (0.0 to 1.0)
  final double opacity;

  /// Custom gradient for the glass background
  final Gradient? gradient;

  /// Padding inside the glass container
  final EdgeInsetsGeometry? padding;

  /// Margin around the glass container
  final EdgeInsetsGeometry? margin;

  /// Width of the glass container
  final double? width;

  /// Height of the glass container
  final double? height;

  /// Whether to clip the child widget
  final Clip clipBehavior;

  /// Shadow for the glass container
  final List<BoxShadow>? boxShadow;

  const GlassMorphism({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.gradient,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Optimize blur for web platform
    final effectiveBlur = kIsWeb ? blur * 0.3 : blur; // Reduce blur on web by 70%
    final shouldUseBlur = effectiveBlur > 0 && !kIsWeb || (kIsWeb && effectiveBlur > 2);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        clipBehavior: clipBehavior,
        child: shouldUseBlur 
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: effectiveBlur, 
                sigmaY: effectiveBlur,
              ),
              child: _buildContainer(),
            )
          : _buildContainer(),
      ),
    );
  }
  
  Widget _buildContainer() {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(opacity),
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border ??
            Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Predefined glass morphism presets for common use cases
class GlassPresets {
  /// Light glass effect for cards and containers
  static Widget light({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) =>
      GlassMorphism(
        blur: 8.0,
        opacity: 0.1,
        backgroundColor: Colors.white.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        padding: padding ?? const EdgeInsets.all(20),
        margin: margin,
        width: width,
        height: height,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        child: child,
      );

  /// Dark glass effect for overlays and modals
  static Widget dark({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) =>
      GlassMorphism(
        blur: 15.0,
        opacity: 0.2,
        backgroundColor: Colors.black.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        padding: padding ?? const EdgeInsets.all(20),
        margin: margin,
        width: width,
        height: height,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        child: child,
      );

  /// Colorful glass effect with gradient
  static Widget colorful({
    required Widget child,
    required Gradient gradient,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) =>
      GlassMorphism(
        blur: 12.0,
        opacity: 0.15,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        padding: padding ?? const EdgeInsets.all(24),
        margin: margin,
        width: width,
        height: height,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        child: child,
      );

  /// Subtle glass effect for navigation bars
  static Widget navigation({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) =>
      GlassMorphism(
        blur: 20.0,
        opacity: 0.8,
        backgroundColor: Colors.white.withOpacity(0.8),
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        width: width,
        height: height,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
        child: child,
      );

  /// Floating glass effect for action buttons
  static Widget floating({
    required Widget child,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) =>
      GlassMorphism(
        blur: 6.0,
        opacity: 0.15,
        backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.15),
        borderRadius: borderRadius ?? BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        padding: padding ?? const EdgeInsets.all(16),
        width: width,
        height: height,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        child: child,
      );

  // Private constructor
  GlassPresets._();
}

/// Extension for easy glass morphism effects on any widget
extension GlassExtension on Widget {
  /// Apply light glass morphism effect
  Widget glass({
    double blur = 10.0,
    double opacity = 0.1,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    Border? border,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
  }) =>
      GlassMorphism(
        blur: blur,
        opacity: opacity,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        border: border,
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        boxShadow: boxShadow,
        child: this,
      );

  /// Apply light glass preset
  Widget glassLight({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) =>
      GlassPresets.light(
        borderRadius: borderRadius,
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        child: this,
      );

  /// Apply dark glass preset
  Widget glassDark({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) =>
      GlassPresets.dark(
        borderRadius: borderRadius,
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        child: this,
      );

  /// Apply colorful glass preset
  Widget glassColorful({
    required Gradient gradient,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) =>
      GlassPresets.colorful(
        gradient: gradient,
        borderRadius: borderRadius,
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        child: this,
      );

  /// Apply navigation glass preset
  Widget glassNavigation({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) =>
      GlassPresets.navigation(
        borderRadius: borderRadius,
        padding: padding,
        width: width,
        height: height,
        child: this,
      );

  /// Apply floating glass preset
  Widget glassFloating({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) =>
      GlassPresets.floating(
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        padding: padding,
        width: width,
        height: height,
        child: this,
      );
}

/// Animated glass morphism widget with smooth transitions
class AnimatedGlassMorphism extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final double blur;
  final double opacity;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedGlassMorphism({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.gradient,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<AnimatedGlassMorphism> createState() => _AnimatedGlassMorphismState();
}

class _AnimatedGlassMorphismState extends State<AnimatedGlassMorphism>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: widget.blur,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: widget.opacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GlassMorphism(
          blur: _blurAnimation.value,
          opacity: _opacityAnimation.value,
          backgroundColor: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          border: widget.border,
          gradient: widget.gradient,
          padding: widget.padding,
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          child: widget.child,
        );
      },
    );
  }
}

/// Glass card widget combining glass morphism with common card properties
class GlassCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double blur;
  final double opacity;

  const GlassCard({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.blur = 8.0,
    this.opacity = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassMorphism(
        blur: blur,
        opacity: opacity,
        backgroundColor: backgroundColor ?? Colors.white.withOpacity(opacity),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        padding: padding ?? const EdgeInsets.all(20),
        margin: margin,
        width: width,
        height: height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || subtitle != null || leading != null || trailing != null)
              _buildHeader(),
            if (title != null || subtitle != null) const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
} 