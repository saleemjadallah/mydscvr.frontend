import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AdsterraWebBanner extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const AdsterraWebBanner({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<AdsterraWebBanner> createState() => _AdsterraWebBannerState();
}

class _AdsterraWebBannerState extends State<AdsterraWebBanner> {
  late final String viewType;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    viewType = 'adsterra-web-banner-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
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
        ..style.left = '8px'
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
        ..style.color = '#666666';

      container.append(adLabel);
      container.append(loadingDiv);

      // Set up ad loading timeout
      _loadingTimer = Timer(const Duration(seconds: 8), () {
        if (container.children.contains(loadingDiv)) {
          loadingDiv.innerText = 'Ad temporarily unavailable';
          loadingDiv.style.color = '#dc3545';
          loadingDiv.style.fontSize = '12px';
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        }
      });

      // Create script elements
      _injectAdScript(container, loadingDiv, viewId);

      return container;
    });
  }

  void _injectAdScript(html.DivElement container, html.DivElement loadingDiv, int viewId) {
    try {
      // Create script to set atOptions (using exact user-provided format)
      final optionsScript = html.ScriptElement()
        ..type = 'text/javascript'
        ..text = '''
          atOptions = {
              'key' : '${widget.adKey}',
              'format' : 'iframe',
              'height' : ${widget.height.toInt()},
              'width' : ${widget.width.toInt()},
              'params' : {}
          };
        ''';

      // Create the ad script (using protocol-relative URL as provided)
      final adScript = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = '//www.highperformanceformat.com/${widget.adKey}/invoke.js';

      // Handle successful script load
      adScript.onLoad.listen((_) {
        _loadingTimer?.cancel();
        loadingDiv.style.display = 'none';
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
        }
      });

      // Handle script load error
      adScript.onError.listen((_) {
        _loadingTimer?.cancel();
        loadingDiv.innerText = 'Ad temporarily unavailable';
        loadingDiv.style.color = '#dc3545';
        loadingDiv.style.fontSize = '12px';
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      // Append scripts to container instead of document head for better isolation
      container.append(optionsScript);
      container.append(adScript);

    } catch (e) {
      print('Error injecting ad script: $e');
      loadingDiv.innerText = 'Ad temporarily unavailable';
      loadingDiv.style.color = '#dc3545';
      loadingDiv.style.fontSize = '12px';
      
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