import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AdsterraWorkingBanner extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const AdsterraWorkingBanner({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<AdsterraWorkingBanner> createState() => _AdsterraWorkingBannerState();
}

class _AdsterraWorkingBannerState extends State<AdsterraWorkingBanner> {
  late final String viewType;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    viewType = 'adsterra-working-banner-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
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
      // Create iframe element directly - this avoids Flutter's HTML sanitization
      final iframe = html.IFrameElement()
        ..width = widget.width.toString()
        ..height = widget.height.toString()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;

      // Create the HTML content for the iframe
      final adHtml = '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { 
            margin: 0; 
            padding: 0; 
            width: 100%; 
            height: 100%; 
            overflow: hidden;
        }
        .ad-label {
            position: absolute;
            top: 4px;
            right: 8px;
            font-size: 10px;
            color: #999999;
            background-color: #f5f5f5;
            padding: 2px 6px;
            border-radius: 4px;
            z-index: 10;
            font-family: Arial, sans-serif;
        }
        .loading {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            font-family: Arial, sans-serif;
            color: #666666;
        }
    </style>
</head>
<body>
    <div class="ad-label">Advertisement</div>
    <div id="loading" class="loading">Loading ad...</div>
    
    <script type="text/javascript">
        atOptions = {
            'key' : '${widget.adKey}',
            'format' : 'iframe',
            'height' : ${widget.height.toInt()},
            'width' : ${widget.width.toInt()},
            'params' : {}
        };
        
        // Hide loading after script loads or on timeout
        setTimeout(function() {
            var loading = document.getElementById('loading');
            if (loading) {
                loading.style.display = 'none';
            }
        }, 3000);
    </script>
    <script type="text/javascript" src="//www.highperformanceformat.com/${widget.adKey}/invoke.js"></script>
</body>
</html>
      ''';

      // Set the iframe src to a data URL
      iframe.src = 'data:text/html;charset=utf-8,' + Uri.encodeComponent(adHtml);

      // Set timeout for loading state
      _loadingTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      // Listen for iframe load
      iframe.onLoad.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
        }
      });

      // Listen for iframe error
      iframe.onError.listen((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      return iframe;
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
                child: CircularProgressIndicator(),
              ),
            ),
          if (_hasError)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Ad temporarily unavailable',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}