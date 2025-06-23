import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/event.dart';

class EventAmenitiesWidget extends StatelessWidget {
  final Venue venue;
  final List<String> accessibility;

  const EventAmenitiesWidget({
    super.key,
    required this.venue,
    required this.accessibility,
  });

  @override
  Widget build(BuildContext context) {
    final amenities = _getAmenities();
    final accessibilityFeatures = _getAccessibilityFeatures();
    
    if (amenities.isEmpty && accessibilityFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      blur: 4,
      opacity: 0.03,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.building,
                  size: 20,
                  color: AppColors.dubaiPurple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Facilities & Amenities',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Venue amenities
          if (amenities.isNotEmpty) ...[
            _buildSection('Venue Amenities', amenities, AppColors.dubaiTeal),
            if (accessibilityFeatures.isNotEmpty) const SizedBox(height: 20),
          ],
          
          // Accessibility features
          if (accessibilityFeatures.isNotEmpty)
            _buildSection('Accessibility', accessibilityFeatures, AppColors.dubaiCoral),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<AmenityItem> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) => _buildAmenityChip(item, color)).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(AmenityItem item, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            item.name,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<AmenityItem> _getAmenities() {
    final amenities = <AmenityItem>[];
    
    // Parse venue amenities from the amenities map
    if (venue.amenities != null) {
      final amenitiesMap = venue.amenities!;
      
      // Common venue amenities
      if (amenitiesMap['wifi'] == true) {
        amenities.add(AmenityItem('WiFi', LucideIcons.wifi));
      }
      if (amenitiesMap['air_conditioning'] == true) {
        amenities.add(AmenityItem('A/C', LucideIcons.snowflake));
      }
      if (amenitiesMap['restaurant'] == true) {
        amenities.add(AmenityItem('Restaurant', LucideIcons.utensils));
      }
      if (amenitiesMap['cafe'] == true) {
        amenities.add(AmenityItem('Café', LucideIcons.coffee));
      }
      if (amenitiesMap['gift_shop'] == true) {
        amenities.add(AmenityItem('Gift Shop', LucideIcons.shoppingBag));
      }
      if (amenitiesMap['restrooms'] == true) {
        amenities.add(AmenityItem('Restrooms', LucideIcons.building));
      }
      if (amenitiesMap['prayer_room'] == true) {
        amenities.add(AmenityItem('Prayer Room', LucideIcons.home));
      }
      if (amenitiesMap['atm'] == true) {
        amenities.add(AmenityItem('ATM', LucideIcons.creditCard));
      }
      if (amenitiesMap['first_aid'] == true) {
        amenities.add(AmenityItem('First Aid', LucideIcons.cross));
      }
      if (amenitiesMap['lockers'] == true) {
        amenities.add(AmenityItem('Lockers', LucideIcons.lock));
      }
    }
    
    // Basic venue features
    if (venue.parkingAvailable) {
      amenities.add(AmenityItem('Parking', LucideIcons.car));
    }
    
    if (venue.publicTransportAccess) {
      amenities.add(AmenityItem('Public Transport', LucideIcons.bus));
    }
    
    return amenities;
  }

  List<AmenityItem> _getAccessibilityFeatures() {
    final features = <AmenityItem>[];
    
    for (final feature in accessibility) {
      final lowerFeature = feature.toLowerCase();
      
      if (lowerFeature.contains('wheelchair') || lowerFeature.contains('accessible')) {
        features.add(AmenityItem('Wheelchair Accessible', LucideIcons.accessibility));
      } else if (lowerFeature.contains('elevator') || lowerFeature.contains('lift')) {
        features.add(AmenityItem('Elevator Access', LucideIcons.arrowUp));
      } else if (lowerFeature.contains('ramp')) {
        features.add(AmenityItem('Ramp Access', LucideIcons.trendingUp));
      } else if (lowerFeature.contains('braille')) {
        features.add(AmenityItem('Braille Signage', LucideIcons.eye));
      } else if (lowerFeature.contains('hearing') || lowerFeature.contains('audio')) {
        features.add(AmenityItem('Hearing Assistance', LucideIcons.headphones));
      } else if (lowerFeature.contains('sign language')) {
        features.add(AmenityItem('Sign Language', LucideIcons.hand));
      } else if (lowerFeature.contains('assistance') || lowerFeature.contains('guide')) {
        features.add(AmenityItem('Staff Assistance', LucideIcons.userCheck));
      } else if (lowerFeature.contains('reserved seating')) {
        features.add(AmenityItem('Reserved Seating', LucideIcons.armchair));
      } else {
        // Generic accessibility feature
        features.add(AmenityItem(feature, LucideIcons.heart));
      }
    }
    
    return features;
  }
}

class AmenityItem {
  final String name;
  final IconData icon;

  const AmenityItem(this.name, this.icon);
} 