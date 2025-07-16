import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;
import 'package:flutter/material.dart';

class NativeBannerNuxtStyle extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const NativeBannerNuxtStyle({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<NativeBannerNuxtStyle> createState() => _NativeBannerNuxtStyleState();
}

class _NativeBannerNuxtStyleState extends State<NativeBannerNuxtStyle> with AutomaticKeepAliveClientMixin {
  late final String viewType;
  late final String containerId;
  bool _isMounted = false;
  html.DivElement? _containerElement;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    containerId = 'container-${widget.adKey}';
    viewType = 'native-banner-nuxt-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register the platform view
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      _containerElement = html.DivElement()
        ..id = containerId
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px'
        ..style.position = 'relative';
      
      return _containerElement!;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isMounted) {
      _isMounted = true;
      // Delay to ensure DOM is ready, similar to Nuxt's mounted hook
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _loadBanner();
        }
      });
    }
  }

  void _loadBanner() {
    if (_containerElement == null) return;

    // Clear any existing content
    _containerElement!.children.clear();

    // Check if we already have a reload function stored globally
    final hasReload = js.context.hasProperty('__adReload_${widget.adKey}');
    
    if (hasReload) {
      // Call existing reload function
      js.context.callMethod('__adReload_${widget.adKey}');
      print('Called existing reload function for ${widget.adKey}');
    } else {
      // First time loading - inject the script
      final script = html.ScriptElement()
        ..async = true
        ..src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js';

      script.onLoad.listen((_) {
        print('Script loaded for ${widget.adKey}');
        
        // Set up polling for reload function (Nuxt style with setInterval)
        js.context.callMethod('eval', ['''
          (function() {
            var checkCount = 0;
            var ticker = setInterval(function() {
              checkCount++;
              var container = document.getElementById('$containerId');
              
              if (container && container.reload) {
                clearInterval(ticker);
                
                // Store the reload function globally
                window.__adReload_${widget.adKey} = function() {
                  if (container.reload) {
                    container.reload();
                    console.log('Reloaded ad ${widget.adKey}');
                  }
                };
                
                console.log('Reload function stored for ${widget.adKey}');
              } else if (checkCount > 300) { // ~5 seconds
                clearInterval(ticker);
                console.log('Reload function not found for ${widget.adKey}');
              }
            }, 16); // Check every 16ms like in the Vue/Nuxt example
          })();
        ''']);
      });

      script.onError.listen((error) {
        print('Failed to load script for ${widget.adKey}: $error');
      });

      _containerElement!.append(script);
    }
  }

  void reload() {
    // Call the stored reload function
    if (js.context.hasProperty('__adReload_${widget.adKey}')) {
      js.context.callMethod('__adReload_${widget.adKey}');
    } else {
      // Fallback to full reload
      _loadBanner();
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HtmlElementView(
          viewType: viewType,
          // Keep the view alive to prevent rebuilds
          key: ValueKey(viewType),
        ),
      ),
    );
  }
}

// Wrapper component that manages multiple banners (like Nuxt's page component)
class NuxtStyleBannerPage extends StatefulWidget {
  final List<String> adKeys;
  
  const NuxtStyleBannerPage({
    Key? key,
    required this.adKeys,
  }) : super(key: key);

  @override
  State<NuxtStyleBannerPage> createState() => _NuxtStyleBannerPageState();
}

class _NuxtStyleBannerPageState extends State<NuxtStyleBannerPage> with RouteAware {
  final Map<String, GlobalKey<_NativeBannerNuxtStyleState>> _bannerKeys = {};

  @override
  void initState() {
    super.initState();
    // Create keys for each banner
    for (final adKey in widget.adKeys) {
      _bannerKeys[adKey] = GlobalKey<_NativeBannerNuxtStyleState>();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Similar to Nuxt's route watching
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Handle route changes
    }
  }

  void reloadAllBanners() {
    for (final key in _bannerKeys.values) {
      key.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.adKeys.map((adKey) {
        return NativeBannerNuxtStyle(
          key: _bannerKeys[adKey],
          adKey: adKey,
        );
      }).toList(),
    );
  }
}