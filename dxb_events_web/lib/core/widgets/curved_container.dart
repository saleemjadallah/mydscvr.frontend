import 'package:flutter/material.dart';

/// A container with beautiful curved designs perfect for hero sections and headers
/// Creates the flowing, organic feel that makes DXB Events feel welcoming
class CurvedContainer extends StatelessWidget {
  /// The child widget to be displayed inside the curved container
  final Widget child;

  /// Gradient for the curved container background
  final Gradient? gradient;

  /// Solid background color (used if gradient is null)
  final Color? backgroundColor;

  /// Height of the curve effect
  final double curveHeight;

  /// Position of the curve (top or bottom)
  final CurvePosition curvePosition;

  /// Type of curve shape
  final CurveType curveType;

  /// Custom clipper for advanced curve shapes
  final CustomClipper<Path>? customClipper;

  /// Padding inside the curved container
  final EdgeInsetsGeometry? padding;

  /// Width of the container
  final double? width;

  /// Height of the container
  final double? height;

  const CurvedContainer({
    Key? key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.curveHeight = 50.0,
    this.curvePosition = CurvePosition.bottom,
    this.curveType = CurveType.concave,
    this.customClipper,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: customClipper ?? CurveClipper(
        curveHeight: curveHeight,
        curvePosition: curvePosition,
        curveType: curveType,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor ?? Colors.blue,
        ),
        child: child,
      ),
    );
  }
}

/// Custom clipper for creating curved shapes
class CurveClipper extends CustomClipper<Path> {
  final double curveHeight;
  final CurvePosition curvePosition;
  final CurveType curveType;
  
  // Cache the path to avoid recalculation
  Path? _cachedPath;
  Size? _cachedSize;

  CurveClipper({
    required this.curveHeight,
    required this.curvePosition,
    required this.curveType,
  });

  @override
  Path getClip(Size size) {
    // Return cached path if size hasn't changed
    if (_cachedPath != null && _cachedSize == size) {
      return _cachedPath!;
    }
    
    final path = Path();

    switch (curvePosition) {
      case CurvePosition.top:
        _cachedPath = _createTopCurve(size, path);
        break;
      case CurvePosition.bottom:
        _cachedPath = _createBottomCurve(size, path);
        break;
      case CurvePosition.both:
        _cachedPath = _createBothCurves(size, path);
        break;
    }
    
    _cachedSize = size;
    return _cachedPath!;
  }

  Path _createTopCurve(Size size, Path path) {
    switch (curveType) {
      case CurveType.concave:
        path.moveTo(0, curveHeight);
        path.quadraticBezierTo(
          size.width / 2, 0,
          size.width, curveHeight,
        );
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;

      case CurveType.convex:
        path.moveTo(0, 0);
        path.quadraticBezierTo(
          size.width / 2, curveHeight,
          size.width, 0,
        );
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;

      case CurveType.wave:
        path.moveTo(0, curveHeight / 2);
        path.quadraticBezierTo(
          size.width * 0.25, 0,
          size.width * 0.5, curveHeight / 2,
        );
        path.quadraticBezierTo(
          size.width * 0.75, curveHeight,
          size.width, curveHeight / 2,
        );
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    return path;
  }

  Path _createBottomCurve(Size size, Path path) {
    switch (curveType) {
      case CurveType.concave:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - curveHeight);
        path.quadraticBezierTo(
          size.width / 2, size.height,
          0, size.height - curveHeight,
        );
        break;

      case CurveType.convex:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.quadraticBezierTo(
          size.width / 2, size.height - curveHeight,
          0, size.height,
        );
        break;

      case CurveType.wave:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - curveHeight / 2);
        path.quadraticBezierTo(
          size.width * 0.75, size.height - curveHeight,
          size.width * 0.5, size.height - curveHeight / 2,
        );
        path.quadraticBezierTo(
          size.width * 0.25, size.height,
          0, size.height - curveHeight / 2,
        );
        break;
    }

    path.close();
    return path;
  }

  Path _createBothCurves(Size size, Path path) {
    // Start from top-left with curve
    path.moveTo(0, curveHeight);
    path.quadraticBezierTo(
      size.width / 2, 0,
      size.width, curveHeight,
    );

    // Right side
    path.lineTo(size.width, size.height - curveHeight);

    // Bottom curve
    path.quadraticBezierTo(
      size.width / 2, size.height,
      0, size.height - curveHeight,
    );

    // Left side back to start
    path.lineTo(0, curveHeight);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    if (oldClipper is CurveClipper) {
      return oldClipper.curveHeight != curveHeight ||
             oldClipper.curvePosition != curvePosition ||
             oldClipper.curveType != curveType;
    }
    return true;
  }
}

/// Position of the curve in the container
enum CurvePosition {
  top,
  bottom,
  both,
}

