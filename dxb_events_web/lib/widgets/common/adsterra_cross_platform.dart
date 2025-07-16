import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';

class AdsterraAd extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailed;

  const AdsterraAd({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.onAdLoaded,
    this.onAdFailed,
  }) : super(key: key);

  @override
  State<AdsterraAd> createState() => _AdsterraAdState();
}

class _AdsterraAdState extends State<AdsterraAd> {
  late final String viewType;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    viewType = 'adsterra-cross-platform-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _registerWebViewFactory();
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _registerWebViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      // Create iframe that loads the ad HTML
      final iframe = html.IFrameElement()
        ..width = widget.width.toString()
        ..height = widget.height.toString()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;

      // Generate the HTML content
      final adHtml = _generateAdHtml();
      iframe.src = 'data:text/html;charset=utf-8,' + Uri.encodeComponent(adHtml);

      // Set timeout for loading
      _loadingTimer = Timer(const Duration(seconds: 15), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
          widget.onAdFailed?.call();
        }
      });

      // Listen for iframe load
      iframe.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
          widget.onAdLoaded?.call();
        }
        _loadingTimer?.cancel();
      });

      // Listen for iframe error
      iframe.onError.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
          widget.onAdFailed?.call();
        }
        _loadingTimer?.cancel();
      });

      return iframe;
    });
  }

  String _generateAdHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        body {
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: transparent;
            font-family: Arial, sans-serif;
        }
        #ad-container {
            width: ${widget.width}px;
            height: ${widget.height}px;
            position: relative;
            background-color: #f8f9fa;
            border-radius: 8px;
            overflow: hidden;
        }
        .loading {
            text-align: center;
            color: #666;
            padding: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
        }
        .error {
            text-align: center;
            color: #dc3545;
            padding: 20px;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div id="ad-container">
        <div class="loading" id="loading">Loading ad...</div>
        <div id="container-${widget.adKey}"></div>
    </div>
    
    <script type="text/javascript">
        window.atOptions = {
            'key': '${widget.adKey}',
            'format': 'iframe',
            'height': ${widget.height.toInt()},
            'width': ${widget.width.toInt()},
            'params': {}
        };
        
        // Try multiple ad server patterns
        const AD_DOMAINS = [
            '//www.topcreativeformat.com',
            '//pl27139224.profitableratecpm.com',
            '//pl15015147.pvclouds.com'
        ];
        
        let currentDomainIndex = 0;
        let retryCount = 0;
        const maxRetries = 3;
        
        function loadAdScript() {
            if (currentDomainIndex >= AD_DOMAINS.length) {
                if (retryCount < maxRetries) {
                    retryCount++;
                    currentDomainIndex = 0;
                    document.getElementById('loading').innerHTML = 'Retrying... (' + retryCount + '/' + maxRetries + ')';
                    setTimeout(loadAdScript, 2000);
                    return;
                } else {
                    document.getElementById('loading').innerHTML = '<div class="error">Ad temporarily unavailable</div>';
                    return;
                }
            }
            
            const script = document.createElement('script');
            script.type = 'text/javascript';
            script.src = AD_DOMAINS[currentDomainIndex] + '/${widget.adKey}/invoke.js';
            script.async = true;
            
            script.onload = function() {
                console.log('Ad script loaded from: ' + script.src);
                document.getElementById('loading').style.display = 'none';
                
                // Check if ad actually loaded and set up reload function
                setTimeout(function() {
                    const container = document.getElementById('ad-container');
                    
                    // Check for container-specific reload function
                    const adContainer = document.getElementById('container-${widget.adKey}');
                    if (adContainer && adContainer.reload) {
                        // Store reload function for later use
                        window.adReloadFunction = function() {
                            try {
                                adContainer.reload();
                                console.log('Ad reloaded using container reload function');
                            } catch (e) {
                                console.error('Error reloading ad:', e);
                            }
                        };
                    }
                    
                    const adFrames = document.querySelectorAll('iframe');
                    if (adFrames.length === 0) {
                        // Try next domain
                        currentDomainIndex++;
                        loadAdScript();
                    }
                }, 3000);
            };
            
            script.onerror = function(e) {
                console.warn('Failed to load ad script from: ' + script.src);
                // Suppress DNS errors in console
                if (e && e.message && e.message.includes('ERR_NAME_NOT_RESOLVED')) {
                    console.log('Domain not accessible, trying next...');
                }
                currentDomainIndex++;
                setTimeout(loadAdScript, 1000); // Add delay before retry
            };
            
            // Add timeout for each script load
            setTimeout(function() {
                if (script.parentNode) {
                    script.parentNode.removeChild(script);
                    currentDomainIndex++;
                    loadAdScript();
                }
            }, 10000);
            
            document.head.appendChild(script);
        }
        
        // Start loading when page is ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', loadAdScript);
        } else {
            loadAdScript();
        }
        
        // Handle reload messages
        window.addEventListener('message', function(event) {
            if (event.data === 'reloadAd') {
                currentDomainIndex = 0;
                retryCount = 0;
                document.getElementById('loading').innerHTML = 'Loading ad...';
                document.getElementById('loading').style.display = 'flex';
                loadAdScript();
            }
        });
    </script>
</body>
</html>
    ''';
  }

  void _reloadAd() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    
    // Send reload message to iframe
    if (kIsWeb) {
      try {
        final iframe = html.document.querySelector('iframe[src*="data:text/html"]') as html.IFrameElement?;
        iframe?.contentWindow?.postMessage('reloadAd', '*');
      } catch (e) {
        print('Error sending reload message: $e');
      }
    }
    
    // Reset timer
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        widget.onAdFailed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // For mobile, you would use webview_flutter here
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'WebView not available\nfor mobile in this implementation',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text(
                      'Loading ad...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasError)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ad temporarily unavailable',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _reloadAd,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}