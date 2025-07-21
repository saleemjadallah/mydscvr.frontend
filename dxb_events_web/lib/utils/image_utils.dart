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
    
    debugPrint('🔍 getSafeImageUrl called with: $originalUrl');
    var url = originalUrl;

    // Use CloudFront CDN for S3 images if available
    if (url.contains('mydscvr-event-images.s3') && url.contains('amazonaws.com')) {
      final cdnUrl = EnvironmentConfig.cdnUrl;
      debugPrint('🔍 CDN URL from config: $cdnUrl');
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
        debugPrint('⚠️ Not using CloudFront - CDN URL check failed');
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

    // Add cache-busting query parameter for mobile web ONLY for S3 URLs
    // CloudFront handles caching properly, so we don't need it there
    if (kIsWeb && _isMobileBrowser() && eventId != null && !url.contains('cloudfront.net')) {
      final uri = Uri.parse(url);
      final queryParameters = Map<String, String>.from(uri.queryParameters);
      queryParameters['v'] = eventId;
      url = uri.replace(queryParameters: queryParameters).toString();
    }
    
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
    
    // Add headers for better mobile compatibility
    final headers = <String, String>{};
    if (kIsWeb) {
      // Simplified headers for better compatibility
      headers['Accept'] = 'image/*';
      
      // Only add Origin header for CORS
      if (_isMobileBrowser()) {
        headers['Origin'] = html.window.location.origin;
      }
    }
    
    debugPrint('🖼️ Image.network called with URL: $safeUrl');
    debugPrint('🖼️ Contains cloudfront.net: ${safeUrl.contains('cloudfront.net')}');
    
    // For mobile web with CloudFront, use simpler loading without headers
    if (kIsWeb && _isMobileBrowser() && safeUrl.contains('cloudfront.net')) {
      return Image.network(
        safeUrl,
        width: width,
        height: height,
        fit: fit,
        // No headers for CloudFront on mobile
        errorBuilder: (context, error, stackTrace) {
          debugPrint('🚨 Mobile CloudFront image error: $error');
          debugPrint('🚨 URL: $safeUrl');
          return errorWidget ?? _buildDefaultErrorWidget(width, height);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(width, height);
        },
      );
    }
    
    // Standard loading for desktop or S3 URLs
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
          debugPrint('Safe URL (actual used): $safeUrl');
          debugPrint('CDN URL: ${EnvironmentConfig.cdnUrl}');
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