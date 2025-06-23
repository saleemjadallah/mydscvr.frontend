import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

/// Beautiful animated bottom navigation with curved design and smooth transitions
/// Perfect for the family-friendly Dubai Events experience
class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool visible;

  const AnimatedBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.visible = true,
  }) : super(key: key);

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rippleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.visible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: 90,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.dubaiTeal.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, -5),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    // Background decoration
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppColors.dubaiTeal.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                    
                    // Navigation items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0, LucideIcons.home, 'Home'),
                        _buildNavItem(1, LucideIcons.calendar, 'Events'),
                        _buildNavItem(2, LucideIcons.search, 'Search'),
                        _buildNavItem(3, LucideIcons.user, 'Profile'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _rippleController.forward().then((_) {
            _rippleController.reset();
          });
          widget.onTap(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.oceanGradient : null,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.dubaiTeal.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with ripple effect
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected && index == widget.currentIndex
                      ? 1.0 + (_rippleController.value * 0.2)
                      : 1.0,
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    size: 24,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 4),
            
            // Label with smooth transitions
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).scale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.1, 1.1),
      ),
    );
  }
}

/// Navigation item data structure
class NavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color? color;

  const NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.color,
  });
}

/// Floating navigation bubble for special actions
class FloatingNavBubble extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  const FloatingNavBubble({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  }) : super(key: key);

  @override
  State<FloatingNavBubble> createState() => _FloatingNavBubbleState();
}

class _FloatingNavBubbleState extends State<FloatingNavBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 20,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: widget.color != null 
                        ? LinearGradient(
                            colors: [widget.color!, widget.color!.withOpacity(0.8)],
                          )
                        : AppColors.sunsetGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? AppColors.dubaiCoral).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            );
          },
        ),
      ).animate().scale(
        delay: const Duration(milliseconds: 500),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
      ),
    );
  }
}

/// Custom navigation indicator with smooth animations
class NavIndicator extends StatelessWidget {
  final double position;
  final int itemCount;

  const NavIndicator({
    Key? key,
    required this.position,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 3,
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: AppColors.oceanGradient,
        ),
        transform: Matrix4.identity()
          ..translate(
            (MediaQuery.of(context).size.width * 0.8 / itemCount) * position,
            0.0,
          ),
      ),
    );
  }
} 