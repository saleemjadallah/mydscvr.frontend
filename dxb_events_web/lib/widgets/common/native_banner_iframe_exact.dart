import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

/// This widget creates an iframe with the EXACT HTML structure
class NativeBannerIframeExact extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const NativeBannerIframeExact({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<NativeBannerIframeExact> createState() => _NativeBannerIframeExactState();
}

class _NativeBannerIframeExactState extends State<NativeBannerIframeExact> {
  late final String viewType;
  
  @override
  void initState() {
    super.initState();
    viewType = 'native-banner-iframe-exact-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..width = widget.width.toString()
        ..height = widget.height.toString()
        ..style.border = 'none';

      // Create the EXACT HTML that works in standalone pages
      final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { margin: 0; padding: 0; }
    </style>
</head>
<body>
    <script async="async" data-cfasync="false" src="//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js"></script>
    <div id="container-${widget.adKey}"></div>
    
    <script>
        // Log for debugging
        console.log('Ad iframe loaded for ${widget.adKey}');
        
        // Set up reload function check
        setTimeout(function() {
            var container = document.getElementById('container-${widget.adKey}');
            if (container && container.reload) {
                console.log('Reload function available for ${widget.adKey}');
                // Store it globally in the iframe
                window.reloadAd = function() {
                    container.reload();
                };
            } else {
                console.log('No reload function for ${widget.adKey}');
            }
        }, 3000);
        
        // Listen for reload messages from parent
        window.addEventListener('message', function(event) {
            if (event.data === 'reload-ad') {
                if (window.reloadAd) {
                    window.reloadAd();
                } else {
                    console.log('Reload function not available');
                }
            }
        });
    </script>
</body>
</html>
      ''';

      iframe.src = 'data:text/html;charset=utf-8,' + Uri.encodeComponent(htmlContent);

      iframe.onLoad.listen((_) {
        print('NativeBannerIframeExact: Iframe loaded for ${widget.adKey}');
      });

      return iframe;
    });
  }

  void reload() {
    // Send reload message to iframe
    final iframe = html.document.querySelector('iframe[src*="${widget.adKey}"]') as html.IFrameElement?;
    if (iframe != null) {
      iframe.contentWindow?.postMessage('reload-ad', '*');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
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