import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AdsterraBannerFixed extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const AdsterraBannerFixed({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<AdsterraBannerFixed> createState() => _AdsterraBannerFixedState();
}

class _AdsterraBannerFixedState extends State<AdsterraBannerFixed> {
  late final String viewType;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadingTimer;
  static bool _scriptLoaded = false;

  @override
  void initState() {
    super.initState();
    viewType = 'adsterra-banner-fixed-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _registerViewFactory();
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final container = html.DivElement()
        ..id = 'adsterra-container-$viewId'
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px'
        ..style.backgroundColor = '#ffffff'
        ..style.border = '1px solid #e0e0e0'
        ..style.borderRadius = '8px'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.fontFamily = 'Arial, sans-serif'
        ..style.fontSize = '14px'
        ..style.color = '#666666'
        ..style.position = 'relative'
        ..style.overflow = 'hidden';

      // Add ad label
      final adLabel = html.DivElement()
        ..innerText = 'Advertisement'
        ..style.position = 'absolute'
        ..style.top = '4px'
        ..style.right = '8px'
        ..style.fontSize = '10px'
        ..style.color = '#999999'
        ..style.backgroundColor = '#f5f5f5'
        ..style.padding = '2px 6px'
        ..style.borderRadius = '4px'
        ..style.zIndex = '10';

      // Add loading indicator
      final loadingDiv = html.DivElement()
        ..innerText = 'Loading ad...'
        ..style.textAlign = 'center'
        ..style.color = '#666666'
        ..id = 'loading-$viewId';

      container.append(adLabel);
      container.append(loadingDiv);

      // Create ad content div
      final adContentDiv = html.DivElement()
        ..id = 'ad-content-$viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center';

      container.append(adContentDiv);

      // Set timeout for loading
      _loadingTimer = Timer(const Duration(seconds: 10), () {
        final loading = html.document.getElementById('loading-$viewId');
        if (loading != null) {
          loading.innerText = 'Ad temporarily unavailable';
          loading.style.color = '#dc3545';
          loading.style.fontSize = '12px';
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        }
      });

      // Load ad script
      _loadAdScript(container, loadingDiv, adContentDiv, viewId);

      return container;
    });
  }

  void _loadAdScript(html.DivElement container, html.DivElement loadingDiv, 
                     html.DivElement adContentDiv, int viewId) {
    try {
      // Clear any existing atOptions
      html.window.setProperty('atOptions', null);
      
      // Set atOptions globally
      html.window.setProperty('atOptions', {
        'key': widget.adKey,
        'format': 'iframe',
        'height': widget.height.toInt(),
        'width': widget.width.toInt(),
        'params': {}
      });

      // Create a unique script element
      final script = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = '//www.highperformanceformat.com/${widget.adKey}/invoke.js'
        ..id = 'adsterra-script-$viewId';

      // Handle script load
      script.onLoad.listen((_) {
        _loadingTimer?.cancel();
        print('Adsterra script loaded for view $viewId');
        
        // Wait a bit for ad to render
        Timer(const Duration(milliseconds: 2000), () {
          final loading = html.document.getElementById('loading-$viewId');
          if (loading != null) {
            loading.style.display = 'none';
          }
          
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          }
        });
      });

      // Handle script error
      script.onError.listen((_) {
        _loadingTimer?.cancel();
        print('Adsterra script failed to load for view $viewId');
        
        final loading = html.document.getElementById('loading-$viewId');
        if (loading != null) {
          loading.innerText = 'Ad temporarily unavailable';
          loading.style.color = '#dc3545';
          loading.style.fontSize = '12px';
        }
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      // Add script to document head
      html.document.head?.append(script);

    } catch (e) {
      print('Error loading ad script: $e');
      _loadingTimer?.cancel();
      
      final loading = html.document.getElementById('loading-$viewId');
      if (loading != null) {
        loading.innerText = 'Ad temporarily unavailable';
        loading.style.color = '#dc3545';
        loading.style.fontSize = '12px';
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}