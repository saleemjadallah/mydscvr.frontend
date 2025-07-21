import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html if (dart.library.io) 'dart:io';
import '../core/config/environment_config.dart';

/// Utility class for handling image URLs and loading
class ImageUtils {
  /// Get a safe image URL that avoids HTTP/2 errors and cache issues
  static String getSafeImageUrl(String? originalUrl, {String? eventId}) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return '';
    }
    
    var url = originalUrl;

    // Use CloudFront CDN for S3 images if available
    if (url.contains('mydscvr-event-images.s3') && url.contains('amazonaws.com')) {
      final cdnUrl = EnvironmentConfig.cdnUrl;
      // Use CDN if it's configured and contains cloudfront domain
      if (cdnUrl.isNotEmpty && cdnUrl.contains('cloudfront.net')) {
        // Extract the path after the bucket URL
        final regex = RegExp(r'https://mydscvr-event-images\.s3\.[^/]+\.amazonaws\.com/(.+)');
        final match = regex.firstMatch(url);
        if (match != null) {
          url = '$cdnUrl/${match.group(1)}';
          debugPrint('🌐 Using CloudFront CDN: $url');
        }
      } else {
        // Fallback to HTTPS for S3 URLs
        url = url.replaceAll('http://', 'https://');
      }
    } else if (url.contains('s3') && url.contains('amazonaws.com')) {
      // For other S3 URLs, ensure we're using HTTPS
      url = url.replaceAll('http://', 'https://');
    }
    
    // If it's a mydscvr.xyz URL, use the mydscvr.ai domain instead
    if (url.contains('mydscvr.xyz')) {
      url = url.replaceAll('mydscvr.xyz', 'mydscvr.ai');
    }

    // Add cache-busting query parameter for mobile web
    if (kIsWeb && _isMobileBrowser() && eventId != null) {
      final uri = Uri.parse(url);
      final queryParameters = Map<String, String>.from(uri.queryParameters);
      queryParameters['v'] = eventId;
      url = uri.replace(queryParameters: queryParameters).toString();
    }
    
    // Debug S3 URLs on mobile
    if (kIsWeb && _isMobileBrowser() && url.contains('s3') && url.contains('amazonaws.com')) {
      debugPrint('📱 MOBILE S3 IMAGE: $url');
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
    
    // Add headers for better mobile compatibility
    final headers = <String, String>{};
    if (kIsWeb) {
      headers['Accept'] = 'image/webp,image/apng,image/*,*/*;q=0.8';
      // Add no-cache headers for mobile to avoid stale images
      if (_isMobileBrowser()) {
        headers['Cache-Control'] = 'no-cache';
        headers['Pragma'] = 'no-cache';
        // Add CORS headers for S3 images on mobile
        headers['Origin'] = html.window.location.origin;
      }
    }
    
    return Image.network(
      safeUrl,
      width: width,
      height: height,
      fit: fit,
      headers: headers,
      errorBuilder: (context, error, stackTrace) {
        // Enhanced error logging for debugging
        if (kIsWeb) {
          final userAgent = _getUserAgent();
          final isMobile = _isMobileBrowser();
          debugPrint('===== Image Loading Error =====');
          debugPrint('Platform: ${isMobile ? "Mobile" : "Desktop"} Browser');
          debugPrint('User Agent: $userAgent');
          debugPrint('Error: $error');
          debugPrint('Original URL: $imageUrl');
          debugPrint('Safe URL: $safeUrl');
          debugPrint('==============================');
        } else {
          debugPrint('Image loading error: $error for URL: $safeUrl');
        }
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