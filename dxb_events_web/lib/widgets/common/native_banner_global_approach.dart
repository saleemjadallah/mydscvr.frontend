import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;
import 'package:flutter/material.dart';

class NativeBannerGlobalApproach extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const NativeBannerGlobalApproach({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<NativeBannerGlobalApproach> createState() => _NativeBannerGlobalApproachState();
}

class _NativeBannerGlobalApproachState extends State<NativeBannerGlobalApproach> {
  late final String viewType;
  late final String containerId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    containerId = 'container-${widget.adKey}';
    viewType = 'native-banner-global-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..width = widget.width.toString()
        ..height = widget.height.toString()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      // Create the HTML content with the ad
      final adHtml = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
        }
        #$containerId {
            width: ${widget.width}px;
            height: ${widget.height}px;
        }
    </style>
</head>
<body>
    <div id="$containerId"></div>
    
    <script type="text/javascript">
        // Global reload function
        window.reloadAd = function() {
            console.log('Reload requested for ${widget.adKey}');
            
            // Method 1: Try container reload
            var container = document.getElementById('$containerId');
            if (container && container.reload) {
                container.reload();
                return;
            }
            
            // Method 2: Re-inject the script
            var existingScript = document.querySelector('script[src*="${widget.adKey}"]');
            if (existingScript) {
                existingScript.remove();
            }
            
            // Clear container
            container.innerHTML = '';
            
            // Re-inject
            var script = document.createElement('script');
            script.async = true;
            script.src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js?t=' + Date.now();
            container.appendChild(script);
        };
        
        // Initial load
        (function() {
            var script = document.createElement('script');
            script.async = true;
            script.src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js';
            
            script.onload = function() {
                // Try to set up reload after load
                setTimeout(function() {
                    var container = document.getElementById('$containerId');
                    if (container && container.reload && !window.originalReload) {
                        window.originalReload = container.reload.bind(container);
                        window.reloadAd = function() {
                            console.log('Using native reload for ${widget.adKey}');
                            window.originalReload();
                        };
                    }
                }, 1000);
            };
            
            document.getElementById('$containerId').appendChild(script);
        })();
    </script>
</body>
</html>
      ''';

      iframe.src = 'data:text/html;charset=utf-8,' + Uri.encodeComponent(adHtml);

      // Set up message listener for reload requests
      html.window.addEventListener('message', (event) {
        final message = (event as html.MessageEvent).data;
        if (message == 'reload-ad-${widget.adKey}') {
          // Call reload in iframe
          iframe.contentWindow?.postMessage('reload', '*');
        }
      });

      iframe.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });

      return iframe;
    });
  }

  void reload() {
    // Send reload message
    html.window.postMessage('reload-ad-${widget.adKey}', '*');
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
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: HtmlElementView(viewType: viewType),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}