import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AdsterraDirectBanner extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const AdsterraDirectBanner({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<AdsterraDirectBanner> createState() => _AdsterraDirectBannerState();
}

class _AdsterraDirectBannerState extends State<AdsterraDirectBanner> {
  late final String viewType;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    viewType = 'adsterra-direct-banner-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
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

      container.append(adLabel);

      // Inject the exact HTML as provided by user
      container.innerHtml = '''
        <div style="position: absolute; top: 4px; right: 8px; font-size: 10px; color: #999999; background-color: #f5f5f5; padding: 2px 6px; border-radius: 4px; z-index: 10;">Advertisement</div>
        <script type="text/javascript">
          atOptions = {
              'key' : '${widget.adKey}',
              'format' : 'iframe',
              'height' : ${widget.height.toInt()},
              'width' : ${widget.width.toInt()},
              'params' : {}
          };
        </script>
        <script type="text/javascript" src="//www.highperformanceformat.com/${widget.adKey}/invoke.js"></script>
      ''';

      // Set timeout for loading feedback
      _loadingTimer = Timer(const Duration(seconds: 8), () {
        // Check if ad loaded by looking for iframe or ad content
        final iframes = container.querySelectorAll('iframe');
        if (iframes.isEmpty) {
          container.innerHtml = '''
            <div style="position: absolute; top: 4px; right: 8px; font-size: 10px; color: #999999; background-color: #f5f5f5; padding: 2px 6px; border-radius: 4px; z-index: 10;">Advertisement</div>
            <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: #dc3545; font-size: 12px;">
              Ad temporarily unavailable
            </div>
          ''';
          
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          }
        }
      });

      return container;
    });
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