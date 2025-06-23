import 'package:flutter/material.dart';

/// A reusable animation widget that combines fade-in and slide-up effects
/// 
/// This widget is used throughout the app to create smooth entrance animations
/// for various UI elements like cards, text, and images.
class FadeInSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideDistance;
  final Curve curve;

  const FadeInSlideUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.slideDistance = 0.3,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<FadeInSlideUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _position;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _position = Tween<Offset>(
      begin: Offset(0, widget.slideDistance),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (!_isDisposed && mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _position,
          child: widget.child,
        ),
      ),
    );
  }
} 