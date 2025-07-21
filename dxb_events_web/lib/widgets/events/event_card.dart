import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/event.dart';
import '../../utils/duration_formatter.dart';
import '../../utils/image_utils.dart';
import '../../core/config/environment_config.dart';
import 'event_actions.dart';

enum EventCardLayout { vertical, horizontal }

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isCompact;
  final EventCardLayout layout;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isCompact = false,
    this.layout = EventCardLayout.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (layout == EventCardLayout.horizontal) {
      return _buildHorizontalLayout(context);
    }
    return _buildVerticalLayout(context);
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        blur: 8,
        opacity: 0.05,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image - increased height for mobile
            _buildEventImage(),
            
            // Event details - more compact layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12), // Reduced padding from 16 to 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event title
                    Text(
                      event.title,
                      style: GoogleFonts.comfortaa(
                        fontSize: 15, // Slightly smaller
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4), // Reduced from 6
                    
                    // Event date and time
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatEventDate(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 2), // Reduced from 3
                    
                    // Venue location
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue.area,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Duration and experience metrics (like featured events)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 12,
                          color: AppColors.dubaiTeal,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${DurationFormatter.formatForDetails(event.startDate, event.endDate)} experience',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.dubaiTeal,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6), // Reduced from 8
                    
                    // Description text - NEW: Using available description content
                    Expanded(
                      child: Text(
                        _getDisplayDescription(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 4, // Increased from 3 to 4 lines for more description
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 4), // Reduced from 8 to minimize space before price
                    
                    // Price and rating - more compact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Text(
                          event.displayPrice,
                          style: GoogleFonts.comfortaa(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: event.isFree ? AppColors.dubaiTeal : AppColors.textPrimary,
                          ),
                        ),
                        
                        // Rating
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 12,
                              color: AppColors.dubaiGold,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              event.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150, // Increased height for mobile horizontal cards
        child: GlassCard(
          padding: EdgeInsets.zero,
          blur: 8,
          opacity: 0.05,
          child: Row(
            children: [
              // Event image - larger size for mobile
              _buildEventImageHorizontal(),
              
              // Event details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Event title
                      Text(
                        event.title,
                        style: GoogleFonts.comfortaa(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Event date
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatEventDate(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venue.area,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Price
                      Text(
                        event.displayPrice,
                        style: GoogleFonts.comfortaa(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: event.isFree ? AppColors.dubaiTeal : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return Container(
      height: isCompact ? 180 : 200, // Increased height for better visibility on mobile
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Image - Direct loading for mobile
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: event.imageUrls.isNotEmpty
                ? _buildDirectImage()
                : _buildImagePlaceholder(),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Event badges - smaller and more compact
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.isFeatured)
                  _buildEventBadge('Featured', AppColors.dubaiGold),
                if (event.isFree)
                  _buildEventBadge('Free', AppColors.dubaiTeal),
                if (event.isTrending)
                  _buildEventBadge('Trending', AppColors.dubaiCoral),
              ],
            ),
          ),
          
          // Heart/Save actions
          Positioned(
            top: 8,
            right: 8,
            child: EventFloatingActions(event: event),
          ),
          
          // Age range indicator
          if (event.familySuitability.minAge != null || event.familySuitability.maxAge != null)
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  event.ageRange,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEventImageHorizontal() {
    return Container(
      width: 150, // Increased width for better visibility
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        child: event.imageUrls.isNotEmpty
            ? ImageUtils.buildNetworkImage(
                imageUrl: event.imageUrls.first,
                eventId: event.id,
                width: 150,
                height: double.infinity,
                fit: BoxFit.cover,
                errorWidget: _buildImagePlaceholderHorizontal(),
              )
            : _buildImagePlaceholderHorizontal(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: isCompact ? 180 : 200,
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Image.asset(
            'assets/images/mydscvr-logo.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              LucideIcons.calendar,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholderHorizontal() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/images/mydscvr-logo.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              LucideIcons.calendar,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Method to get the best available description
  String _getDisplayDescription() {
    // Priority order: shortDescription -> aiSummary -> description (truncated) -> fallback
    
    if (event.shortDescription != null && event.shortDescription!.isNotEmpty) {
      return event.shortDescription!;
    }
    
    if (event.aiSummary != null && event.aiSummary!.isNotEmpty) {
      return event.aiSummary!;
    }
    
    if (event.description.isNotEmpty) {
      // Increased max length to utilize more space with 4 lines
      const maxLength = 160; // Increased from 120 for more content
      if (event.description.length <= maxLength) {
        return event.description;
      }
      return '${event.description.substring(0, maxLength)}...';
    }
    
    // Fallback: generate description from available data
    return _generateFallbackDescription();
  }

  String _generateFallbackDescription() {
    // Generate description based on category and venue
    final category = event.category.toLowerCase();
    final area = event.venue.area;
    
    if (category.contains('cultural')) {
      return 'Discover rich cultural heritage with interactive experiences perfect for the whole family in $area.';
    } else if (category.contains('outdoor') || category.contains('adventure')) {
      return 'Enjoy outdoor adventures and exciting activities in the beautiful setting of $area.';
    } else if (category.contains('arts') || category.contains('craft')) {
      return 'Explore creativity through hands-on arts and crafts activities suitable for all ages in $area.';
    } else if (category.contains('entertainment') || category.contains('show')) {
      return 'Experience world-class entertainment and spectacular performances in the heart of $area.';
    } else {
      return 'Join us for an unforgettable family experience in $area. Perfect for creating lasting memories together.';
    }
  }

  String _formatEventDate() {
    final now = DateTime.now();
    final startDate = event.startDate;
    final endDate = event.endDate;
    
    // Helper function to check if two dates are the same day
    bool isSameDay(DateTime date1, DateTime date2) {
      return date1.year == date2.year && 
             date1.month == date2.month && 
             date1.day == date2.day;
    }
    
    // Format a date as "15 Mar" or "15 Mar 2024" if different year
    String formatDateShort(DateTime date) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final yearSuffix = date.year != now.year ? ' ${date.year}' : '';
      return '${date.day} ${months[date.month - 1]}$yearSuffix';
    }
    
    // Handle special cases for today/tomorrow
    if (isSameDay(startDate, now)) {
      if (endDate != null && !isSameDay(startDate, endDate)) {
        // Multi-day event starting today
        return 'Today - ${formatDateShort(endDate)}';
      } else {
        // Single day event today
        return 'Today ${_formatTime(startDate)}';
      }
    } else if (startDate.year == now.year && 
               startDate.month == now.month && 
               startDate.day == now.day + 1) {
      if (endDate != null && !isSameDay(startDate, endDate)) {
        // Multi-day event starting tomorrow
        return 'Tomorrow - ${formatDateShort(endDate)}';
      } else {
        // Single day event tomorrow
        return 'Tomorrow ${_formatTime(startDate)}';
      }
    } else {
      // Regular dates
      if (endDate != null && !isSameDay(startDate, endDate)) {
        // Multi-day event
        return '${formatDateShort(startDate)} - ${formatDateShort(endDate)}';
      } else {
        // Single day event
        return '${formatDateShort(startDate)} ${_formatTime(startDate)}';
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  
  Widget _buildDirectImage() {
    // Get CloudFront URL for S3 images
    String imageUrl = event.imageUrls.first;
    if (imageUrl.contains('mydscvr-event-images.s3') && imageUrl.contains('amazonaws.com')) {
      final regex = RegExp(r'https://mydscvr-event-images\.s3\.[^/]+\.amazonaws\.com/(.+)');
      final match = regex.firstMatch(imageUrl);
      if (match != null) {
        imageUrl = '${EnvironmentConfig.cdnUrl}/${match.group(1)}';
      }
    }
    
    // Direct Image.network for mobile - simplest possible approach
    if (kIsWeb && _isMobileBrowser()) {
      debugPrint('📱 MOBILE: Direct loading image: $imageUrl');
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: isCompact ? 180 : 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Direct image load failed: $error');
          return _buildImagePlaceholder();
        },
      );
    }
    
    // Use ImageUtils for desktop
    return ImageUtils.buildNetworkImage(
      imageUrl: event.imageUrls.first,
      eventId: event.id,
      width: double.infinity,
      height: isCompact ? 180 : 200,
      fit: BoxFit.cover,
      errorWidget: _buildImagePlaceholder(),
    );
  }
  
  bool _isMobileBrowser() {
    if (!kIsWeb) return false;
    // Simple mobile detection
    return true; // For testing - always treat as mobile
  }
} 