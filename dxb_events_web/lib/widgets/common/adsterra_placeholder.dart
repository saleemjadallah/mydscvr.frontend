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
    viewType = 'adsterra-banner-${widget.adKey}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final adContainer = html.DivElement()
        ..id = 'adsterra-container-${widget.adKey}'
        ..style.width = '100%'
        ..style.height = '100%';

      final script1 = html.ScriptElement()
        ..type = 'text/javascript'
        ..innerHtml = """
          atOptions = {
            'key' : '${widget.adKey}',
            'format' : 'iframe',
            'height' : ${widget.height},
            'width' : ${widget.width},
            'params' : {}
          };
        """;

      final script2 = html.ScriptElement()
        ..type = 'text/javascript'
        ..src = '//www.highperformanceformat.com/${widget.adKey}/invoke.js';

      adContainer.children.addAll([script1, script2]);
      return adContainer;
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
            width: widget.width,
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
            child: HtmlElementView(
              viewType: viewType,
            ),
          ),
        ],
      ),
    );
  }
} 