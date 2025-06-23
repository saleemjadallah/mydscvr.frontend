import 'package:flutter/material.dart';

/// Slide page transition from right to left
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Slide page transition from bottom to top
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

/// Fade page transition
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  FadeRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Scale page transition (zoom effect)
class ScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  ScaleRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const curve = Curves.fastOutSlowIn;
            var tween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

/// Combined fade and scale transition
class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  FadeScaleRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const curve = Curves.easeOutCubic;
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );
            var scaleTween = Tween(begin: 0.95, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}

/// Hero dialog route for modal-like transitions
class HeroDialogRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  
  HeroDialogRoute({required this.builder})
      : super();

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }
}

/// Shared axis transition for tab-like navigation
class SharedAxisRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisTransitionType transitionType;
  
  SharedAxisRoute({
    required this.page,
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = _getOffsetAnimation(
              animation,
              transitionType,
            );
            
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
  
  static Animation<Offset> _getOffsetAnimation(
    Animation<double> animation,
    SharedAxisTransitionType type,
  ) {
    switch (type) {
      case SharedAxisTransitionType.horizontal:
        return Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
      case SharedAxisTransitionType.vertical:
        return Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
      case SharedAxisTransitionType.scaled:
        return Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: Offset.zero,
        ).animate(animation);
    }
  }
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

/// Navigation helper with animated transitions
class AnimatedNavigation {
  /// Navigate with slide from right
  static Future<T?> slideRight<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      SlideRightRoute(page: page),
    );
  }
  
  /// Navigate with slide from bottom
  static Future<T?> slideUp<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      SlideUpRoute(page: page),
    );
  }
  
  /// Navigate with fade
  static Future<T?> fade<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      FadeRoute(page: page),
    );
  }
  
  /// Navigate with scale
  static Future<T?> scale<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      ScaleRoute(page: page),
    );
  }
  
  /// Navigate with fade and scale
  static Future<T?> fadeScale<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      FadeScaleRoute(page: page),
    );
  }
  
  /// Navigate with shared axis
  static Future<T?> sharedAxis<T>(
    BuildContext context,
    Widget page, {
    SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
  }) {
    return Navigator.of(context).push<T>(
      SharedAxisRoute(page: page, transitionType: type),
    );
  }
  
  /// Replace with animation
  static Future<T?> replaceWithSlide<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushReplacement<T, void>(
      SlideRightRoute(page: page),
    );
  }
  
  /// Replace with fade
  static Future<T?> replaceWithFade<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushReplacement<T, void>(
      FadeRoute(page: page),
    );
  }
} 