import 'package:flutter/material.dart';

/// A widget that creates a parallax scrolling effect for backgrounds
/// 
/// Adds depth and visual interest to scrollable screens
class ParallaxBackground extends StatefulWidget {
  final Widget child;
  final String? backgroundImage;
  final Widget? backgroundWidget;
  final double parallaxFactor;
  final double backgroundHeight;
  final ScrollController? scrollController;
  final Alignment alignment;

  const ParallaxBackground({
    super.key,
    required this.child,
    this.backgroundImage,
    this.backgroundWidget,
    this.parallaxFactor = 0.5,
    this.backgroundHeight = 300,
    this.scrollController,
    this.alignment = Alignment.topCenter,
  }) : assert(
          backgroundImage != null || backgroundWidget != null,
          'Either backgroundImage or backgroundWidget must be provided',
        );

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Parallax background
        Positioned(
          top: -_scrollOffset * widget.parallaxFactor,
          left: 0,
          right: 0,
          height: widget.backgroundHeight,
          child: widget.backgroundWidget ??
              Image.asset(
                widget.backgroundImage!,
                fit: BoxFit.cover,
                alignment: widget.alignment,
              ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}

/// A sliver that creates a parallax effect in CustomScrollView
class SliverParallaxBackground extends StatelessWidget {
  final Widget backgroundChild;
  final double expandedHeight;
  final double parallaxRatio;

  const SliverParallaxBackground({
    super.key,
    required this.backgroundChild,
    this.expandedHeight = 300.0,
    this.parallaxRatio = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverParallaxBackgroundDelegate(
        backgroundChild: backgroundChild,
        expandedHeight: expandedHeight,
        parallaxRatio: parallaxRatio,
      ),
      pinned: false,
    );
  }
}

class _SliverParallaxBackgroundDelegate extends SliverPersistentHeaderDelegate {
  final Widget backgroundChild;
  final double expandedHeight;
  final double parallaxRatio;

  _SliverParallaxBackgroundDelegate({
    required this.backgroundChild,
    required this.expandedHeight,
    required this.parallaxRatio,
  });

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double parallaxOffset = shrinkOffset * parallaxRatio;
    final double opacity = 1.0 - (shrinkOffset / expandedHeight).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -parallaxOffset,
          left: 0,
          right: 0,
          height: expandedHeight,
          child: Opacity(
            opacity: opacity,
            child: backgroundChild,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _SliverParallaxBackgroundDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight ||
        parallaxRatio != oldDelegate.parallaxRatio ||
        backgroundChild != oldDelegate.backgroundChild;
  }
}

/// A container with a parallax background effect
class ParallaxContainer extends StatelessWidget {
  final Widget child;
  final String? imageUrl;
  final double height;
  final double parallaxOffset;
  final Alignment alignment;

  const ParallaxContainer({
    super.key,
    required this.child,
    this.imageUrl,
    this.height = 200,
    this.parallaxOffset = 0.0,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            if (imageUrl != null)
              Positioned(
                top: parallaxOffset,
                left: 0,
                right: 0,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  height: height * 1.3,
                  alignment: alignment,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                  ),
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
} 