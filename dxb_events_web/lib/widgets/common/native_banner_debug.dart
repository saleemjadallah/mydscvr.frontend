import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'package:flutter/material.dart';

class NativeBannerDebug extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;

  const NativeBannerDebug({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
  }) : super(key: key);

  @override
  State<NativeBannerDebug> createState() => _NativeBannerDebugState();
}

class _NativeBannerDebugState extends State<NativeBannerDebug> {
  late final String viewType;
  final List<String> _logs = [];
  Timer? _debugTimer;

  @override
  void initState() {
    super.initState();
    viewType = 'native-banner-debug-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  @override
  void dispose() {
    _debugTimer?.cancel();
    super.dispose();
  }

  void _log(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toIso8601String()}] $message');
      if (_logs.length > 20) _logs.removeAt(0);
    });
    print('NativeBannerDebug: $message');
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final container = html.DivElement()
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px'
        ..style.position = 'relative'
        ..style.backgroundColor = '#f0f0f0';

      // Create debug UI
      final debugInfo = html.DivElement()
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.right = '0'
        ..style.backgroundColor = 'rgba(0,0,0,0.8)'
        ..style.color = 'white'
        ..style.padding = '5px'
        ..style.fontSize = '10px'
        ..style.zIndex = '1000'
        ..style.maxWidth = '200px'
        ..style.maxHeight = '100px'
        ..style.overflow = 'auto'
        ..id = 'debug-info-${widget.adKey}';

      container.append(debugInfo);

      // Create ad container
      final adContainer = html.DivElement()
        ..id = 'container-${widget.adKey}'
        ..style.width = '100%'
        ..style.height = '100%';

      container.append(adContainer);

      _log('Container created');

      // Try multiple approaches
      _tryMultipleApproaches(adContainer, debugInfo);

      return container;
    });
  }

  void _tryMultipleApproaches(html.DivElement adContainer, html.DivElement debugInfo) {
    _log('Starting ad load attempts...');

    // Approach 1: Direct script injection
    final script = html.ScriptElement()
      ..async = true
      ..src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js';

    script.onLoad.listen((_) {
      _log('Script loaded successfully');
      _startDebugging(adContainer, debugInfo);
    });

    script.onError.listen((error) {
      _log('Script load error: $error');
      
      // Try alternative URLs
      _tryAlternativeUrls(adContainer);
    });

    adContainer.append(script);
  }

  void _tryAlternativeUrls(html.DivElement adContainer) {
    final urls = [
      '//www.topcreativeformat.com/${widget.adKey}/invoke.js',
      '//pl15015147.pvclouds.com/${widget.adKey}/invoke.js',
      '//www.integratedadvertising.top/${widget.adKey}/invoke.js',
    ];

    for (final url in urls) {
      _log('Trying URL: $url');
      
      final testScript = html.ScriptElement()
        ..async = true
        ..src = url;

      testScript.onLoad.listen((_) {
        _log('Success with URL: $url');
      });

      testScript.onError.listen((_) {
        _log('Failed URL: $url');
      });

      html.document.head!.append(testScript);
    }
  }

  void _startDebugging(html.DivElement adContainer, html.DivElement debugInfo) {
    _debugTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final info = <String>[];
      
      // Check for reload function
      try {
        final hasReload = html.window.context.callMethod('eval', [
          'document.getElementById("container-${widget.adKey}") && document.getElementById("container-${widget.adKey}").reload ? true : false'
        ]);
        info.add('Has reload: $hasReload');
      } catch (e) {
        info.add('Reload check error: $e');
      }

      // Check for iframes
      final iframes = adContainer.querySelectorAll('iframe');
      info.add('Iframes: ${iframes.length}');

      // Check for scripts
      final scripts = adContainer.querySelectorAll('script');
      info.add('Scripts: ${scripts.length}');

      // Check container properties
      try {
        final props = html.window.context.callMethod('eval', ['''
          (function() {
            var container = document.getElementById("container-${widget.adKey}");
            if (!container) return "No container";
            var props = [];
            for (var prop in container) {
              if (typeof container[prop] === 'function' && prop.includes('load')) {
                props.push(prop);
              }
            }
            return props.join(', ');
          })()
        ''']);
        info.add('Load functions: $props');
      } catch (e) {
        info.add('Props error: $e');
      }

      debugInfo.innerHtml = info.join('<br>');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: HtmlElementView(viewType: viewType),
        ),
        const SizedBox(height: 10),
        Container(
          width: widget.width,
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListView.builder(
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              return Text(
                _logs[index],
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}