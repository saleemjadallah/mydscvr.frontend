import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/event.dart';
import '../../utils/duration_formatter.dart';
import '../../utils/image_utils.dart';
import 'event_actions.dart';

class EventCardEnhanced extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const EventCardEnhanced({
    super.key,
    required this.event,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        blur: 8,
        opacity: 0.05,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image with AI enhancement indicators
            _buildEventImage(),
            
            // Event details with enhanced information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip and price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(event.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getCategoryColor(event.category).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _formatCategoryName(event.category),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(event.category),
                            ),
                          ),
                        ),
                        // Price
                        Text(
                          event.displayPrice,
                          style: GoogleFonts.comfortaa(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: event.isFree ? AppColors.dubaiTeal : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Event title
                    Text(
                      event.title,
                      style: GoogleFonts.comfortaa(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Event dates with start and end dates
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Start date with time
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
                                _formatStartDate(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Duration indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.dubaiTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatDuration(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.dubaiTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // End date (if different from start date)
                        if (_shouldShowEndDate())
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 2),
                            child: Text(
                              'Ends: ${_formatEndDate()}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 3),
                    
                    // Venue location with area emphasis
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
                            '${event.venue.name} • ${event.venue.area}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
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
                        Text(
                          '${_formatDurationExperience()} experience',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.dubaiTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Key features chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _buildFeatureChips(),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description with fallback logic
                    Expanded(
                      child: Text(
                        _getDisplayDescription(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2, // Reduced to save space
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Bottom row with family score and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Family Score (AI-enhanced) and age range
                        Row(
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 12,
                              color: AppColors.dubaiTeal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.ageRange,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dubaiTeal,
                              ),
                            ),
                            if (event.familyScore != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                LucideIcons.heart,
                                size: 12,
                                color: event.familyScoreColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${event.familyScore}%',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: event.familyScoreColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        // Rating with interaction
                        EventRatingButton(
                          event: event,
                          isCompact: true,
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

  Widget _buildEventImage() {
    return Container(
      height: 140, // Reduced from 160 to make card smaller
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: event.imageUrls.isNotEmpty
                ? ImageUtils.buildNetworkImage(
                    imageUrl: event.imageUrls.first,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorWidget: _buildImagePlaceholder(),
                  )
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
          
          // Event badges including AI enhancement indicator
          Positioned(
            top: 12,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Enhancement Badge
                if (event.hasAiEnhancement)
                  _buildEventBadge('AI Enhanced', AppColors.dubaiTeal),
                if (event.isFeatured)
                  _buildEventBadge('Featured', AppColors.dubaiGold),
                if (event.isFree)
                  _buildEventBadge('Free', AppColors.dubaiCoral),
                if (event.isTrending)
                  _buildEventBadge('Trending', AppColors.dubaiGold),
              ],
            ),
          ),
          
          // Heart/Save actions
          Positioned(
            top: 8,
            right: 8,
            child: EventFloatingActions(event: event),
          ),
          
          // Age range indicator with family score
          Positioned(
            bottom: 8,
            left: 8,
            child: Row(
              children: [
                // Age range
                if (event.familySuitability.minAge != null || event.familySuitability.maxAge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.ageRange,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // Family suitability indicator
                if (event.familyScore != null)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.familyScoreColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.heart,
                          size: 8,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${event.familyScore}',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiCategoriesRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: event.categories.take(3).map((category) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getCategoryColor(category).withOpacity(0.5),
                width: 0.5,
              ),
            ),
            child: Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: _getCategoryColor(category),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            'assets/images/mydscvr-logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              LucideIcons.calendar,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'family':
        return AppColors.dubaiTeal;
      case 'kids':
      case 'children':
        return AppColors.dubaiCoral;
      case 'outdoor':
        return Colors.green;
      case 'indoor':
        return Colors.blue;
      case 'arts':
        return Colors.purple;
      case 'sports':
        return Colors.orange;
      case 'educational':
        return Colors.indigo;
      case 'entertainment':
        return AppColors.dubaiGold;
      case 'free':
        return AppColors.dubaiTeal;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getQualityColor(int score) {
    if (score >= 90) return Colors.green.shade600;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.orange.shade700;
    return Colors.red;
  }

  String _formatEventDate() {
    final now = DateTime.now();
    final eventDate = event.startDate;
    
    if (eventDate.year == now.year && 
        eventDate.month == now.month && 
        eventDate.day == now.day) {
      return 'Today ${_formatTime(eventDate)}';
    } else if (eventDate.year == now.year && 
               eventDate.month == now.month && 
               eventDate.day == now.day + 1) {
      return 'Tomorrow ${_formatTime(eventDate)}';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${eventDate.day} ${months[eventDate.month - 1]}';
    }
  }

  String _formatStartDate() {
    final now = DateTime.now();
    final eventDate = event.startDate;
    
    if (eventDate.year == now.year && 
        eventDate.month == now.month && 
        eventDate.day == now.day) {
      return 'Today ${_formatTime(eventDate)}';
    } else if (eventDate.year == now.year && 
               eventDate.month == now.month && 
               eventDate.day == now.day + 1) {
      return 'Tomorrow ${_formatTime(eventDate)}';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${eventDate.day} ${months[eventDate.month - 1]} ${_formatTime(eventDate)}';
    }
  }

  String _formatEndDate() {
    final now = DateTime.now();
    final endDate = event.endDate;
    
    if (endDate == null) return '';
    
    if (endDate.year == now.year && 
        endDate.month == now.month && 
        endDate.day == now.day) {
      return 'Today';
    } else if (endDate.year == now.year && 
               endDate.month == now.month && 
               endDate.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${endDate.day} ${months[endDate.month - 1]}';
    }
  }

  bool _shouldShowEndDate() {
    final startDate = event.startDate;
    final endDate = event.endDate;
    
    // Don't show end date if it's null
    if (endDate == null) return false;
    
    // Only show end date if it's different from start date (different day)
    return startDate.year != endDate.year ||
           startDate.month != endDate.month ||
           startDate.day != endDate.day;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getDisplayDescription() {
    // Priority order: shortDescription -> aiSummary -> description (truncated) -> fallback
    
    if (event.shortDescription != null && event.shortDescription!.isNotEmpty) {
      return event.shortDescription!;
    }
    
    if (event.aiSummary != null && event.aiSummary!.isNotEmpty) {
      return event.aiSummary!;
    }
    
    if (event.description.isNotEmpty) {
      const maxLength = 160;
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

  String _formatCategoryName(String category) {
    // Format category names for display
    switch (category.toLowerCase()) {
      case 'tours_and_sightseeing':
        return 'Tours';
      case 'business_and_networking':
        return 'Business';
      case 'kids_and_family':
        return 'Family';
      case 'food_and_dining':
        return 'Food';
      case 'indoor_activities':
        return 'Indoor';
      case 'outdoor_activities':
        return 'Outdoor';
      case 'water_sports':
        return 'Water';
      case 'music_and_concerts':
        return 'Music';
      case 'comedy_and_shows':
        return 'Shows';
      case 'sports_and_fitness':
        return 'Sports';
      case 'festivals_and_celebrations':
        return 'Festival';
      default:
        return category.replaceAll('_', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }

  String _formatDuration() {
    return DurationFormatter.formatForCard(event.startDate, event.endDate);
  }

  String _formatDurationExperience() {
    return DurationFormatter.formatForDetails(event.startDate, event.endDate);
  }

  List<Widget> _buildFeatureChips() {
    List<Widget> chips = [];
    
    // Add key features based on event data
    if (event.isFree) {
      chips.add(_buildFeatureChip('Free', AppColors.dubaiTeal));
    }
    
    if (event.venue.parkingAvailable) {
      chips.add(_buildFeatureChip('Parking', AppColors.dubaiGold));
    }
    
    if (event.familySuitability.strollerFriendly) {
      chips.add(_buildFeatureChip('Stroller OK', AppColors.dubaiCoral));
    }
    
    if (event.tags.contains('indoor') || event.category.toLowerCase().contains('indoor')) {
      chips.add(_buildFeatureChip('Indoor', Colors.blue));
    }
    
    if (event.tags.contains('outdoor') || event.category.toLowerCase().contains('outdoor')) {
      chips.add(_buildFeatureChip('Outdoor', Colors.green));
    }
    
    if (event.familySuitability.educationalContent || event.tags.contains('educational')) {
      chips.add(_buildFeatureChip('Educational', Colors.purple));
    }
    
    if (event.tags.contains('food') || event.category.toLowerCase().contains('food')) {
      chips.add(_buildFeatureChip('Food Included', Colors.orange));
    }
    
    // Limit to 3 chips to avoid overflow
    return chips.take(3).toList();
  }

  Widget _buildFeatureChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
} 