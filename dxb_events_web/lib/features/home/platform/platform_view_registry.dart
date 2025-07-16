// Platform-specific imports for web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

void registerAdView(String viewId, String identifier) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) {
      // Create container div exactly like Vue example
      final container = html.DivElement()
        ..id = 'container-e1bd304e9b4f790ab61f30e117275a37-$identifier'
        ..style.width = '100%'
        ..style.height = '250px';
      
      // Store reload function reference
      var reloadFunction;
      
      // Create and append script
      final script = html.ScriptElement()
        ..async = true
        ..src = '//trotscheme.com/e1bd304e9b4f790ab61f30e117275a37/invoke.js'
        ..setAttribute('data-cfasync', 'false');
      
      // Handle script load event
      script.onLoad.listen((_) {
        // Check for reload function like Vue example
        html.window.setInterval(() {
          try {
            // Check if container has reload method
            final jsContainer = html.document.getElementById('container-e1bd304e9b4f790ab61f30e117275a37-$identifier');
            if (jsContainer != null) {
              // Try to access reload function
              final dynamic containerJs = jsContainer as dynamic;
              if (containerJs.reload != null) {
                reloadFunction = containerJs.reload;
                html.window.console.log('Ad reload function found for $identifier');
              }
            }
          } catch (e) {
            // Ignore errors while checking
          }
        }, 16);
      });
      
      // Append script to container
      container.append(script);
      
      return container;
    },
  );
}