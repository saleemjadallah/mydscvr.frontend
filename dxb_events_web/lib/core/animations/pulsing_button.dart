import 'package:flutter/material.dart';
import 'package:dxb_events_web/core/constants/app_colors.dart';

/// A button widget with a pulsing animation effect
/// 
/// Creates an eye-catching animation perfect for CTAs like "Book Now" or "Get Started"
class PulsingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? pulseColor;
  final double pulseScale;
  final Duration duration;
  final bool enabled;

  const PulsingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.pulseColor,
    this.pulseScale = 1.05,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pulseScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulseColor = widget.pulseColor ?? AppColors.dubaiTeal;

    return GestureDetector(
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            if (widget.enabled)
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: pulseColor.withOpacity(_opacityAnimation.value),
                        blurRadius: 20 * _scaleAnimation.value,
                        spreadRadius: 5 * (_scaleAnimation.value - 1),
                      ),
                    ],
                  ),
                  child: Opacity(
                    opacity: 0,
                    child: widget.child,
                  ),
                ),
              ),
            // Main button
            widget.child,
          ],
        ),
      ),
    );
  }
} 