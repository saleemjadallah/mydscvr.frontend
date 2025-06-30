import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../widgets/notifications/notification_bell.dart';
import '../theme/app_theme.dart';

/// Dynamic Dubai-inspired app bar with beautiful gradients and animations
/// Perfect for creating engaging headers throughout the DXB Events platform
class DubaiAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;
  final bool showNotificationBell;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final bool showCurrentRoute;

  const DubaiAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.onBackTap,
    this.actions,
    this.showNotificationBell = true,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.showCurrentRoute = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColor != null 
              ? [backgroundColor!, backgroundColor!]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
        ),
        boxShadow: elevation > 0 ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ] : null,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        automaticallyImplyLeading: false,
        leading: automaticallyImplyLeading && _shouldShowBackButton(context)
            ? _buildBackButton(context)
            : null,
        title: _buildTitle(context),
        actions: _buildActions(context),
      ),
    );
  }

  bool _shouldShowBackButton(BuildContext context) {
    return context.canPop();
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onBackTap != null) {
          onBackTap!();
        } else {
          context.pop();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          LucideIcons.arrowLeft,
          color: Colors.white,
          size: 20,
        ),
      ),
    ).animate().slideX(
      delay: 100.ms,
      duration: 400.ms,
      begin: -1,
      curve: Curves.easeOutQuart,
    );
  }

  Widget _buildTitle(BuildContext context) {
    final currentRoute = showCurrentRoute ? GoRouterState.of(context).matchedLocation : null;
    
    return Column(
      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title ?? '',
          style: GoogleFonts.comfortaa(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: centerTitle ? TextAlign.center : TextAlign.left,
        ).animate().slideY(
          delay: 200.ms,
          duration: 400.ms,
          begin: 1,
          end: 0,
          curve: Curves.easeOut,
        ),
        
        if (showCurrentRoute && currentRoute != null) ...[
          const SizedBox(height: 2),
          Text(
            currentRoute,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: centerTitle ? TextAlign.center : TextAlign.left,
          ).animate().slideY(
            delay: 250.ms,
            duration: 400.ms,
            begin: 1,
            end: 0,
            curve: Curves.easeOut,
          ),
        ],
        
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: centerTitle ? TextAlign.center : TextAlign.left,
          ).animate().slideY(
            delay: 300.ms,
            duration: 400.ms,
            begin: 1,
            end: 0,
            curve: Curves.easeOut,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> finalActions = [];
    
    if (showNotificationBell) {
      finalActions.add(
        const NotificationBell(
          color: Colors.white,
          size: 22,
        ).animate().slideX(
          delay: 400.ms,
          duration: 400.ms,
          begin: 1,
          end: 0,
          curve: Curves.easeOut,
        ),
      );
    }
    
    if (actions != null) {
      finalActions.addAll(actions!);
    }

    return finalActions;
  }
}

/// Floating bubble widget for background decoration
class FloatingBubble extends StatefulWidget {
  final double size;
  final Color color;
  final Duration delay;

  const FloatingBubble({
    Key? key,
    required this.size,
    required this.color,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _moveAnimation = Tween<double>(
      begin: 0.0,
      end: -50.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
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
        return Transform.translate(
          offset: Offset(0, _moveAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Search bar with Dubai styling  
class SearchAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String? hintText;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final bool showNotificationBell;

  const SearchAppBar({
    super.key,
    this.hintText = 'Search Dubai events...',
    this.onSearchChanged,
    this.onFilterTap,
    this.showFilter = true,
    this.showNotificationBell = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends ConsumerState<SearchAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Find Activities',
              style: GoogleFonts.comfortaa(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ).animate().slideX(
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
          ],
        ),
        actions: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: widget.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.showFilter)
                    GestureDetector(
                      onTap: widget.onFilterTap,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.sliders,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.showNotificationBell)
            const NotificationBell(
              color: Colors.white,
              size: 22,
            ).animate().slideX(
              delay: 400.ms,
              duration: 400.ms,
              begin: 1,
              end: 0,
              curve: Curves.easeOut,
            ),
        ],
      ),
    );
  }
}

/// Collapsible app bar for detailed views
class CollapsibleDubaiAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? backgroundImage;
  final List<Widget>? actions;

  const CollapsibleDubaiAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backgroundImage,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: GoogleFonts.comfortaa(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (backgroundImage != null) backgroundImage!,
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 