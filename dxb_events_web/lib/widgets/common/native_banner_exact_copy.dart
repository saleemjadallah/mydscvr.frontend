import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;
import 'package:flutter/material.dart';

/// This widget follows the EXACT pattern from the Nuxt/Vue example
class NativeBannerExactCopy extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;

  const NativeBannerExactCopy({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
  }) : super(key: key);

  @override
  State<NativeBannerExactCopy> createState() => _NativeBannerExactCopyState();
}

class _NativeBannerExactCopyState extends State<NativeBannerExactCopy> {
  late final String viewType;
  html.DivElement? _container;
  
  @override
  void initState() {
    super.initState();
    viewType = 'native-banner-exact-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      _container = html.DivElement()
        ..id = 'container-${widget.adKey}'
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px';
      
      // Wait for next frame then mount the ad
      Future.microtask(() => _mountAd());
      
      return _container!;
    });
  }

  void _mountAd() {
    if (_container == null) return;

    // Check if reload exists in global scope (from previous mount)
    final reloadExists = js.context.callMethod('eval', [
      'typeof window.__reload_${widget.adKey} === "function"'
    ]);

    if (reloadExists == true) {
      // Call existing reload
      js.context.callMethod('__reload_${widget.adKey}');
    } else {
      // Create script element
      final script = html.ScriptElement()
        ..async = true
        ..src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js';

      script.onLoad.listen((_) {
        // Start checking for reload function
        js.context.callMethod('eval', ['''
          (function() {
            const ticker = setInterval(() => {
              const container = document.getElementById('container-${widget.adKey}');
              if (container && container.reload) {
                clearInterval(ticker);
                window.__reload_${widget.adKey} = container.reload.bind(container);
                console.log('Reload function cached for ${widget.adKey}');
              }
            }, 16);
            
            // Stop after 10 seconds
            setTimeout(() => clearInterval(ticker), 10000);
          })();
        ''']);
      });

      // Append script to container (EXACTLY like Vue example)
      _container!.append(script);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: HtmlElementView(viewType: viewType),
    );
  }
}