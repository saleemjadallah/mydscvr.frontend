import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

/// Simple Traffic Stars ad that injects directly into the DOM
class TrafficStarsSimpleAd extends StatefulWidget {
  final String spotId;
  final String? title;
  
  const TrafficStarsSimpleAd({
    super.key,
    required this.spotId,
    this.title,
  });

  @override
  State<TrafficStarsSimpleAd> createState() => _TrafficStarsSimpleAdState();
}

class _TrafficStarsSimpleAdState extends State<TrafficStarsSimpleAd> {
  late String _adContainerId;
  
  @override
  void initState() {
    super.initState();
    _adContainerId = 'ts_ad_${DateTime.now().millisecondsSinceEpoch}';
    
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _injectAd();
      });
    }
  }
  
  void _injectAd() {
    try {
      // Find Flutter's root element
      final flutterView = html.document.querySelector('flt-glass-pane') ?? 
                        html.document.querySelector('flutter-view') ?? 
                        html.document.body;
      
      if (flutterView == null) return;
      
      // Create ad container
      final adContainer = html.DivElement()
        ..id = 'traffic-stars-container-${_adContainerId}'
        ..style.cssText = '''
          width: 100%;
          max-width: 1200px;
          margin: 20px auto;
          padding: 20px;
          background-color: #ffffff;
          border-radius: 12px;
          border: 1px solid #e1e5e9;
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
          position: relative;
          z-index: 10;
        ''';
      
      // Add title if provided
      if (widget.title != null) {
        final titleDiv = html.DivElement()
          ..style.cssText = 'font-size: 10px; color: #888; margin-bottom: 5px;'
          ..text = widget.title!;
        adContainer.append(titleDiv);
      }
      
      // Create ad slot
      final adSlot = html.DivElement()
        ..id = _adContainerId;
      
      adContainer.append(adSlot);
      
      // Add "Ads by TrafficStars" label
      final labelDiv = html.DivElement()
        ..style.cssText = 'font-size: 9px; color: #aaa; margin-top: 5px; text-align: right;'
        ..text = 'Ads by TrafficStars';
      adContainer.append(labelDiv);
      
      // Append to body
      html.document.body!.append(adContainer);
      
      // Load Traffic Stars script if not already loaded
      if (html.document.querySelector('script[src*="runative-syndicate.com"]') == null) {
        final script = html.ScriptElement()
          ..src = '//cdn.runative-syndicate.com/sdk/v1/n.js'
          ..async = true;
        
        script.onLoad.listen((_) {
          _initializeAd();
        });
        
        html.document.head!.append(script);
      } else {
        // Script already loaded, initialize immediately
        _initializeAd();
      }
    } catch (e) {
      print('Error injecting Traffic Stars ad: $e');
    }
  }
  
  void _initializeAd() {
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final initScript = html.ScriptElement()
          ..text = '''
            if (typeof NativeAd !== 'undefined') {
              new NativeAd({
                element_id: "$_adContainerId",
                spot: "${widget.spotId}",
                type: "label-under",
                cols: 1,
                rows: 1,
                title: "",
                titlePosition: "left",
                adsByPosition: "bottom-right"
              });
              console.log('Traffic Stars ad initialized: $_adContainerId');
            }
          ''';
        
        html.document.head!.append(initScript);
      } catch (e) {
        print('Error initializing Traffic Stars ad: $e');
      }
    });
  }
  
  @override
  void dispose() {
    // Clean up the ad container when widget is disposed
    if (kIsWeb) {
      final container = html.document.getElementById('traffic-stars-container-${_adContainerId}');
      container?.remove();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Return empty container - ad is rendered outside Flutter
    return const SizedBox.shrink();
  }
} 