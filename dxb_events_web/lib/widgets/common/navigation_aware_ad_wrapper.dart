import 'package:flutter/material.dart';
import 'native_banner_widget.dart';

class NavigationAwareAdWrapper extends StatefulWidget {
  final Widget child;
  
  const NavigationAwareAdWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NavigationAwareAdWrapper> createState() => _NavigationAwareAdWrapperState();
}

class _NavigationAwareAdWrapperState extends State<NavigationAwareAdWrapper> with RouteAware {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  final GlobalKey<_NativeBannerWidgetState> _bannerKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Route was pushed onto navigator
    _reloadAds();
  }

  @override
  void didPopNext() {
    // Returned to this route from another route
    _reloadAds();
  }

  void _reloadAds() {
    // Delay to ensure DOM is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_bannerKey.currentState != null) {
        _bannerKey.currentState!.reload();
      }
      
      // Also trigger the global reload function if available
      try {
        // This calls the JavaScript function defined in index.html
        final jsContext = (context as dynamic).jsObject;
        if (jsContext != null && jsContext.hasProperty('reloadNativeBanner')) {
          jsContext.callMethod('reloadNativeBanner');
        }
      } catch (e) {
        // Fallback for web-specific functionality
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Mixin to add navigation awareness to any screen
mixin AdReloadMixin<T extends StatefulWidget> on State<T> implements RouteAware {
  RouteObserver<PageRoute>? _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = NavigatorObserver() as RouteObserver<PageRoute>?;
    final route = ModalRoute.of(context);
    if (route is PageRoute && _routeObserver != null) {
      _routeObserver!.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _onNavigationEvent();
  }

  @override
  void didPopNext() {
    _onNavigationEvent();
  }

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  void _onNavigationEvent() {
    // Override this method in your screen to handle navigation events
    reloadAds();
  }

  void reloadAds() {
    // This method should be overridden by the implementing class
    // to reload specific ads on that screen
  }
}

// Example usage in a screen
class ExampleScreenWithAds extends StatefulWidget {
  const ExampleScreenWithAds({Key? key}) : super(key: key);

  @override
  State<ExampleScreenWithAds> createState() => _ExampleScreenWithAdsState();
}

class _ExampleScreenWithAdsState extends State<ExampleScreenWithAds> with AdReloadMixin {
  final GlobalKey<_NativeBannerWidgetState> _topBannerKey = GlobalKey();
  final GlobalKey<_NativeBannerWidgetState> _bottomBannerKey = GlobalKey();

  @override
  void reloadAds() {
    // Reload all ads on this screen
    Future.delayed(const Duration(milliseconds: 300), () {
      _topBannerKey.currentState?.reload();
      _bottomBannerKey.currentState?.reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top banner
          NativeBannerWidget(
            key: _topBannerKey,
            adKey: 'e1bd304e9b4f790ab61f30e117275a37',
            containerId: 'container-e1bd304e9b4f790ab61f30e117275a37-top',
            scriptSrc: '//pl27139224.profitableratecpm.com/e1bd304e9b4f790ab61f30e117275a37/invoke.js',
          ),
          
          // Your content here
          Expanded(
            child: Container(
              child: const Text('Your content here'),
            ),
          ),
          
          // Bottom banner
          NativeBannerWidget(
            key: _bottomBannerKey,
            adKey: 'e1bd304e9b4f790ab61f30e117275a37',
            containerId: 'container-e1bd304e9b4f790ab61f30e117275a37-bottom',
            scriptSrc: '//pl27139224.profitableratecpm.com/e1bd304e9b4f790ab61f30e117275a37/invoke.js',
          ),
        ],
      ),
    );
  }
}