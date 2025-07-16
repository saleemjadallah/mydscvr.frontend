import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

/// This widget creates the EXACT HTML structure as provided:
/// <script async="async" data-cfasync="false" src="//pl27139224.profitableratecpm.com/e1bd304e9b4f790ab61f30e117275a37/invoke.js"></script>
/// <div id="container-e1bd304e9b4f790ab61f30e117275a37"></div>
class NativeBannerExactHtml extends StatefulWidget {
  final String adKey;
  final double width;
  final double height;
  final EdgeInsets margin;

  const NativeBannerExactHtml({
    Key? key,
    required this.adKey,
    this.width = 300,
    this.height = 250,
    this.margin = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  }) : super(key: key);

  @override
  State<NativeBannerExactHtml> createState() => _NativeBannerExactHtmlState();
}

class _NativeBannerExactHtmlState extends State<NativeBannerExactHtml> {
  late final String viewType;
  
  @override
  void initState() {
    super.initState();
    viewType = 'native-banner-exact-html-${widget.adKey}-${DateTime.now().millisecondsSinceEpoch}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final wrapper = html.DivElement()
        ..style.width = '${widget.width}px'
        ..style.height = '${widget.height}px';

      // Create the EXACT container with the EXACT ID
      final container = html.DivElement()
        ..id = 'container-${widget.adKey}';
      
      // Create the script element with EXACT attributes
      final script = html.ScriptElement()
        ..async = true
        ..setAttribute('data-cfasync', 'false')
        ..src = '//pl27139224.profitableratecpm.com/${widget.adKey}/invoke.js';

      // Log events for debugging
      script.onLoad.listen((_) {
        print('NativeBannerExactHtml: Script loaded for ${widget.adKey}');
        
        // Check if reload function exists after a delay
        Future.delayed(const Duration(seconds: 2), () {
          _checkReloadFunction();
        });
      });

      script.onError.listen((error) {
        print('NativeBannerExactHtml: Script error for ${widget.adKey}: $error');
        container.innerHtml = '''
          <div style="text-align:center;padding:20px;color:#999;font-family:Arial,sans-serif;">
            <div>Ad unavailable</div>
            <div style="font-size:12px;margin-top:5px;">Script failed to load</div>
          </div>
        ''';
      });

      // Append in the EXACT order: container first, then script
      wrapper.append(container);
      wrapper.append(script);

      print('NativeBannerExactHtml: Created with container ID: container-${widget.adKey}');

      return wrapper;
    });
  }

  void _checkReloadFunction() {
    try {
      final hasReload = html.document.getElementById('container-${widget.adKey}');
      if (hasReload != null) {
        print('NativeBannerExactHtml: Container found for ${widget.adKey}');
        // Check if it has reload method using JavaScript
        final result = html.window.postMessage({
          'action': 'checkReload',
          'containerId': 'container-${widget.adKey}'
        }, '*');
      }
    } catch (e) {
      print('NativeBannerExactHtml: Error checking reload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}

// Test widget that uses the exact ad key from the HTML
class NativeBannerExactTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Exact HTML Structure Test', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        // Using the EXACT ad key from your HTML
        NativeBannerExactHtml(
          adKey: 'e1bd304e9b4f790ab61f30e117275a37',
        ),
      ],
    );
  }
}