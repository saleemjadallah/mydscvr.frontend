import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdsterraBanner extends StatefulWidget {
  final double height;
  final double width;
  final EdgeInsets margin;
  final String adKey;

  const AdsterraBanner({
    Key? key,
    this.height = 250,
    this.width = 300,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    required this.adKey,
  }) : super(key: key);

  @override
  _AdsterraBannerState createState() => _AdsterraBannerState();
}

class _AdsterraBannerState extends State<AdsterraBanner> {
  late final String viewType;

  @override
  void initState() {
    super.initState();
    viewType = 'adsterra-banner-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframeElement = html.IFrameElement()
        ..width = '${widget.width}'
        ..height = '${widget.height}'
        ..style.border = 'none'
        ..srcdoc = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { margin: 0; padding: 0; }
    </style>
</head>
<body>
    <script type="text/javascript">
        atOptions = {
            'key' : '${widget.adKey}',
            'format' : 'iframe',
            'height' : ${widget.height},
            'width' : ${widget.width},
            'params' : {}
        };
    </script>
    <script type="text/javascript" src="//www.highperformanceformat.com/${widget.adKey}/invoke.js"></script>
</body>
</html>
        ''';

      return iframeElement;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              'This is an Ad. Please scroll to proceed with content',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF666666),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              child: HtmlElementView(
                viewType: viewType,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 