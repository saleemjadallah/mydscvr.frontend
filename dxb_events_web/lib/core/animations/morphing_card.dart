import 'package:flutter/material.dart';
import 'package:dxb_events_web/core/constants/app_colors.dart';

/// A card that morphs between collapsed and expanded states
/// 
/// Perfect for showing preview content that expands to show full details
class MorphingCard extends StatefulWidget {
  final Widget collapsedChild;
  final Widget expandedChild;
  final bool isExpanded;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const MorphingCard({
    super.key,
    required this.collapsedChild,
    required this.expandedChild,
    required this.isExpanded,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.fastOutSlowIn,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  State<MorphingCard> createState() => _MorphingCardState();
}

class _MorphingCardState extends State<MorphingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: widget.curve),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MorphingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              boxShadow: widget.boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Collapsed content
                  Opacity(
                    opacity: 1.0 - _fadeAnimation.value,
                    child: Transform.scale(
                      scale: 1.0 - (_scaleAnimation.value - 0.95),
                      child: widget.collapsedChild,
                    ),
                  ),
                  // Expanded content
                  if (_expandAnimation.value > 0)
                    Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: widget.expandedChild,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// An expandable card specifically designed for event previews
class EventMorphingCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String price;
  final String location;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget? expandedDetails;

  const EventMorphingCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.isExpanded,
    required this.onTap,
    this.expandedDetails,
  });

  @override
  Widget build(BuildContext context) {
    return MorphingCard(
      isExpanded: isExpanded,
      onTap: onTap,
      collapsedChild: _buildCollapsedView(),
      expandedChild: _buildExpandedView(),
    );
  }

  Widget _buildCollapsedView() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 88,
                height: 88,
                color: AppColors.dubaiTeal.withOpacity(0.1),
                child: const Icon(
                  Icons.image,
                  color: AppColors.dubaiTeal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.dubaiCoral,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.dubaiCoral,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dubaiGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 200,
              color: AppColors.dubaiTeal.withOpacity(0.1),
              child: const Icon(
                Icons.image,
                size: 48,
                color: AppColors.dubaiTeal,
              ),
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.dubaiCoral,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.dubaiCoral,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dubaiGold,
                      ),
                    ),
                  ),
                ],
              ),
              if (expandedDetails != null) ...[
                const SizedBox(height: 20),
                expandedDetails!,
              ],
            ],
          ),
        ),
      ],
    );
  }
} 