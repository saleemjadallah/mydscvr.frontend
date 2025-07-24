import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../core/config/environment_config.dart';

/// Utility class for handling image URLs and loading
class ImageUtils {
  static const String cloudinaryCloudName = 'dikjgzjsq';
  
  /// Check if running on mobile browser
  static bool _isMobileBrowser() {
    if (!kIsWeb) return false;
    
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') || 
           userAgent.contains('android') || 
           userAgent.contains('iphone') ||
           userAgent.contains('ipad') ||
           userAgent.contains('ipod') ||
           userAgent.contains('opera mini') ||
           userAgent.contains('webos') ||
           userAgent.contains('windows phone');
  }
  
  /// Get a safe image URL that avoids HTTP/2 errors and cache issues
  static String getSafeImageUrl(String? originalUrl, {String? eventId}) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return '';
    }
    
    debugPrint('🔍 getSafeImageUrl called with: $originalUrl');
    var url = originalUrl;
    
    // Check if this is already a Cloudinary URL
    if (url.contains('res.cloudinary.com')) {
      debugPrint('☁️ Already using Cloudinary: $url');
      return url;
    }

    // Determine quality based on device
    final isMobile = _isMobileBrowser();
    final quality = isMobile ? 'q_auto:low' : 'q_90';
    final format = isMobile ? 'f_auto' : 'f_auto';
    final width = isMobile ? ',w_800' : ''; // Limit width on mobile
    
    debugPrint('📱 Device type: ${isMobile ? "Mobile" : "Desktop"}, Quality: $quality');
    
    // Convert S3 URLs to Cloudinary with appropriate quality settings
    if (url.contains('mydscvr-event-images.s3') && url.contains('amazonaws.com')) {
      final regex = RegExp(r'https://mydscvr-event-images\.s3\.[^/]+\.amazonaws\.com/(.+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final s3Path = match.group(1)!;
        // Use device-appropriate quality
        final encodedUrl = Uri.encodeComponent(originalUrl);
        url = 'https://res.cloudinary.com/$cloudinaryCloudName/image/fetch/$format,$quality$width/$encodedUrl';
        debugPrint('☁️ Converting S3 to Cloudinary: $url');
      }
    } else if (url.contains('s3') && url.contains('amazonaws.com')) {
      // For other S3 URLs, also use Cloudinary fetch with device-appropriate quality
      final encodedUrl = Uri.encodeComponent(url);
      url = 'https://res.cloudinary.com/$cloudinaryCloudName/image/fetch/$format,$quality$width/$encodedUrl';
    }
    
    // Don't add timestamp to Cloudinary URLs as it breaks their fetch functionality
    if (!url.contains('res.cloudinary.com')) {
      // Add cache-busting parameter only for non-Cloudinary URLs
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      url = '$url?t=$timestamp';
    }
    
    return url;
  }
  
  /// Build an image widget with proper error handling
  static Widget buildNetworkImage({
    required String imageUrl,
    String? eventId, // Add eventId for cache-busting
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    final safeUrl = getSafeImageUrl(imageUrl, eventId: eventId);
    
    if (safeUrl.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    }
    
    debugPrint('🖼️ Loading image: $safeUrl');
    
    // SIMPLE IMAGE LOADING - Just load the image, no complications
    return Image.network(
      safeUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Image failed: $error');
        debugPrint('❌ URL: $safeUrl');
        return errorWidget ?? _buildDefaultErrorWidget(width, height);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingWidget(width, height);
      },
    );
  }
  
  static Widget _buildDefaultErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade300,
            Colors.pink.shade300,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.white70,
        ),
      ),
    );
  }
  
  static Widget _buildLoadingWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}