import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class NativeBannerSimple extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const NativeBannerSimple({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<NativeBannerSimple> createState() => _NativeBannerSimpleState();
}

class _NativeBannerSimpleState extends State<NativeBannerSimple> {
  late final String viewType;
  late final String containerId;
  html.DivElement? _container;
  int _reloadCount = 0;

  @override
  void initState() {
    super.initState();
    containerId = 'container-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    viewType = 'native-banner-simple-$containerId';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      _container = html.DivElement()
        ..id = containerId
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px'
        ..style.position = 'relative';

      // Load the ad
      _loadAd();

      return _container!;
    });
  }

  void _loadAd() {
    if (_container == null) return;

    // Clear existing content
    _container!.children.clear();

    // Create a unique container for this load
    final adContainerId = 'ad-container-${widget.adKey}-${_reloadCount++}';
    final adContainer = html.DivElement()
      ..id = adContainerId
      ..style.width = '100%'
      ..style.height = '100%';
    
    _container!.append(adContainer);

    // Inject the ad script
    final scriptContent = '''
    (function() {
      // Wait for container to be ready
      var container = document.getElementById('$adContainerId');
      if (!container) return;
      
      // Create and inject the ad script
      var script = document.createElement('script');
      script.async = true;
      script.setAttribute('data-cfasync', 'false');
      script.src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js?_=' + Date.now();
      
      script.onload = function() {
        console.log('Ad script loaded for ${widget.adKey}');
        
        // Store reload function if available
        setTimeout(function() {
          var adDiv = document.getElementById('container-${widget.adKey}');
          if (adDiv && adDiv.reload) {
            window['reload_${widget.adKey}'] = function() {
              try {
                adDiv.reload();
                console.log('Reloaded using native function');
              } catch(e) {
                console.error('Native reload failed:', e);
              }
            };
          }
        }, 500);
      };
      
      script.onerror = function() {
        console.error('Failed to load ad script');
        container.innerHTML = '<div style="text-align:center;padding:20px;color:#999;">Ad unavailable</div>';
      };
      
      container.appendChild(script);
    })();
    ''';

    final scriptElement = html.ScriptElement()
      ..text = scriptContent;
    
    _container!.append(scriptElement);
  }

  void reload() {
    print('Reloading ad: ${widget.adKey}');
    
    // Try native reload first
    html.window.context.callMethod('eval', ['''
      if (window['reload_${widget.adKey}']) {
        window['reload_${widget.adKey}']();
      } else {
        console.log('Native reload not available, doing full reload');
      }
    ''']);
    
    // If native reload doesn't work, do full reload
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadAd();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}