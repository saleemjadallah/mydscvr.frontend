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
      final adContainer = html.DivElement();

      final adOptionsScript = html.ScriptElement()
        ..type = 'text/javascript'
        ..text = '''
          window.atOptions = {
            'key' : '${widget.adKey}',
            'format' : 'iframe',
            'height' : ${widget.height},
            'width' : ${widget.width},
            'params' : {}
          };
        ''';

      final adScript = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = '//www.highperformanceformat.com/${widget.adKey}/invoke.js';

      adContainer.children.addAll([adOptionsScript, adScript]);

      return adContainer;
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