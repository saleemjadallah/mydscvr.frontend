import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

class GlassmorphicBackground extends StatefulWidget {
  final Widget child;
  final bool animated;

  const GlassmorphicBackground({
    super.key,
    required this.child,
    this.animated = true,
  });

  @override
  State<GlassmorphicBackground> createState() => _GlassmorphicBackgroundState();
}

class _GlassmorphicBackgroundState extends State<GlassmorphicBackground>
    with TickerProviderStateMixin {
  
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    
    _controller3 = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );

    if (widget.animated && !kIsWeb) {
      _controller1.repeat();
      _controller2.repeat();
      _controller3.repeat();
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B6B), // Coral
            const Color(0xFFFFB347), // Orange
            const Color(0xFFFF8E53), // Warm orange
            const Color(0xFFFF6B6B), // Back to coral
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated gradient orbs
          if (widget.animated) ...[
            // Large warm orb
            AnimatedBuilder(
              animation: _controller1,
              builder: (context, child) {
                return Positioned(
                  left: screenSize.width * 0.7 + 
                      (screenSize.width * 0.2 * _controller1.value),
                  top: screenSize.height * 0.2 + 
                      (screenSize.height * 0.3 * 
                      (0.5 + 0.5 * Curves.easeInOut.transform(_controller1.value))),
                  child: Container(
                    width: screenSize.width * 0.6,
                    height: screenSize.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Medium accent orb
            AnimatedBuilder(
              animation: _controller2,
              builder: (context, child) {
                return Positioned(
                  left: screenSize.width * 0.1 + 
                      (screenSize.width * 0.3 * 
                      (0.5 + 0.5 * Curves.easeInOut.transform(_controller2.value))),
                  top: screenSize.height * 0.6 + 
                      (screenSize.height * 0.2 * _controller2.value),
                  child: Container(
                    width: screenSize.width * 0.4,
                    height: screenSize.width * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFD93D).withOpacity(0.3), // Warm yellow
                          const Color(0xFFFFB347).withOpacity(0.2), // Orange
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Small accent orb
            AnimatedBuilder(
              animation: _controller3,
              builder: (context, child) {
                return Positioned(
                  left: screenSize.width * 0.8 + 
                      (screenSize.width * 0.15 * 
                      (0.5 + 0.5 * Curves.easeInOut.transform(_controller3.value))),
                  top: screenSize.height * 0.1 + 
                      (screenSize.height * 0.4 * _controller3.value),
                  child: Container(
                    width: screenSize.width * 0.25,
                    height: screenSize.width * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6BCFCF).withOpacity(0.25), // Teal accent
                          const Color(0xFF4ECDC4).withOpacity(0.15), // Lighter teal
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            // Static gradient orbs for better performance
            Positioned(
              right: -100,
              top: 100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: 50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD93D).withOpacity(0.25),
                      const Color(0xFFFFB347).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          // Content - ensure it's on top with proper positioning
          Positioned.fill(
            child: widget.child,
          ),
        ],
      ),
    );
  }
} 