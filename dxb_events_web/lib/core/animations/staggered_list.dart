import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// A list widget with staggered animations for each item
/// 
/// Creates a beautiful cascade effect as list items appear on screen
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final double verticalOffset;
  final double horizontalOffset;
  final Axis direction;
  final EdgeInsets? padding;

  const StaggeredList({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
    this.verticalOffset = 50.0,
    this.horizontalOffset = 0.0,
    this.direction = Axis.vertical,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return AnimationLimiter(
        child: ListView.builder(
          padding: padding,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: duration,
              delay: delay,
              child: SlideAnimation(
                verticalOffset: verticalOffset,
                horizontalOffset: horizontalOffset,
                child: FadeInAnimation(
                  child: children[index],
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Horizontal list
      return SizedBox(
        height: 200, // Default height for horizontal lists
        child: AnimationLimiter(
          child: ListView.builder(
            padding: padding,
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: duration,
                delay: delay,
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: children[index],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }
}

/// A grid widget with staggered animations
class StaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final Duration duration;
  final Duration delay;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets? padding;

  const StaggeredGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.duration = const Duration(milliseconds: 600),
    this.delay = const Duration(milliseconds: 100),
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        padding: padding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        children: List.generate(
          children.length,
          (index) => AnimationConfiguration.staggeredGrid(
            position: index,
            duration: duration,
            delay: delay,
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: children[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A scrollable list with staggered animations that trigger as items come into view
class StaggeredScrollableList extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const StaggeredScrollableList({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 600),
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        controller: scrollController,
        padding: padding,
        itemCount: children.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: duration,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: children[index],
              ),
            ),
          );
        },
      ),
    );
  }
} 