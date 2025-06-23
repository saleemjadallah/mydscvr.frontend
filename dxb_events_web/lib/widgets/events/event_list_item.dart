import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/event.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const EventListItem({
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
        padding: const EdgeInsets.all(16),
        blur: 6,
        opacity: 0.03,
        child: Row(
          children: [
            // Event image
            _buildEventImage(),
            
            const SizedBox(width: 16),
            
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and badges
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: GoogleFonts.comfortaa(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Event badges
                      if (event.isFeatured) _buildBadge('Featured', AppColors.dubaiGold),
                      if (event.isFree) _buildBadge('Free', AppColors.dubaiTeal),
                      if (event.isTrending) _buildBadge('Trending', AppColors.dubaiCoral),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Short description
                  if (event.shortDescription != null) ...[
                    Text(
                      event.shortDescription!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Event details row
                  Row(
                    children: [
                      // Date and time
                      Icon(
                        LucideIcons.calendar,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatEventDate(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Location
                      Icon(
                        LucideIcons.mapPin,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.venue.area,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bottom row with price, rating, and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        event.displayPrice,
                        style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: event.isFree ? AppColors.dubaiTeal : AppColors.textPrimary,
                        ),
                      ),
                      
                      // Rating and age range
                      Row(
                        children: [
                          // Age range
                          if (event.familySuitability.minAge != null || 
                              event.familySuitability.maxAge != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.dubaiPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.dubaiPurple.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                event.ageRange,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.dubaiPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          
                          // Rating
                          Icon(
                            LucideIcons.star,
                            size: 16,
                            color: AppColors.dubaiGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${event.reviewCount})',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Favorite button
                          GestureDetector(
                            onTap: onFavorite,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isFavorite 
                                    ? AppColors.dubaiCoral.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? LucideIcons.heart : LucideIcons.heart,
                                size: 18,
                                color: isFavorite ? AppColors.dubaiCoral : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return Container(
      width: 120,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              event.imageUrl,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder();
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            ),
          ),
          
          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),
          
          // Availability indicator
          if (!event.hasAvailableSlots)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sold Out',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 120,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          LucideIcons.image,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
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

  String _formatEventDate() {
    final now = DateTime.now();
    final eventDate = event.startDate;
    
    if (eventDate.year == now.year && 
        eventDate.month == now.month && 
        eventDate.day == now.day) {
      return 'Today • ${_formatTime(eventDate)}';
    } else if (eventDate.year == now.year && 
               eventDate.month == now.month && 
               eventDate.day == now.day + 1) {
      return 'Tomorrow • ${_formatTime(eventDate)}';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${eventDate.day} ${months[eventDate.month - 1]} • ${_formatTime(eventDate)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
} 