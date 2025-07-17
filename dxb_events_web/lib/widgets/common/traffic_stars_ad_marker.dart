import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:js' as js;

/// A marker widget that controls the positioning of external Traffic Stars ads
class TrafficStarsAdMarker extends StatefulWidget {
  final int slotNumber;
  final String? label;
  final EdgeInsets? margin;

  const TrafficStarsAdMarker({
    super.key,
    required this.slotNumber,
    this.label,
    this.margin,
  });

  @override
  State<TrafficStarsAdMarker> createState() => _TrafficStarsAdMarkerState();
}

class _TrafficStarsAdMarkerState extends State<TrafficStarsAdMarker> {
  final GlobalKey _markerKey = GlobalKey();
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Check visibility after frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateAdPosition();
      });
      
      // Listen to scroll events to update position
      _setupScrollListener();
    }
  }
  
  void _setupScrollListener() {
    // Add scroll listener to update ad position
    html.window.addEventListener('scroll', (_) {
      _updateAdPosition();
    });
  }
  
  void _updateAdPosition() {
    if (!mounted) return;
    
    try {
      final RenderBox? renderBox = _markerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        
        // Calculate position relative to viewport
        final scrollY = html.window.scrollY ?? 0;
        final absoluteTop = position.dy + scrollY;
        
        // Check if marker is in viewport
        final viewportHeight = html.window.innerHeight ?? 0;
        final isInViewport = position.dy >= -size.height && position.dy <= viewportHeight;
        
        // Call JavaScript function to position the ad
        js.context.callMethod('positionTrafficStarsAd', [
          widget.slotNumber,
          absoluteTop,
          isInViewport,
        ]);
        
        setState(() {
          _isVisible = isInViewport;
        });
      }
    } catch (e) {
      print('Error updating ad position: $e');
    }
  }
  
  @override
  void dispose() {
    // Hide ad when widget is disposed
    if (kIsWeb) {
      js.context.callMethod('positionTrafficStarsAd', [widget.slotNumber, 0, false]);
    }
    super.dispose();
  }
  
  bool _shouldShowAdSpace() {
    // Only show ad space if we're on web and ad might load
    // You can add additional logic here to check if ads are enabled
    return kIsWeb;
  }
  
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }
    
    return Container(
      key: _markerKey,
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional label
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    widget.label!,
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
          
          // Placeholder space for the ad - only show if ads are expected to load
          if (_shouldShowAdSpace())
            Container(
              height: 60, // Banner ad height
              width: double.infinity,
              color: Colors.transparent,
              child: const SizedBox.shrink(), // Empty space for ad
            ),
        ],
      ),
    );
  }
} 