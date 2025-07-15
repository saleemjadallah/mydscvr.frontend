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
      final iframe = html.IFrameElement()
        ..width = '${widget.width}'
        ..height = '${widget.height}'
        ..src = '/adsterra_ad.html' // Absolute path from web root
        ..style.border = 'none'
        ..style.pointerEvents = 'none'; // Disable pointer events by default

      // Add sandbox attributes to allow the ad script to run correctly
      iframe.sandbox?.add('allow-scripts');
      iframe.sandbox?.add('allow-same-origin');
      iframe.sandbox?.add('allow-forms');
      iframe.sandbox?.add('allow-popups');
      iframe.sandbox?.add('allow-popups-to-escape-sandbox');
      iframe.sandbox?.add('allow-top-navigation');
      iframe.sandbox?.add('allow-top-navigation-by-user-activation');

      // Toggle pointer events on hover to allow both scrolling and clicking
      iframe.onMouseEnter.listen((_) => iframe.style.pointerEvents = 'auto');
      iframe.onMouseLeave.listen((_) => iframe.style.pointerEvents = 'none');

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(
        viewType: viewType,
      ),
    );
  }
} 