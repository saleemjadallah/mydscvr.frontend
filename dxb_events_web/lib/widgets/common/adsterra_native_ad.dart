import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'dart:js' as js;

class AdsterraNativeAd extends StatefulWidget {
  final String identifier;
  final Color? backgroundColor;
  
  const AdsterraNativeAd({
    Key? key,
    required this.identifier,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<AdsterraNativeAd> createState() => _AdsterraNativeAdState();
}

class _AdsterraNativeAdState extends State<AdsterraNativeAd> {
  late String viewId;
  
  @override
  void initState() {
    super.initState();
    viewId = 'adsterra-native-${widget.identifier}';
    
    if (kIsWeb) {
      _registerAdView();
    }
  }
  
  void _registerAdView() {
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) {
        // Get the pre-created container from HTML
        final containerId = 'flutter-ad-container-${widget.identifier}';
        final container = html.document.getElementById(containerId);
        
        if (container != null) {
          // Show the container
          container.style.display = 'block';
          
          // Initialize the ad script
          js.context.callMethod('initializeAdsterra', ['flutter-${widget.identifier}']);
          
          // Create a wrapper div to return
          final wrapper = html.DivElement()
            ..style.width = '100%'
            ..style.height = '250px';
          
          // Move the container content to the wrapper
          wrapper.append(container);
          
          return wrapper;
        }
        
        // Fallback if container not found
        return html.DivElement()
          ..text = 'Ad container not found'
          ..style.textAlign = 'center'
          ..style.padding = '20px';
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: double.infinity,
          height: 250,
          child: HtmlElementView(
            viewType: viewId,
          ),
        ),
      ),
    );
  }
}