import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event.dart';
import 'event_actions.dart';

class EventCardSimple extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCardSimple({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  State<EventCardSimple> createState() => _EventCardSimpleState();
}

class _EventCardSimpleState extends State<EventCardSimple>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 16.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Navigate to event details page using proper GoRouter with event ID
    context.go('/event/${widget.event.id}');
    
    // Call the provided onTap callback if exists
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered 
                          ? AppColors.dubaiTeal.withOpacity(0.15)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                      spreadRadius: _isHovered ? 1 : 0,
                    ),
                  ],
                  border: _isHovered
                      ? Border.all(
                          color: AppColors.dubaiTeal.withOpacity(0.3),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image header with fallback - responsive height
                    Container(
                      height: isMobile ? 140 : 160,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        color: Colors.grey[200],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              widget.event.imageUrl,
                              width: double.infinity,
                              height: isMobile ? 140 : 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to gradient if image fails
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.oceanGradient,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      LucideIcons.calendar,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Heart/Save actions
                          Positioned(
                            top: 8,
                            right: 8,
                            child: EventFloatingActions(event: widget.event),
                          ),
                          
                          // Hover overlay
                          if (_isHovered)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                color: AppColors.dubaiTeal.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.eye,
                                        size: 14,
                                        color: AppColors.dubaiTeal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'View Details',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.dubaiTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Event details - more compact for mobile
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Venue location with rating - always show
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.event.venue.area,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Rating
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: AppColors.dubaiGold,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.event.rating.toStringAsFixed(1),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Date and time - always show but compact on mobile
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.calendar,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    isMobile ? _formatEventDateShort() : _formatEventDate(),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Age range and duration - always show
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.users,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.event.ageRange,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  LucideIcons.clock,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    isMobile ? _formatDurationShort() : _formatDuration(),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Event title - allow 2 lines on mobile too
                            Text(
                              widget.event.title,
                              style: GoogleFonts.comfortaa(
                                fontSize: isMobile ? 13 : 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Event tags - show on mobile too but limit to 2
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: _buildEventTags(maxTags: isMobile ? 2 : 3),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Description - show on mobile with more lines
                            Expanded(
                              child: Text(
                                _getEventDescription(),
                                style: GoogleFonts.inter(
                                  fontSize: isMobile ? 12 : 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: isMobile ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Price and View Details - simplified for mobile
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.event.displayPrice,
                                  style: GoogleFonts.comfortaa(
                                    fontSize: isMobile ? 13 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: widget.event.isFree ? AppColors.dubaiTeal : AppColors.textPrimary,
                                  ),
                                ),
                                if (!isMobile)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _isHovered 
                                          ? AppColors.dubaiTeal.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'View Details',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _isHovered ? AppColors.dubaiTeal : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        AnimatedRotation(
                                          turns: _isHovered ? 0.1 : 0.0,
                                          duration: const Duration(milliseconds: 200),
                                          child: Icon(
                                            LucideIcons.arrowRight,
                                            size: 14,
                                            color: _isHovered ? AppColors.dubaiTeal : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Icon(
                                    LucideIcons.arrowRight,
                                    size: 16,
                                    color: AppColors.dubaiTeal,
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
            ),
          );
        },
      ),
    );
  }
  
  List<Widget> _buildEventTags({int maxTags = 3}) {
    final tags = <Widget>[];
    
    // Add category-based tags
    if (widget.event.category.isNotEmpty) {
      tags.add(_buildTag(_formatCategoryName(widget.event.category), AppColors.dubaiTeal));
    }
    
    // Add amenity-based tags
    if (widget.event.venue.parkingAvailable) {
      tags.add(_buildTag('Free Parking', AppColors.dubaiGold));
    }
    
    if (widget.event.included.any((item) => item.toLowerCase().contains('food')) ||
        widget.event.tags.contains('food')) {
      tags.add(_buildTag('Food Included', AppColors.dubaiCoral));
    }
    
    if (widget.event.tags.contains('outdoor')) {
      tags.add(_buildTag('Outdoor Fun', AppColors.dubaiTeal));
    }
    
    if (widget.event.tags.contains('educational')) {
      tags.add(_buildTag('Educational', AppColors.dubaiGold));
    }
    
    if (widget.event.tags.contains('entertainment')) {
      tags.add(_buildTag('Live Shows', AppColors.dubaiCoral));
    }
    
    // Limit tags based on parameter
    return tags.take(maxTags).toList();
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  
  String _formatCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'arts_and_culture':
        return 'Arts & Crafts';
      case 'educational':
        return 'Educational';
      case 'entertainment':
        return 'Entertainment';
      case 'food_and_drink':
        return 'Food & Drink';
      case 'health_and_wellness':
        return 'Health & Wellness';
      case 'shopping':
        return 'Shopping';
      case 'sports_and_fitness':
        return 'Sports & Fitness';
      case 'technology':
        return 'Technology';
      case 'travel_and_tourism':
        return 'Tourism';
      default:
        return category.replaceAll('_', ' ').toUpperCase();
    }
  }
  
  String _formatEventDate() {
    final now = DateTime.now();
    final eventDate = widget.event.startDate;
    final endDate = widget.event.endDate ?? eventDate.add(const Duration(hours: 2));
    
    if (eventDate.year == now.year && 
        eventDate.month == now.month && 
        eventDate.day == now.day) {
      return 'Today • ${_formatTime(eventDate)} - ${_formatTime(endDate)}';
    } else if (eventDate.year == now.year && 
               eventDate.month == now.month && 
               eventDate.day == now.day + 1) {
      return 'Tomorrow • ${_formatTime(eventDate)} - ${_formatTime(endDate)}';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${weekdays[eventDate.weekday - 1]}, ${months[eventDate.month - 1]} ${eventDate.day} • ${_formatTime(eventDate)} - ${_formatTime(endDate)}';
    }
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  
  String _formatDuration() {
    final endDate = widget.event.endDate ?? widget.event.startDate.add(const Duration(hours: 2));
    final duration = endDate.difference(widget.event.startDate);
    if (duration.inHours > 0) {
      if (duration.inHours >= 6) {
        return 'Full day adventure';
      } else {
        return '${duration.inHours}-hour experience';
      }
    } else {
      return '${duration.inMinutes} min experience';
    }
  }

  String _getEventDescription() {
    // Use the displaySummary method which already has fallback logic
    final summary = widget.event.displaySummary;
    if (summary.isNotEmpty) {
      return summary;
    }

    // Additional fallback: try to generate a description from category and venue
    final category = _formatCategoryName(widget.event.category);
    final area = widget.event.venue.area;
    return 'Join us for this $category event in $area. Perfect for families looking for quality time together.';
  }
  
  String _formatEventDateShort() {
    final now = DateTime.now();
    final eventDate = widget.event.startDate;
    
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
      return '${months[eventDate.month - 1]} ${eventDate.day} • ${_formatTime(eventDate)}';
    }
  }
  
  String _formatDurationShort() {
    final endDate = widget.event.endDate ?? widget.event.startDate.add(const Duration(hours: 2));
    final duration = endDate.difference(widget.event.startDate);
    if (duration.inHours >= 6) {
      return 'Full day';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}min';
    }
  }
} 