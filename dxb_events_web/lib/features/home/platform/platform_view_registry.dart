// Platform-specific imports for web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

void registerAdView(String viewId, String identifier) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) {
      final container = html.DivElement()
        ..id = 'adsterra-container-$identifier'
        ..style.width = '100%'
        ..style.height = '250px'
        ..style.textAlign = 'center'
        ..style.padding = '10px'
        ..style.backgroundColor = '#f9f9f9';
      
      // Create the ad container div
      final adDiv = html.DivElement()
        ..id = 'container-e1bd304e9b4f790ab61f30e117275a37-$identifier';
      
      container.append(adDiv);
      
      // Create and inject the ad script
      final script = html.ScriptElement()
        ..async = true
        ..src = '//trotscheme.com/e1bd304e9b4f790ab61f30e117275a37/invoke.js'
        ..setAttribute('data-cfasync', 'false');
      
      container.append(script);
      
      // Reload ad when script loads
      script.onLoad.listen((_) {
        // Try to reload the ad after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          html.window.console.log('Adsterra ad loaded for $identifier');
        });
      });
      
      return container;
    },
  );
}