import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../core/constants/app_colors.dart';
import '../../models/event.dart';

class EventCardGlassmorphic extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool isListMode;

  const EventCardGlassmorphic({
    super.key,
    required this.event,
    this.onTap,
    this.isListMode = false,
  });

  @override
  State<EventCardGlassmorphic> createState() => _EventCardGlassmorphicState();
}

class _EventCardGlassmorphicState extends State<EventCardGlassmorphic>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _animationController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -4.0 : 0.0, 0.0),
          child: Container(
            width: widget.isListMode ? double.infinity : 320,
            height: widget.isListMode ? 120 : 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isHovered 
                      ? const Color(0xFFFF6B6B).withOpacity(0.15)
                      : const Color(0xFFFF6B6B).withOpacity(0.1),
                  blurRadius: _isHovered ? 30 : 20,
                  offset: Offset(0, _isHovered ? 8 : 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: widget.isListMode 
                ? _buildListContent() 
                : _buildGridContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildGridContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(widget.event.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildPriceTag(),
                  ),
                ),
              ),
            ),
          ),
          
          // Content section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: GoogleFonts.comfortaa(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.event.category,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Date and location row
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDate(widget.event.startDate),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: const Color(0xFFFFB347),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.event.venue.area,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.event.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and category
                Text(
                  widget.event.title,
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.event.category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Date and location
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 12,
                      color: const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(widget.event.startDate),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      LucideIcons.mapPin,
                      size: 12,
                      color: const Color(0xFFFFB347),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.event.venue.area,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF666666),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Price
          _buildPriceTag(),
        ],
      ),
    );
  }

  Widget _buildPriceTag() {
    return Container(
      width: widget.isListMode ? 60 : 80,
      height: widget.isListMode ? 28 : 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B), // Coral
            Color(0xFFFFB347), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.event.pricing.basePrice == 0 
              ? 'FREE' 
              : 'AED ${widget.event.pricing.basePrice.toInt()}',
          style: GoogleFonts.inter(
            fontSize: widget.isListMode ? 10 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    
    if (eventDate == today) {
      return 'Today';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
} 