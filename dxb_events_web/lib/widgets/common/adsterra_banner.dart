import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class AdsterraBanner extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const AdsterraBanner({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<AdsterraBanner> createState() => _AdsterraBannerState();
}

class _AdsterraBannerState extends State<AdsterraBanner> {
  late final String viewType;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    viewType = 'adsterra-banner-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final container = html.DivElement()
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px'
        ..style.backgroundColor = '#f8f9fa'
        ..style.border = '1px solid #e9ecef'
        ..style.borderRadius = '8px'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.fontFamily = 'Arial, sans-serif'
        ..style.fontSize = '14px'
        ..style.color = '#6c757d'
        ..style.position = 'relative'
        ..style.overflow = 'hidden';

      // Add loading indicator
      final loadingDiv = html.DivElement()
        ..innerText = 'Loading ad...'
        ..style.textAlign = 'center';
      container.append(loadingDiv);

      // Create and inject the ad script
      final script1 = html.ScriptElement()
        ..type = 'text/javascript'
        ..innerText = '''
          window.atOptions = {
            'key': '${widget.adKey}',
            'format': 'iframe',
            'height': ${widget.height.toInt()},
            'width': ${widget.width.toInt()},
            'params': {}
          };
        ''';

      final script2 = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = 'https://www.highperformanceformat.com/${widget.adKey}/invoke.js'
        ..async = true;

      // Handle script load success
      script2.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        loadingDiv.remove();
      });

      // Handle script load error
      script2.onError.listen((_) {
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

      // Set timeout for ad loading
      Future.delayed(const Duration(seconds: 10), () {
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

      // Append scripts to container
      container.append(script1);
      container.append(script2);

      return container;
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