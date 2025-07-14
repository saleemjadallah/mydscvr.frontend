import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
// import 'package:url_launcher/url_launcher.dart'; // TODO: Replace with web-safe link handling

import '../../core/constants/app_colors.dart';
import '../../models/event.dart';
import '../../utils/duration_formatter.dart';
import '../../features/event_details/event_details_screen.dart';

/// Enhanced Event Card that showcases all new backend extraction features
class EnhancedEventCard extends StatelessWidget {
  final Event event;
  final bool showQualityMetrics;
  final bool showSocialMedia;
  final VoidCallback? onTap;

  const EnhancedEventCard({
    super.key,
    required this.event,
    this.showQualityMetrics = true,
    this.showSocialMedia = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 480;
    final isTablet = screenWidth <= 768;
    
    return Card(
      elevation: isMobile ? 4 : 8,
      margin: EdgeInsets.all(isMobile ? 4 : 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Quality Badge
            _buildImageSection(context),
            
            // Event Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Category
                    _buildTitleSection(context),
                    
                    SizedBox(height: isMobile ? 4 : 8),
                    
                    // Enhanced Description
                    _buildDescriptionSection(context),
                    
                    SizedBox(height: isMobile ? 6 : 12),
                    
                    // Event Details Row - simplified on mobile
                    _buildEventDetailsRow(),
                    
                    // Venue section - only show on larger screens
                    if (!isMobile) ...[
                      const SizedBox(height: 12),
                      _buildVenueSection(),
                    ],
                    
                    // Social Media Links - hide on mobile and tablet
                    if (showSocialMedia && !isTablet && event.socialMedia?.hasAnyLinks == true) ...[
                      const SizedBox(height: 12),
                      _buildSocialMediaSection(),
                    ],
                    
                    const Spacer(),
                    
                    // Bottom section with price and actions
                    _buildBottomSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 480;
    
    return Container(
      height: isMobile ? 140 : 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: event.imageUrls.isNotEmpty
                ? Image.network(
                    event.imageUrls.first,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          
          // Quality Badge (top-right)
          if (showQualityMetrics && event.qualityMetrics != null)
            Positioned(
              top: 12,
              right: 12,
              child: _buildQualityBadge(),
            ),
          
          // Event Type Badge (top-left)
          if (event.eventType != null)
            Positioned(
              top: 12,
              left: 12,
              child: _buildEventTypeBadge(),
            ),
          
          // Featured/Premium badges
          if (event.isFeatured || (event.qualityMetrics?.isReliableSource == true))
            Positioned(
              bottom: 12,
              left: 12,
              child: _buildFeaturedBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Icon(
        LucideIcons.calendar,
        size: 48,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildQualityBadge() {
    final metrics = event.qualityMetrics!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: metrics.qualityColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.checkCircle,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            metrics.confidenceLevel,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dubaiTeal.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        event.eventType!.replaceAll('_', ' ').toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeaturedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dubaiGold.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            event.qualityMetrics?.isReliableSource == true 
                ? LucideIcons.shield 
                : LucideIcons.star,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            event.qualityMetrics?.isReliableSource == true ? 'VERIFIED' : 'FEATURED',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 480;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chip - smaller on mobile
        if (event.primaryCategory != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8, 
              vertical: isMobile ? 2 : 4
            ),
            decoration: BoxDecoration(
              color: AppColors.dubaiCoral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.dubaiCoral.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              event.primaryCategory!.replaceAll('_', ' ').toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w600,
                color: AppColors.dubaiCoral,
              ),
            ),
          ),
        
        SizedBox(height: isMobile ? 4 : 8),
        
        // Event Title - single line on mobile
        Text(
          event.title,
          style: GoogleFonts.comfortaa(
            fontSize: isMobile ? 14 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          maxLines: isMobile ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 480;
    
    // Use AI summary if available, otherwise description
    String displayText = event.aiSummary ?? event.description;
    
    // Skip description on very small screens to save space
    if (isMobile && screenWidth <= 380) {
      return const SizedBox.shrink();
    }
    
    return Text(
      displayText,
      style: GoogleFonts.inter(
        fontSize: isMobile ? 12 : 14,
        color: AppColors.textSecondary,
        height: 1.3,
      ),
      maxLines: isMobile ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEventDetailsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration and experience metrics (like featured events)
        Row(
          children: [
            Icon(
              LucideIcons.clock,
              size: 14,
              color: AppColors.dubaiTeal,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${DurationFormatter.formatForDetails(event.startDate, event.endDate)} experience',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.dubaiTeal,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Additional detail chips
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            // Age restrictions
            _buildDetailChip(
              icon: LucideIcons.users,
              label: event.ageRange,
              color: AppColors.dubaiGold,
            ),
            
            // Indoor/Outdoor
            if (event.indoorOutdoor != null)
              _buildDetailChip(
                icon: event.indoorOutdoor == 'indoor' ? LucideIcons.home : LucideIcons.sun,
                label: event.indoorOutdoor!.toUpperCase(),
                color: event.indoorOutdoor == 'indoor' ? Colors.blue : Colors.green,
              ),
              
            // Duration hours (if available)
            if (event.durationHours != null)
              _buildDetailChip(
                icon: LucideIcons.clock,
                label: '${event.durationHours!.toStringAsFixed(0)}h',
                color: AppColors.dubaiTeal,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Date, Time, and Venue
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                icon: LucideIcons.calendar,
                text: _formatEventDate(),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: LucideIcons.mapPin,
                text: '${event.venue.name}, ${event.venue.area}',
              ),
            ],
          ),
        ),
        
        // Right Column: Transportation Badges
        if (event.metroAccessible == true || event.venue.parkingAvailable)
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (event.metroAccessible == true)
                  _buildTransportBadge(LucideIcons.train, 'METRO'),
                if (event.venue.parkingAvailable)
                  _buildTransportBadge(LucideIcons.car, 'PARKING'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTransportBadge(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    final socialMedia = event.socialMedia!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Event',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            if (socialMedia.instagram != null)
              _buildSocialButton(
                icon: LucideIcons.instagram,
                color: const Color(0xFFE4405F),
                url: socialMedia.instagram!,
              ),
            if (socialMedia.facebook != null)
              _buildSocialButton(
                icon: LucideIcons.facebook,
                color: const Color(0xFF1877F2),
                url: socialMedia.facebook!,
              ),
            if (socialMedia.twitter != null)
              _buildSocialButton(
                icon: LucideIcons.twitter,
                color: const Color(0xFF1DA1F2),
                url: socialMedia.twitter!,
              ),
            if (socialMedia.tiktok != null)
              _buildSocialButton(
                icon: LucideIcons.music,
                color: const Color(0xFF000000),
                url: socialMedia.tiktok!,
              ),
            if (socialMedia.youtube != null)
              _buildSocialButton(
                icon: LucideIcons.youtube,
                color: const Color(0xFFFF0000),
                url: socialMedia.youtube!,
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Left Column: Price and Family Score
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                event.displayPrice,
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: event.isFree ? AppColors.dubaiTeal : AppColors.textPrimary,
                ),
              ),
              if (event.familyScore != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.heart,
                        size: 14,
                        color: event.familyScoreColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Family ${event.familyScore}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: event.familyScoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Right Column: Action Buttons
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Quality info button
              if (showQualityMetrics && event.qualityMetrics != null)
                IconButton(
                  onPressed: () => _showQualityInfo(context),
                  icon: Icon(
                    LucideIcons.info,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Quality Info',
                ),
              
              // Book/Details button
              ElevatedButton(
                onPressed: () => _navigateToDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View More',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatEventDate() {
    final now = DateTime.now();
    final eventDate = event.startDate;
    
    if (eventDate.year == now.year && eventDate.month == now.month && eventDate.day == now.day) {
      return 'Today at ${_formatTime(eventDate)}';
    } else if (eventDate.difference(now).inDays == 1) {
      return 'Tomorrow at ${_formatTime(eventDate)}';
    } else if (eventDate.difference(now).inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[eventDate.weekday - 1]} at ${_formatTime(eventDate)}';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${eventDate.day} ${months[eventDate.month - 1]} at ${_formatTime(eventDate)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(eventId: event.id),
      ),
    );
  }

  void _launchUrl(String url) async {
    // TODO: Implement web-safe URL launching
    print('Launch URL: $url');
    /*
    String finalUrl = url;
    if (!url.startsWith('http')) {
      finalUrl = 'https://$url';
    }
    
    if (await canLaunchUrl(Uri.parse(finalUrl))) {
      await launchUrl(Uri.parse(finalUrl));
    }
    */
  }

  void _showQualityInfo(BuildContext context) {
    final metrics = event.qualityMetrics!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Event Quality Information',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQualityRow('Extraction Confidence', '${(metrics.extractionConfidence * 100).toInt()}%'),
            _buildQualityRow('Data Completeness', '${(metrics.dataCompleteness * 100).toInt()}%'),
            _buildQualityRow('Source Reliability', metrics.sourceReliability.toUpperCase()),
            _buildQualityRow('Extraction Method', metrics.extractionMethod),
            
            if (metrics.hasWarnings) ...[
              const SizedBox(height: 16),
              Text(
                'Validation Warnings:',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...metrics.validationWarnings.map((warning) => Text(
                '• $warning',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}