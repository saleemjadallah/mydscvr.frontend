import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;
import 'package:flutter/material.dart';

class NativeBannerSimpleFixed extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const NativeBannerSimpleFixed({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<NativeBannerSimpleFixed> createState() => _NativeBannerSimpleFixedState();
}

class _NativeBannerSimpleFixedState extends State<NativeBannerSimpleFixed> {
  late final String viewType;
  late final String containerId;
  html.DivElement? _container;
  bool _isLoading = true;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    containerId = 'container-${widget.adKey}';
    viewType = 'native-banner-simple-fixed-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  void _updateStatus(String status) {
    setState(() {
      _status = status;
    });
    print('NativeBannerSimpleFixed: $status');
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      _container = html.DivElement()
        ..id = containerId
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px'
        ..style.position = 'relative'
        ..style.backgroundColor = '#f9f9f9';

      // Add loading indicator
      _container!.innerHtml = '''
        <div style="display:flex;align-items:center;justify-content:center;height:100%;font-family:Arial,sans-serif;color:#666;">
          <div style="text-align:center;">
            <div>Loading ad...</div>
            <div style="font-size:12px;margin-top:5px;">${widget.adKey}</div>
          </div>
        </div>
      ''';

      // Load the ad after a short delay
      Future.delayed(const Duration(milliseconds: 100), _loadAd);

      return _container!;
    });
  }

  void _loadAd() {
    if (_container == null) return;

    _updateStatus('Loading ad script...');

    // Create the script directly
    final script = html.ScriptElement()
      ..async = true
      ..setAttribute('data-cfasync', 'false')
      ..src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js?t=${DateTime.now().millisecondsSinceEpoch}';

    script.onLoad.listen((_) {
      _updateStatus('Script loaded successfully');
      setState(() {
        _isLoading = false;
      });

      // Check for reload function after delay
      Future.delayed(const Duration(seconds: 1), () {
        _checkReloadFunction();
      });
    });

    script.onError.listen((error) {
      _updateStatus('Script load error: $error');
      setState(() {
        _isLoading = false;
      });
      
      // Show error in container
      if (_container != null) {
        _container!.innerHtml = '''
          <div style="display:flex;align-items:center;justify-content:center;height:100%;font-family:Arial,sans-serif;">
            <div style="text-align:center;">
              <div style="color:#dc3545;font-size:14px;">Ad temporarily unavailable</div>
              <div style="color:#666;font-size:12px;margin-top:5px;">Error loading script</div>
              <div style="color:#666;font-size:10px;margin-top:5px;">${widget.adKey}</div>
            </div>
          </div>
        ''';
      }
    });

    // Append script to the container (following Vue example)
    _container!.append(script);
  }

  void _checkReloadFunction() {
    try {
      final hasReload = js.context.callMethod('eval', ['''
        (function() {
          var container = document.getElementById('$containerId');
          if (container && container.reload) {
            window['__reload_${widget.adKey}'] = function() {
              container.reload();
              console.log('Reload function stored for ${widget.adKey}');
            };
            return true;
          }
          return false;
        })()
      ''']);

      if (hasReload == true) {
        _updateStatus('Reload function found and stored');
      } else {
        _updateStatus('No reload function available');
      }
    } catch (e) {
      _updateStatus('Error checking reload: $e');
    }
  }

  void reload() {
    _updateStatus('Attempting reload...');
    
    try {
      js.context.callMethod('eval', ['''
        if (window['__reload_${widget.adKey}']) {
          window['__reload_${widget.adKey}']();
          console.log('Reload called for ${widget.adKey}');
        } else {
          console.log('No reload function stored for ${widget.adKey}');
        }
      ''']);
    } catch (e) {
      _updateStatus('Reload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height + 30, // Extra height for status
      child: Column(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: HtmlElementView(viewType: viewType),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _status,
              style: TextStyle(
                fontSize: 10,
                color: _isLoading ? Colors.blue : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}