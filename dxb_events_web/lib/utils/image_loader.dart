import 'package:flutter/material.dart';

/// Utility class for optimized image loading with HTTP/2 error handling
class ImageLoader {
  /// Load image with error handling and optimization
  static Widget loadNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Handle empty URLs
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildDefaultError(width, height);
    }
    
    // Optimize image URL if it's from our server
    final optimizedUrl = _optimizeImageUrl(imageUrl);
    
    return Image.network(
      optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      // Add headers to prevent HTTP/2 issues
      headers: const {
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Cache-Control': 'max-age=3600',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultPlaceholder(width, height);
      },
      errorBuilder: (context, error, stackTrace) {
        // Log error for debugging
        debugPrint('Image loading error: $error for URL: $optimizedUrl');
        return errorWidget ?? _buildDefaultError(width, height);
      },
    );
  }
  
  /// Optimize image URL for better loading
  static String _optimizeImageUrl(String url) {
    // If it's our server URL, add query parameters for optimization
    if (url.contains('mydscvr.xyz') || url.contains('mydscvr.ai')) {
      // Add cache busting and size hints
      final uri = Uri.parse(url);
      final params = Map<String, String>.from(uri.queryParameters);
      
      // Add optimization parameters
      params['opt'] = '1';  // Enable server-side optimization
      params['q'] = '85';   // Quality setting
      
      return uri.replace(queryParameters: params).toString();
    }
    
    return url;
  }
  
  /// Build default placeholder widget
  static Widget _buildDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }
  
  /// Build default error widget
  static Widget _buildDefaultError(double? width, double? height) {
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
  
  /// Preload images to avoid HTTP/2 errors during scrolling
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    final futures = imageUrls.map((url) {
      if (url.isNotEmpty) {
        final optimizedUrl = _optimizeImageUrl(url);
        return precacheImage(
          NetworkImage(
            optimizedUrl,
            headers: const {
              'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
              'Accept-Encoding': 'gzip, deflate, br',
            },
          ),
          context,
        ).catchError((error) {
          debugPrint('Failed to preload image: $url');
          return Future.value();
        });
      }
      return Future.value();
    }).toList();
    
    await Future.wait(futures);
  }
}