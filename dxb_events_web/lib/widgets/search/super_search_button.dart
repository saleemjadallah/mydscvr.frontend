import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/search/super_search_screen.dart';

/// MyDscvr Super Search Button Widget
/// 
/// A prominent, beautifully designed button that launches the Super Search experience.
/// Features glassmorphic design with gradient and animations.
class SuperSearchButton extends StatefulWidget {
  final String? initialQuery;
  final EdgeInsets? margin;
  final double? width;
  final VoidCallback? onTap;

  const SuperSearchButton({
    super.key,
    this.initialQuery,
    this.margin,
    this.width,
    this.onTap,
  });

  @override
  State<SuperSearchButton> createState() => _SuperSearchButtonState();
}

class _SuperSearchButtonState extends State<SuperSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _launchSuperSearch() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      final query = widget.initialQuery?.trim();
      if (query != null && query.isNotEmpty) {
        context.go('/super-search?query=${Uri.encodeComponent(query)}');
      } else {
        context.go('/super-search');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: widget.width,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              onTap: _launchSuperSearch,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.dubaiTeal,
                        AppColors.dubaiTeal.withOpacity(0.8),
                        AppColors.dubaiPurple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dubaiTeal.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MyDscvr Super Search',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Powered by Algolia',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.flash_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const Text(
                                  '< 100ms',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Compact version of Super Search Button for smaller spaces
class SuperSearchButtonCompact extends StatelessWidget {
  final String? initialQuery;
  final VoidCallback? onTap;

  const SuperSearchButtonCompact({
    super.key,
    this.initialQuery,
    this.onTap,
  });

  void _launchSuperSearch(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      final query = initialQuery?.trim();
      if (query != null && query.isNotEmpty) {
        context.go('/super-search?query=${Uri.encodeComponent(query)}');
      } else {
        context.go('/super-search');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchSuperSearch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.dubaiTeal,
              AppColors.dubaiPurple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.dubaiTeal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Super Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Super Search FAB (Floating Action Button)
class SuperSearchFAB extends StatelessWidget {
  final String? initialQuery;
  final VoidCallback? onPressed;

  const SuperSearchFAB({
    super.key,
    this.initialQuery,
    this.onPressed,
  });

  void _launchSuperSearch(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      final query = initialQuery?.trim();
      if (query != null && query.isNotEmpty) {
        context.go('/super-search?query=${Uri.encodeComponent(query)}');
      } else {
        context.go('/super-search');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _launchSuperSearch(context),
      backgroundColor: AppColors.dubaiTeal,
      elevation: 8,
      icon: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
      ),
      label: const Text(
        'Super Search',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}