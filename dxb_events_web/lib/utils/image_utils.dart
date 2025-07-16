import 'package:flutter/material.dart';

/// Utility class for handling image URLs and loading
class ImageUtils {
  /// Get a safe image URL that avoids HTTP/2 errors
  static String getSafeImageUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return '';
    }
    
    // If it's a mydscvr.xyz URL, use the mydscvr.ai domain instead
    // This helps avoid HTTP/2 protocol errors
    if (originalUrl.contains('mydscvr.xyz')) {
      return originalUrl.replaceAll('mydscvr.xyz', 'mydscvr.ai');
    }
    
    return originalUrl;
  }
  
  /// Build an image widget with proper error handling
  static Widget buildNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    final safeUrl = getSafeImageUrl(imageUrl);
    
    if (safeUrl.isEmpty) {
      return errorWidget ?? _buildDefaultErrorWidget(width, height);
    }
    
    return Image.network(
      safeUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image loading error: $error for URL: $safeUrl');
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