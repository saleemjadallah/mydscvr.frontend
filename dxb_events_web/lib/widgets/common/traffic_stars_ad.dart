import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class TrafficStarsAd extends StatefulWidget {
  final String? title;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;
  final bool showLabel;

  const TrafficStarsAd({
    super.key,
    this.title,
    this.margin,
    this.padding,
    this.height,
    this.showLabel = true,
  });

  @override
  State<TrafficStarsAd> createState() => _TrafficStarsAdState();
}

class _TrafficStarsAdState extends State<TrafficStarsAd> {
  String? _adViewType;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeAd();
    }
  }

  void _initializeAd() {
    try {
      // Create unique view type for this ad instance
      _adViewType = 'traffic-stars-ad-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create the ad container HTML element
      final adElement = html.DivElement()
        ..id = 'ts_ad_native_${DateTime.now().millisecondsSinceEpoch}'
        ..style.width = '100%'
        ..style.height = '${widget.height ?? 80}px'
        ..style.backgroundColor = '#f8fafc'
        ..style.borderRadius = '12px'
        ..style.border = '1px solid #e2e8f0'
        ..style.overflow = 'hidden'
        ..style.position = 'relative'
        ..innerHtml = '''
          <div id="ts_ad_native_dizsj" style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;">
            <div style="text-align: center; color: #64748b; font-family: 'Inter', sans-serif; font-size: 12px;">
              Loading ads...
            </div>
          </div>
        ''';

      // Register the element with Flutter's platform view registry
      ui.platformViewRegistry.registerViewFactory(_adViewType!, (int viewId) {
        return adElement;
      });

      // Load the Traffic Stars script and initialize ad
      _loadTrafficStarsScript();
    } catch (e) {
      print('Error initializing Traffic Stars ad: $e');
    }
  }

  void _loadTrafficStarsScript() {
    try {
      // Check if script is already loaded
      if (html.document.querySelector('script[src*="runative-syndicate.com"]') != null) {
        _initializeTrafficStarsAd();
        return;
      }

      // Create and load the script
      final script = html.ScriptElement()
        ..src = '//cdn.runative-syndicate.com/sdk/v1/n.js'
        ..async = true;

      script.onLoad.listen((_) {
        print('Traffic Stars script loaded successfully');
        _initializeTrafficStarsAd();
      });

      script.onError.listen((_) {
        print('Failed to load Traffic Stars script');
        setState(() {
          _isAdLoaded = false;
        });
      });

      html.document.head!.append(script);
    } catch (e) {
      print('Error loading Traffic Stars script: $e');
    }
  }

  void _initializeTrafficStarsAd() {
    try {
      // Wait a bit for the ad container to be available in DOM
      Future.delayed(const Duration(milliseconds: 500), () {
        final initScript = html.ScriptElement()
          ..text = '''
            try {
              if (typeof NativeAd !== 'undefined') {
                console.log('Initializing Traffic Stars banner ad...');
                new NativeAd({
                  element_id: "ts_ad_native_dizsj",
                  spot: "761603040346483ea143d5f6b52b8959",
                  type: "label-under",
                  cols: 1,
                  rows: 1,
                  title: "",
                  titlePosition: "left",
                  adsByPosition: "bottom-right",
                  breakpoints: [
                    {
                      "cols": 1,
                      "width": 770
                    }
                  ],
                  styles: {
                    "image": {
                      "padding-bottom": "42px"
                    },
                    "label": {
                      "height": "42px"
                    },
                    "thumb": {
                      "margin-bottom": 0
                    },
                    "container": {
                      "width": "468px",
                      "height": "60px",
                      "overflow": "hidden"
                    },
                    "headlineLink": {
                      "font-size": "10px"
                    }
                  }
                });
                console.log('Traffic Stars banner ad initialized successfully');
              } else {
                console.log('NativeAd not available, retrying...');
                setTimeout(function() {
                  if (typeof NativeAd !== 'undefined') {
                    new NativeAd({
                      element_id: "ts_ad_native_dizsj",
                      spot: "761603040346483ea143d5f6b52b8959",
                      type: "label-under",
                      cols: 1,
                      rows: 1,
                      title: "",
                      titlePosition: "left",
                      adsByPosition: "bottom-right",
                      breakpoints: [
                        {
                          "cols": 1,
                          "width": 770
                        }
                      ],
                      styles: {
                        "image": {
                          "padding-bottom": "42px"
                        },
                        "label": {
                          "height": "42px"
                        },
                        "thumb": {
                          "margin-bottom": 0
                        },
                        "container": {
                          "width": "468px",
                          "height": "60px",
                          "overflow": "hidden"
                        },
                        "headlineLink": {
                          "font-size": "10px"
                        }
                      }
                    });
                  }
                }, 1000);
              }
            } catch (error) {
              console.error('Traffic Stars banner ad initialization error:', error);
            }
          ''';
        
        html.document.head!.append(initScript);
        
        setState(() {
          _isAdLoaded = true;
        });
      });
    } catch (e) {
      print('Error initializing Traffic Stars ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _adViewType == null) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      margin: widget.margin ?? EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional label
          if (widget.showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Sponsored',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748b),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ads by TrafficStars',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94a3b8),
                    ),
                  ),
                ],
              ),
            ),
          
          // Ad container
          Container(
            width: double.infinity,
            height: widget.height ?? (isMobile ? 60 : 60), // Banner ad is 60px height
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _isAdLoaded
                  ? HtmlElementView(viewType: _adViewType!)
                  : _buildLoadingPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF64748b).withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading ads...',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748b),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 