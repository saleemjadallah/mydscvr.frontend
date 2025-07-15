import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;
import 'package:flutter/material.dart';

class NativeBannerWidget extends StatefulWidget {
  final String adKey;
  final String containerId;
  final String scriptSrc;
  final double width;
  final double height;
  final EdgeInsets margin;
  final bool autoReload;

  const NativeBannerWidget({
    Key? key,
    required this.adKey,
    required this.containerId,
    required this.scriptSrc,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.autoReload = true,
  }) : super(key: key);

  @override
  State<NativeBannerWidget> createState() => _NativeBannerWidgetState();
}

class _NativeBannerWidgetState extends State<NativeBannerWidget> with WidgetsBindingObserver {
  late final String viewType;
  bool _isLoading = true;
  bool _hasError = false;
  html.DivElement? _container;
  Function? _reloadFunction;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    viewType = 'native-banner-${widget.containerId}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadFunction = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.autoReload && _isInitialized) {
      _reloadBanner();
    }
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      _container = html.DivElement()
        ..id = widget.containerId
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px'
        ..style.backgroundColor = '#f8f9fa'
        ..style.border = '1px solid #e9ecef'
        ..style.borderRadius = '8px'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.position = 'relative'
        ..style.overflow = 'hidden';

      // Add loading indicator
      final loadingDiv = html.DivElement()
        ..innerText = 'Loading ad...'
        ..style.textAlign = 'center'
        ..style.fontFamily = 'Arial, sans-serif'
        ..style.fontSize = '14px'
        ..style.color = '#6c757d';
      _container!.append(loadingDiv);

      // Check if script already exists in document
      final existingScript = html.document.querySelector('script[src="${widget.scriptSrc}"]');
      
      if (existingScript != null) {
        // Script already loaded, just wait for container to be ready
        _waitForReloadFunction(loadingDiv);
      } else {
        // Create and inject the ad script
        final script = html.ScriptElement()
          ..async = true
          ..setAttribute('data-cfasync', 'false')
          ..src = widget.scriptSrc;

        // Handle script load success
        script.onLoad.listen((_) {
          _waitForReloadFunction(loadingDiv);
        });

        // Handle script load error
        script.onError.listen((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
          loadingDiv.innerText = 'Ad temporarily unavailable';
          loadingDiv.style.color = '#dc3545';
          loadingDiv.style.fontSize = '12px';
        });

        // Append script to document head
        html.document.head!.append(script);
      }

      return _container!;
    });
  }

  void _waitForReloadFunction(html.DivElement loadingDiv) {
    int attempts = 0;
    const maxAttempts = 100; // 10 seconds with 100ms intervals

    void checkReloadFunction() {
      attempts++;
      
      if (_container != null) {
        // Try to get reload function from the container
        try {
          final jsContainer = js.JsObject.fromBrowserObject(_container!);
          if (jsContainer.hasProperty('reload')) {
            _reloadFunction = () {
              jsContainer.callMethod('reload');
            };
            
            if (mounted) {
              setState(() {
                _isLoading = false;
                _isInitialized = true;
              });
            }
            
            // Remove loading div if it still exists
            if (_container!.contains(loadingDiv)) {
              loadingDiv.remove();
            }
            
            print('Native banner reload function initialized for ${widget.containerId}');
            return;
          }
        } catch (e) {
          // Continue checking
        }
      }

      if (attempts < maxAttempts) {
        Future.delayed(const Duration(milliseconds: 100), checkReloadFunction);
      } else {
        // Timeout reached
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
        loadingDiv.innerText = 'Ad temporarily unavailable';
        loadingDiv.style.color = '#dc3545';
        loadingDiv.style.fontSize = '12px';
      }
    }

    // Start checking
    Future.delayed(const Duration(milliseconds: 100), checkReloadFunction);
  }

  void _reloadBanner() {
    if (_reloadFunction != null) {
      try {
        _reloadFunction!();
        print('Native banner reloaded: ${widget.containerId}');
      } catch (e) {
        print('Error reloading native banner: $e');
        
        // Try to re-acquire reload function
        _waitForReloadFunction(html.DivElement());
      }
    } else {
      print('Reload function not available for ${widget.containerId}');
    }
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          if (_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ad temporarily unavailable',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Public method to manually reload the banner
  void reload() {
    _reloadBanner();
  }
}

// Example usage widget
class NativeBannerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const NativeBannerWidget(
      adKey: 'e1bd304e9b4f790ab61f30e117275a37',
      containerId: 'container-e1bd304e9b4f790ab61f30e117275a37',
      scriptSrc: '//pl27139224.profitableratecpm.com/e1bd304e9b4f790ab61f30e117275a37/invoke.js',
      width: 300,
      height: 250,
    );
  }
}