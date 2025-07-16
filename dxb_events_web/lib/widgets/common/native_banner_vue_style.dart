import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class NativeBannerVueStyle extends StatefulWidget {
  final String adKey;
  final String containerId;
  final double width;
  final double height;
  final EdgeInsets margin;

  const NativeBannerVueStyle({
    Key? key,
    required this.adKey,
    required this.containerId,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<NativeBannerVueStyle> createState() => _NativeBannerVueStyleState();
}

class _NativeBannerVueStyleState extends State<NativeBannerVueStyle> with WidgetsBindingObserver {
  late final String viewType;
  bool _isInitialized = false;
  html.DivElement? _container;

  @override
  void initState() {
    super.initState();
    viewType = 'native-banner-vue-${widget.containerId}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized) {
      _callReloadFunction();
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
        ..style.position = 'relative'
        ..style.overflow = 'hidden';

      // Initialize the ad following Vue example pattern
      _initializeAd();

      return _container!;
    });
  }

  void _initializeAd() {
    // Check if reload function already exists (for navigation)
    final existingReload = html.window.localStorage['reload_${widget.adKey}'];
    if (existingReload != null) {
      _callReloadFunction();
    } else {
      // First time loading - inject script
      final script = html.ScriptElement()
        ..async = true
        ..src = _getAdScriptUrl();

      script.onLoad.listen((_) {
        // Poll for reload function like Vue example
        int attempts = 0;
        void checkReload() {
          attempts++;
          
          // Check if container has reload function
          final jsObject = html.JsObject.fromBrowserObject(_container!);
          if (jsObject.hasProperty('reload')) {
            // Store reload function reference
            html.window.localStorage['reload_${widget.adKey}'] = 'true';
            setState(() {
              _isInitialized = true;
            });
            print('Native banner initialized with reload function for ${widget.adKey}');
          } else if (attempts < 300) { // ~5 seconds at 16ms intervals
            Future.delayed(const Duration(milliseconds: 16), checkReload);
          }
        }
        
        Future.delayed(const Duration(milliseconds: 16), checkReload);
      });

      script.onError.listen((_) {
        print('Failed to load ad script for ${widget.adKey}');
      });

      // Append script to container like Vue example
      _container!.append(script);
    }
  }

  String _getAdScriptUrl() {
    // Try different URL patterns based on the ad key
    if (widget.adKey.startsWith('e1bd')) {
      return '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js';
    } else if (widget.adKey.length == 32) {
      // Standard format keys
      return '//www.topcreativeformat.com/${widget.adKey}/invoke.js';
    } else {
      // Fallback
      return '//pl15015147.pvclouds.com/${widget.adKey}/invoke.js';
    }
  }

  void _callReloadFunction() {
    if (_container != null) {
      try {
        final jsObject = html.JsObject.fromBrowserObject(_container!);
        if (jsObject.hasProperty('reload')) {
          jsObject.callMethod('reload');
          print('Native banner reloaded: ${widget.adKey}');
        }
      } catch (e) {
        print('Error calling reload: $e');
      }
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }

  // Public method for manual reload
  void reload() {
    _callReloadFunction();
  }
}