import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;

/// Ad placeholder widget with Google AdSense integration
class AdPlaceholder extends StatefulWidget {
  final String adSlot;
  final double height;
  final EdgeInsets margin;

  const AdPlaceholder({
    Key? key,
    required this.adSlot,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<AdPlaceholder> createState() => _AdPlaceholderState();
}

class _AdPlaceholderState extends State<AdPlaceholder> {
  @override
  void initState() {
    super.initState();
    // Initialize AdSense when widget is created
    _initializeAd();
  }

  void _initializeAd() {
    // Wait for next frame to ensure DOM is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Push ad to AdSense queue
        html.window.eval('(adsbygoogle = window.adsbygoogle || []).push({});');
      } catch (e) {
        print('AdSense initialization error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        children: [
          // Header text
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
          
          // Ad container
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
              child: _buildAdContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdContent() {
    // Create the AdSense HTML structure
    return html.DivElement()
      ..innerHTML = '''
        <ins class="adsbygoogle"
             style="display:block; width:100%; height:${widget.height}px;"
             data-ad-client="ca-pub-2361005033053502"
             data-ad-slot="${widget.adSlot}"
             data-ad-format="auto"
             data-full-width-responsive="true"></ins>
        <script>
             (adsbygoogle = window.adsbygoogle || []).push({});
        </script>
      ''' as Widget;
  }
}

/// Simple fallback ad placeholder for development/testing
class SimpleAdPlaceholder extends StatelessWidget {
  final double height;
  final EdgeInsets margin;

  const SimpleAdPlaceholder({
    Key? key,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        children: [
          // Header text
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
          
          // Ad container
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[100],
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.ad_units,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Advertisement Space',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      'Google AdSense - Slot: 2625901948',
                      style: GoogleFonts.mono(
                        fontSize: 10,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}