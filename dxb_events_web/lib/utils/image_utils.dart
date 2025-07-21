import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html if (dart.library.io) 'dart:io';
import '../core/config/environment_config.dart';

/// Utility class for handling image URLs and loading
class ImageUtils {
  static const String cloudinaryCloudName = 'dikjgzjsq';
  /// Get a safe image URL that avoids HTTP/2 errors and cache issues
  static String getSafeImageUrl(String? originalUrl, {String? eventId, bool? isThumbnail}) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return '';
    }
    
    debugPrint('🔍 getSafeImageUrl called with: $originalUrl');
    var url = originalUrl;
    
    // Check if this is already a Cloudinary URL
    if (url.contains('res.cloudinary.com')) {
      debugPrint('☁️ Already using Cloudinary: $url');
      // Add mobile optimizations for Cloudinary
      if (kIsWeb && _isMobileBrowser()) {
        // Add automatic format and quality for mobile
        if (!url.contains('/f_auto')) {
          url = url.replaceFirst('/upload/', '/upload/f_auto,q_auto/');
        }
        debugPrint('☁️ Optimized Cloudinary URL for mobile: $url');
      }
      return url;
    }

    // Convert S3 URLs to Cloudinary
    if (url.contains('mydscvr-event-images.s3') && url.contains('amazonaws.com')) {
      final regex = RegExp(r'https://mydscvr-event-images\.s3\.[^/]+\.amazonaws\.com/(.+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        final s3Path = match.group(1)!;
        // For mobile, use Cloudinary with automatic optimization
        if (kIsWeb && _isMobileBrowser()) {
          final encodedUrl = Uri.encodeComponent(originalUrl);
          url = 'https://res.cloudinary.com/$cloudinaryCloudName/image/fetch/f_auto,q_auto,w_800/$encodedUrl';
          debugPrint('☁️ Mobile: Converting S3 to Cloudinary with optimization: $url');
        } else {
          // For desktop, use higher quality
          final encodedUrl = Uri.encodeComponent(originalUrl);
          url = 'https://res.cloudinary.com/$cloudinaryCloudName/image/fetch/f_auto,q_90/$encodedUrl';
          debugPrint('☁️ Desktop: Converting S3 to Cloudinary: $url');
        }
      }
    } else if (url.contains('s3') && url.contains('amazonaws.com')) {
      // For other S3 URLs, also use Cloudinary fetch
      final encodedUrl = Uri.encodeComponent(url);
      if (kIsWeb && _isMobileBrowser()) {
        url = 'https://res.cloudinary.com/$cloudinaryCloudName/image/fetch/f_auto,q_auto,w_800/$encodedUrl';
      } else {
        url = 'https://res.cloudinary.com/$cloudinaryCloudName/image/fetch/f_auto,q_90/$encodedUrl';
      }
    }
    
    // If it's a mydscvr.xyz URL, use the mydscvr.ai domain instead
    if (url.contains('mydscvr.xyz')) {
      url = url.replaceAll('mydscvr.xyz', 'mydscvr.ai');
    }

    // NO QUERY PARAMETERS - Keep URLs simple
    // CloudFront already handles caching
    
    // Debug final URL on mobile
    if (kIsWeb && _isMobileBrowser()) {
      if (url.contains('cloudfront.net')) {
        debugPrint('🌐 MOBILE CLOUDFRONT IMAGE: $url');
      } else if (url.contains('s3') && url.contains('amazonaws.com')) {
        debugPrint('⚠️ MOBILE S3 IMAGE (not using CloudFront): $url');
      }
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
  
  
  /// Check if running on mobile browser
  static bool _isMobileBrowser() {
    if (!kIsWeb) return false;
    
    final userAgent = _getUserAgent().toLowerCase();
    return userAgent.contains('mobile') || 
           userAgent.contains('android') || 
           userAgent.contains('iphone') ||
           userAgent.contains('ipad');
  }
  
  /// Get user agent string
  static String _getUserAgent() {
    if (!kIsWeb) return '';
    
    try {
      return html.window.navigator.userAgent;
    } catch (e) {
      return '';
    }
  }
}