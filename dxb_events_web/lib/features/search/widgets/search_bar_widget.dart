import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/glass_morphism.dart';

/// Beautiful search bar widget for Dubai Events platform
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final bool isLoading;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onClear,
    this.onSubmitted,
    this.isLoading = false,
    this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen to focus changes
    widget.focusNode.addListener(_onFocusChanged);
    
    // Listen to text changes
    widget.controller.addListener(_onTextChanged);
    
    // Initialize text state
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleClear() {
    widget.controller.clear();
    widget.onClear?.call();
    widget.focusNode.requestFocus();
  }

  void _handleSubmit() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                // Glow effect when focused
                if (_isFocused)
                  BoxShadow(
                    color: AppColors.dubaiGold.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                // Main shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: GlassMorphism(
              blur: 20,
              opacity: 0.9,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _isFocused 
                        ? AppColors.dubaiGold.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                    width: _isFocused ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Search icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isFocused 
                            ? AppColors.dubaiGold.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.search,
                        color: _isFocused ? AppColors.dubaiGold : Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        onSubmitted: (_) => _handleSubmit(),
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? 'Search family activities in Dubai...',
                          hintStyle: AppTypography.body1.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    
                    // Right side actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Loading indicator
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.dubaiGold,
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                            .rotate(duration: 1000.ms),
                          const SizedBox(width: 12),
                        ],
                        
                        // Clear button
                        if (_hasText && !widget.isLoading) ...[
                          GestureDetector(
                            onTap: _handleClear,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.x,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ).animate()
                            .scale(duration: 200.ms)
                            .fade(),
                          const SizedBox(width: 12),
                        ],
                        
                        // Voice search button (placeholder for future)
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement voice search
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice search coming soon!'),
                                backgroundColor: AppColors.dubaiTeal,
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isFocused 
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.mic,
                              color: Colors.white.withOpacity(0.8),
                              size: 18,
                            ),
                          ),
                        ),
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
}

/// Compact search bar for smaller spaces
class CompactSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onTap;
  final String? hintText;
  final bool enabled;

  const CompactSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onTap,
    this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 45,
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
            Icon(
              LucideIcons.search,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.text.isEmpty 
                    ? (hintText ?? 'Search events...')
                    : controller.text,
                style: AppTypography.body2.copyWith(
                  color: controller.text.isEmpty 
                      ? Colors.white.withOpacity(0.7)
                      : Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (controller.text.isNotEmpty) ...[
              Icon(
                LucideIcons.arrowRight,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Search suggestion item widget
class SearchSuggestionItem extends StatelessWidget {
  final String suggestion;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool highlighted;

  const SearchSuggestionItem({
    super.key,
    required this.suggestion,
    this.subtitle,
    this.icon,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: highlighted 
              ? AppColors.dubaiGold.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: highlighted 
              ? Border.all(color: AppColors.dubaiGold.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon ?? LucideIcons.search,
              color: highlighted 
                  ? AppColors.dubaiGold
                  : AppColors.textSecondaryDark,
              size: 18,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion,
                    style: AppTypography.body1.copyWith(
                      color: highlighted 
                          ? AppColors.dubaiGold
                          : AppColors.textDark,
                      fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              LucideIcons.arrowUpLeft,
              color: AppColors.textSecondaryDark,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 