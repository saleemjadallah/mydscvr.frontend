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
  final GlobalKey _placeholderKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _adContainerId = 'ts_ad_${DateTime.now().millisecondsSinceEpoch}';
    
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _injectAd();
        _positionAd();
        _setupScrollListener();
      });
    }
  }
  
  void _setupScrollListener() {
    // Update ad position on scroll
    html.window.addEventListener('scroll', (_) {
      _positionAd();
    });
    
    // Also update on resize
    html.window.addEventListener('resize', (_) {
      _positionAd();
    });
  }
  
  void _positionAd() {
    // Position the ad to match the placeholder
    if (!mounted) return;
    
    try {
      final RenderBox? renderBox = _placeholderKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final scrollY = html.window.scrollY ?? 0;
        final absoluteTop = position.dy + scrollY;
        
        final adContainer = html.document.getElementById('traffic-stars-container-${_adContainerId}');
        if (adContainer != null) {
          adContainer.style.position = 'absolute';
          adContainer.style.top = '${absoluteTop}px';
          adContainer.style.left = '0';
          adContainer.style.right = '0';
          adContainer.style.margin = '0 auto';
          adContainer.style.width = '100%';
          adContainer.style.maxWidth = '468px';
          adContainer.style.zIndex = '1000';
        }
      }
    } catch (e) {
      print('Error positioning ad: $e');
    }
  }
  
  void _injectAd() {
    try {
      // Find Flutter's root element
      final flutterView = html.document.querySelector('flt-glass-pane') ?? 
                        html.document.querySelector('flutter-view') ?? 
                        html.document.body;
      
      if (flutterView == null) return;
      
      // Create ad container with minimal styling
      final adContainer = html.DivElement()
        ..id = 'traffic-stars-container-${_adContainerId}'
        ..style.cssText = '''
          width: 316px;
          height: 266px;
          margin: 0 auto;
          padding: 8px;
          background-color: #ffffff;
          border-radius: 8px;
          border: 1px solid #e1e5e9;
          position: fixed;
          z-index: 1000;
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
        ..id = _adContainerId
        ..style.cssText = '''
          width: 300px;
          height: 250px;
          display: block;
          text-align: center;
        ''';
      
      adContainer.append(adSlot);
      
      // Add "Ads by TrafficStars" label
      final labelDiv = html.DivElement()
        ..style.cssText = 'font-size: 9px; color: #aaa; margin-top: 5px; text-align: right;'
        ..text = 'Ads by TrafficStars';
      adContainer.append(labelDiv);
      
      // Append to body
      html.document.body!.append(adContainer);
      
      // Load Traffic Stars banner script directly with data attributes
      final script = html.ScriptElement()
        ..src = '//cdn.runative-syndicate.com/sdk/v1/bi.js'
        ..setAttribute('data-ts-spot', widget.spotId)
        ..setAttribute('data-ts-width', '300')
        ..setAttribute('data-ts-height', '250')
        ..async = true
        ..defer = true;
      
      // Append script directly to the ad container
      adSlot.append(script);
    } catch (e) {
      print('Error injecting Traffic Stars ad: $e');
    }
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
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }
    
    // Create a placeholder that reserves space in Flutter's layout
    return Container(
      key: _placeholderKey,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional label
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748b),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Ads by TrafficStars',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94a3b8),
                    ),
                  ),
                ],
              ),
            ),
          
          // Placeholder space that will be replaced by the HTML ad
          Container(
            height: 250, // Banner ad height (300x250)
            width: 300, // Banner ad width
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'Ad loading...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 