/// Type of curve shape
enum CurveType {
  concave,
  convex,
  wave,
}

/// Preset curved containers for common use cases
class CurvedPresets {
  /// Hero section with bottom curve
  static Widget hero({
    required Widget child,
    Gradient? gradient,
    Color? backgroundColor,
    double curveHeight = 40.0,
  }) =>
      CurvedContainer(
        gradient: gradient,
        backgroundColor: backgroundColor,
        curveHeight: curveHeight,
        curvePosition: CurvePosition.bottom,
        curveType: CurveType.concave,
        child: child,
      );

  /// Card with top curve
  static Widget card({
    required Widget child,
    Color? backgroundColor,
    double curveHeight = 20.0,
  }) =>
      CurvedContainer(
        backgroundColor: backgroundColor ?? Colors.white,
        curveHeight: curveHeight,
        curvePosition: CurvePosition.top,
        curveType: CurveType.convex,
        padding: const EdgeInsets.all(20),
        child: child,
      );

  /// Wave-shaped container
  static Widget wave({
    required Widget child,
    Gradient? gradient,
    Color? backgroundColor,
    double curveHeight = 30.0,
  }) =>
      CurvedContainer(
        gradient: gradient,
        backgroundColor: backgroundColor,
        curveHeight: curveHeight,
        curvePosition: CurvePosition.bottom,
        curveType: CurveType.wave,
        child: child,
      );

  /// Bubble-shaped container with curves on both ends
  static Widget bubble({
    required Widget child,
    Color? backgroundColor,
    double curveHeight = 25.0,
  }) =>
      CurvedContainer(
        backgroundColor: backgroundColor ?? Colors.white,
        curveHeight: curveHeight,
        curvePosition: CurvePosition.both,
        curveType: CurveType.concave,
        padding: const EdgeInsets.all(16),
        child: child,
      );

  // Private constructor
  CurvedPresets._();
}

/// Extension for easy curved decoration on any widget
extension CurvedExtension on Widget {
  /// Wrap this widget in a curved container
  Widget curved({
    Gradient? gradient,
    Color? backgroundColor,
    double curveHeight = 50.0,
    CurvePosition curvePosition = CurvePosition.bottom,
    CurveType curveType = CurveType.concave,
    EdgeInsetsGeometry? padding,
  }) =>
      CurvedContainer(
        gradient: gradient,
        backgroundColor: backgroundColor,
        curveHeight: curveHeight,
        curvePosition: curvePosition,
        curveType: curveType,
        padding: padding,
        child: this,
      );

  /// Wrap this widget in a hero-style curved container
  Widget curvedHero({
    Gradient? gradient,
    Color? backgroundColor,
    double curveHeight = 40.0,
  }) =>
      CurvedPresets.hero(
        gradient: gradient,
        backgroundColor: backgroundColor,
        curveHeight: curveHeight,
        child: this,
      );

  /// Wrap this widget in a card-style curved container
  Widget curvedCard({
    Color? backgroundColor,
    double curveHeight = 20.0,
  }) =>
      CurvedPresets.card(
        backgroundColor: backgroundColor,
        curveHeight: curveHeight,
        child: this,
      );

  /// Wrap this widget in a wave-style curved container
  Widget curvedWave({
    Gradient? gradient,
    Color? backgroundColor,
    double curveHeight = 30.0,
  }) =>
      CurvedPresets.wave(
        gradient: gradient,
        backgroundColor: backgroundColor,
        curveHeight: curveHeight,
        child: this,
      );

  /// Wrap this widget in a bubble-style curved container
  Widget curvedBubble({
    Color? backgroundColor,
    double curveHeight = 25.0,
  }) =>
      CurvedPresets.bubble(
        backgroundColor: backgroundColor,
        curveHeight: curveHeight,
        child: this,
      );
}

/// Animated curved container with smooth transitions
class AnimatedCurvedContainer extends StatefulWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double curveHeight;
  final CurvePosition curvePosition;
  final CurveType curveType;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedCurvedContainer({
    Key? key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.curveHeight = 50.0,
    this.curvePosition = CurvePosition.bottom,
    this.curveType = CurveType.concave,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<AnimatedCurvedContainer> createState() => _AnimatedCurvedContainerState();
}

class _AnimatedCurvedContainerState extends State<AnimatedCurvedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _curveAnimation = Tween<double>(
      begin: 0.0,
      end: widget.curveHeight,
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
      animation: _curveAnimation,
      builder: (context, child) {
        return CurvedContainer(
          gradient: widget.gradient,
          backgroundColor: widget.backgroundColor,
          curveHeight: _curveAnimation.value,
          curvePosition: widget.curvePosition,
          curveType: widget.curveType,
          child: widget.child,
        );
      },
    );
  }
} 