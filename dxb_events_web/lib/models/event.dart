import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Main event model for Dubai family activities
@JsonSerializable()
class Event {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'ai_summary')
  final String? aiSummary;
  @JsonKey(name: 'family_score')
  final int? familyScore;
  @JsonKey(name: 'categories')
  final List<String> categories;
  @JsonKey(name: 'enhanced_content')
  final EnhancedContent? enhancedContent;
  @JsonKey(name: 'quality_score')
  final int? qualityScore;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String category;
  final List<String> tags;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  final Venue venue;
  final Pricing pricing;
  @JsonKey(name: 'family_suitability')
  final FamilySuitability familySuitability;
  final List<String> highlights;
  final List<String> included;
  final List<String> accessibility;
  @JsonKey(name: 'what_to_bring')
  final List<String> whatToBring;
  @JsonKey(name: 'important_info')
  final List<String> importantInfo;
  @JsonKey(name: 'cancellation_policy')
  final String? cancellationPolicy;
  @JsonKey(name: 'organizer_info')
  final OrganizerInfo organizerInfo;
  @JsonKey(name: 'booking_required')
  final bool bookingRequired;
  @JsonKey(name: 'available_slots')
  final int? availableSlots;
  @JsonKey(name: 'max_capacity')
  final int? maxCapacity;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'is_trending')
  final bool isTrending;
  final double rating;
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  // Enhanced extraction fields from backend
  @JsonKey(name: 'event_url')
  final String? eventUrl;
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @JsonKey(name: 'social_media')
  final SocialMediaLinks? socialMedia;
  @JsonKey(name: 'quality_metrics')
  final QualityMetrics? qualityMetrics;
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;
  @JsonKey(name: 'ticket_links')
  final List<String> ticketLinks;
  @JsonKey(name: 'contact_info')
  final String? contactInfo;
  @JsonKey(name: 'target_audience')
  final List<String> targetAudience;
  @JsonKey(name: 'age_restrictions')
  final String? ageRestrictions;
  @JsonKey(name: 'dress_code')
  final String? dressCode;
  @JsonKey(name: 'duration_hours')
  final double? durationHours;
  final bool? recurring;
  @JsonKey(name: 'venue_type')
  final String? venueType;
  @JsonKey(name: 'metro_accessible')
  final bool? metroAccessible;
  @JsonKey(name: 'special_needs_friendly')
  final bool? specialNeedsFriendly;
  @JsonKey(name: 'language_requirements')
  final String? languageRequirements;
  @JsonKey(name: 'alcohol_served')
  final bool? alcoholServed;
  @JsonKey(name: 'transportation_notes')
  final String? transportationNotes;
  @JsonKey(name: 'primary_category')
  final String? primaryCategory;
  @JsonKey(name: 'secondary_categories')
  final List<String> secondaryCategories;
  @JsonKey(name: 'event_type')
  final String? eventType;
  @JsonKey(name: 'indoor_outdoor')
  final String? indoorOutdoor;
  @JsonKey(name: 'special_occasion')
  final String? specialOccasion;

  // AI Search fields
  @JsonKey(name: 'ai_score')
  final double? aiScore;
  @JsonKey(name: 'ai_reasoning')
  final String? aiReasoning;
  @JsonKey(name: 'ai_highlights')
  final List<String>? aiHighlights;

  // New field for AI image flag
  @JsonKey(name: 'has_ai_image')
  final bool hasAiImage;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription,
    this.aiSummary,
    this.familyScore,
    this.categories = const [],
    this.enhancedContent,
    this.qualityScore,
    required this.imageUrl,
    required this.category,
    required this.tags,
    required this.startDate,
    this.endDate,
    required this.venue,
    required this.pricing,
    required this.familySuitability,
    required this.highlights,
    required this.included,
    required this.accessibility,
    required this.whatToBring,
    required this.importantInfo,
    this.cancellationPolicy,
    required this.organizerInfo,
    required this.bookingRequired,
    this.availableSlots,
    this.maxCapacity,
    required this.isFeatured,
    required this.isTrending,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    
    // Enhanced extraction fields
    this.eventUrl,
    this.sourceUrl,
    this.socialMedia,
    this.qualityMetrics,
    this.imageUrls = const [],
    this.ticketLinks = const [],
    this.contactInfo,
    this.targetAudience = const [],
    this.ageRestrictions,
    this.dressCode,
    this.durationHours,
    this.recurring,
    this.venueType,
    this.metroAccessible,
    this.specialNeedsFriendly,
    this.languageRequirements,
    this.alcoholServed,
    this.transportationNotes,
    this.primaryCategory,
    this.secondaryCategories = const [],
    this.eventType,
    this.indoorOutdoor,
    this.specialOccasion,
    
    // AI Search fields
    this.aiScore,
    this.aiReasoning,
    this.aiHighlights,
    this.hasAiImage = false, // Default to false
  });

  // Use fromBackendApi instead of generated fromJson
  factory Event.fromJson(Map<String, dynamic> json) => Event.fromBackendApi(json);
  Map<String, dynamic> toJson() => throw UnimplementedError('Use fromBackendApi for parsing');

  /// Create Event from backend API response
  factory Event.fromBackendApi(Map<String, dynamic> json) {
    // Parse venue information
    final venueData = json['venue'] as Map<String, dynamic>?;
    final venue = venueData != null 
        ? Venue(
            id: json['id'] ?? '',
            name: venueData['name'] ?? 'TBA',
            address: venueData['address'] ?? '',
            area: venueData['area'] ?? json['area'] ?? 'Dubai',
            district: venueData['district'],
            city: 'Dubai',
            latitude: venueData['latitude']?.toDouble(),
            longitude: venueData['longitude']?.toDouble(),
            amenities: venueData['amenities'] as Map<String, dynamic>?,
            parkingAvailable: true,
            publicTransportAccess: true,
          )
        : Venue(
            id: json['id'] ?? '',
            name: 'Location TBA',
            address: json['area'] ?? 'Dubai',
            area: json['area'] ?? 'Dubai',
            city: 'Dubai',
            parkingAvailable: true,
            publicTransportAccess: true,
          );

    // Parse pricing information - handle multiple possible formats
    final pricingData = json['pricing'] as Map<String, dynamic>?;
    final priceData = json['price'] as Map<String, dynamic>?;
    
    final pricing = pricingData != null
        ? Pricing(
            basePrice: (pricingData['base_price'] ?? 0).toDouble(),
            maxPrice: pricingData['max_price']?.toDouble(),
            currency: pricingData['currency'] ?? 'AED',
            isRefundable: pricingData['is_refundable'] ?? true,
          )
        : priceData != null
        ? Pricing(
            basePrice: (priceData['min'] ?? 0).toDouble(),
            maxPrice: priceData['max']?.toDouble(),
            currency: priceData['currency'] ?? 'AED',
            isRefundable: true,
          )
        : Pricing(
            basePrice: (json['price_min'] ?? 0).toDouble(),
            maxPrice: json['price_max']?.toDouble(),
            currency: json['currency'] ?? 'AED',
            isRefundable: true,
          );

    // Parse AI-enhanced family suitability - handle backend format
    final familyScore = json['family_score'] as int?;
    final familySuitabilityData = json['family_suitability'] as Map<String, dynamic>?;
    final ageRestrictions = json['age_restrictions'] as Map<String, dynamic>?;
    
    final familySuitability = FamilySuitability(
      minAge: familySuitabilityData?['min_age'] ?? ageRestrictions?['min_age'] ?? json['age_min'],
      maxAge: familySuitabilityData?['max_age'] ?? ageRestrictions?['max_age'] ?? json['age_max'],
      recommendedAgeRange: familySuitabilityData?['recommended_age_range'] ?? json['age_range'] ?? 'All ages',
      strollerFriendly: familySuitabilityData?['stroller_friendly'] ?? json['stroller_friendly'] ?? true,
      babyChanging: familySuitabilityData?['baby_changing'] ?? true,
      nursingFriendly: familySuitabilityData?['nursing_friendly'] ?? true,
      kidMenuAvailable: familySuitabilityData?['kid_menu_available'] ?? false,
      educationalContent: familySuitabilityData?['educational_content'] ?? json['categories']?.contains('educational') ?? false,
      notes: familySuitabilityData?['notes'] ?? (familyScore != null ? 'Family Score: $familyScore/100' : null),
    );

    // Parse AI-enhanced content
    final enhancedContentData = json['enhanced_content'] as Map<String, dynamic>?;
    final enhancedContent = enhancedContentData != null
        ? EnhancedContent(
            familySummary: enhancedContentData['family_summary'],
            kidsDescription: enhancedContentData['kids_description'],
            practicalInfo: enhancedContentData['practical_info'],
            highlights: enhancedContentData['highlights'],
            tips: enhancedContentData['tips'],
          )
        : null;

    // Parse organizer info - handle backend format
    final organizerData = json['organizer_info'] as Map<String, dynamic>?;
    // Handle source field - it can be either a string or a map
    final sourceValue = json['source'];
    final sourceData = sourceValue is Map<String, dynamic> ? sourceValue : null;
    final sourceName = sourceValue is String ? sourceValue : sourceData?['name'];
    
    // Determine if the event has an AI-generated image
    final imagesData = json['images'] as Map<String, dynamic>?;
    final bool hasAiImage = imagesData != null && 
                            imagesData['ai_generated'] != null && 
                            (imagesData['ai_generated'] as String).isNotEmpty;

    final organizerInfo = OrganizerInfo(
      name: organizerData?['name'] ?? sourceName ?? json['source_name'] ?? 'Dubai Events',
      description: organizerData?['description'] ?? 'Verified event organizer',
      verificationStatus: organizerData?['verification_status'] ?? (sourceData?['verified'] == true ? 'verified' : 'pending'),
    );

    // Parse dates with better error handling
    DateTime startDate;
    DateTime? endDate;
    try {
      // Handle both string and timestamp formats
      final startDateValue = json['start_date'];
      if (startDateValue is String) {
        startDate = DateTime.parse(startDateValue);
      } else if (startDateValue is int) {
        startDate = DateTime.fromMillisecondsSinceEpoch(startDateValue * 1000);
      } else {
        throw Exception('Invalid start_date format');
      }
      
      final endDateValue = json['end_date'];
      if (endDateValue != null) {
        if (endDateValue is String) {
          endDate = DateTime.parse(endDateValue);
        } else if (endDateValue is int) {
          endDate = DateTime.fromMillisecondsSinceEpoch(endDateValue * 1000);
        }
      }
    } catch (e) {
      print('🚨 Event date parsing error: $e');
      print('🚨 start_date value: ${json['start_date']}');
      print('🚨 end_date value: ${json['end_date']}');
      startDate = DateTime.now().add(const Duration(days: 1));
      endDate = startDate.add(const Duration(hours: 2));
    }

    // Parse AI-enhanced tags and categories
    final aiCategories = (json['categories'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final tags = (json['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    
    // Determine category from AI categories if available
    String category = json['category'] ?? 'General';
    if (category == 'General' && aiCategories.isNotEmpty) {
      final firstCategory = aiCategories.first;
      category = firstCategory.substring(0, 1).toUpperCase() + firstCategory.substring(1);
    } else if (category == 'General' && tags.isNotEmpty) {
      // Fallback to tag-based categorization
      if (tags.contains('cultural') || tags.contains('heritage')) {
        category = 'Cultural';
      } else if (tags.contains('outdoor') || tags.contains('sports')) {
        category = 'Outdoor Activities';
      } else if (tags.contains('arts') || tags.contains('crafts')) {
        category = 'Arts & Crafts';
      } else if (tags.contains('educational') || tags.contains('science')) {
        category = 'Educational';
      } else if (tags.contains('food')) {
        category = 'Food & Dining';
      } else if (tags.contains('adventure')) {
        category = 'Adventure';
      } else if (tags.contains('entertainment') || tags.contains('music')) {
        category = 'Entertainment';
      } else if (tags.contains('indoor')) {
        category = 'Indoor Activities';
      } else if (tags.contains('beach')) {
        category = 'Beach & Water';
      }
    }

    // Parse image URLs using permanent AI image storage priority system
    // Priority: images.ai_generated > ai_image_url > image_url > filtered image_urls
    final List<String> imageUrls = [];
    final defaultImageUrl = 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80';
    
    // Highest priority: permanent AI generated image
    final imagesData = json['images'] as Map<String, dynamic>?;
    if (imagesData != null && imagesData['ai_generated'] != null && (imagesData['ai_generated'] as String).isNotEmpty) {
      imageUrls.add(imagesData['ai_generated'] as String);
    }
    
    // Second priority: ai_image_url field
    if (json['ai_image_url'] != null && json['ai_image_url'].toString().isNotEmpty) {
      final aiImageUrl = json['ai_image_url'].toString();
      if (!imageUrls.contains(aiImageUrl)) {
        imageUrls.add(aiImageUrl);
      }
    }
    
    // Third priority: regular image_url field
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      final regularImageUrl = json['image_url'].toString();
      if (!imageUrls.contains(regularImageUrl)) {
        imageUrls.add(regularImageUrl);
      }
    }
    
    // Finally, add other images from image_urls array (excluding OpenAI URLs)
    final rawImageUrls = (json['image_urls'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    for (final url in rawImageUrls) {
      if (!url.contains('oaidalleapiprodscus.blob.core.windows.net') && !imageUrls.contains(url)) {
        imageUrls.add(url);
      }
    }
    
    // Use default if no valid images found
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : defaultImageUrl;
    if (imageUrls.isEmpty) {
      imageUrls.add(defaultImageUrl);
    }

    // Parse social media links
    final socialMediaData = json['social_media'] as Map<String, dynamic>?;
    final socialMedia = socialMediaData != null 
        ? SocialMediaLinks.fromJson(socialMediaData)
        : null;

    // Parse quality metrics
    final qualityMetricsData = json['quality_metrics'] as Map<String, dynamic>?;
    final qualityMetrics = qualityMetricsData != null 
        ? QualityMetrics.fromJson(qualityMetricsData)
        : null;

    // Parse additional lists
    final ticketLinks = (json['ticket_links'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final targetAudience = (json['target_audience'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    final secondaryCategories = (json['secondary_categories'] as List<dynamic>?)?.cast<String>() ?? <String>[];

    // Parse boolean fields with defaults
    final isFeatured = json['is_featured'] ?? false;
    final isTrending = json['is_trending'] ?? false;
    final isFamilyFriendly = json['is_family_friendly'] ?? true;
    
    // Calculate rating from family_score if rating not provided
    final rating = (json['rating'] ?? (familyScore ?? 75) / 20).toDouble().clamp(1.0, 5.0);

    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Event',
      description: json['description'] ?? '',
      shortDescription: json['short_description'],
      aiSummary: json['ai_summary'],
      familyScore: familyScore,
      categories: aiCategories,
      enhancedContent: enhancedContent,
      qualityScore: json['quality_score'],
      imageUrl: imageUrl,
      category: category,
      tags: tags,
      startDate: startDate,
      endDate: endDate,
      venue: venue,
      pricing: pricing,
      familySuitability: familySuitability,
      highlights: <String>[], // Not provided by backend yet
      included: <String>[], // Not provided by backend yet
      accessibility: <String>[], // Not provided by backend yet
      whatToBring: <String>[], // Not provided by backend yet
      importantInfo: <String>[], // Not provided by backend yet
      cancellationPolicy: 'Please check with organizer',
      organizerInfo: organizerInfo,
      bookingRequired: json['booking_url'] != null,
      availableSlots: null,
      maxCapacity: null,
      isFeatured: isFeatured,
      isTrending: isTrending,
      rating: rating,
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      
      // Enhanced extraction fields
      eventUrl: json['event_url'],
      sourceUrl: json['source_url'],
      socialMedia: socialMedia,
      qualityMetrics: qualityMetrics,
      imageUrls: imageUrls,
      ticketLinks: ticketLinks,
      contactInfo: json['contact_info'],
      targetAudience: targetAudience,
      ageRestrictions: json['age_restrictions'],
      dressCode: json['dress_code'],
      durationHours: json['duration_hours']?.toDouble(),
      recurring: json['recurring'],
      venueType: json['venue_type'],
      metroAccessible: json['metro_accessible'],
      specialNeedsFriendly: json['special_needs_friendly'],
      languageRequirements: json['language_requirements'],
      alcoholServed: json['alcohol_served'],
      transportationNotes: json['transportation_notes'],
      primaryCategory: json['primary_category'],
      secondaryCategories: secondaryCategories,
      eventType: json['event_type'],
      indoorOutdoor: json['indoor_outdoor'],
      specialOccasion: json['special_occasion'],
      
      // AI Search fields
      aiScore: json['ai_score']?.toDouble(),
      aiReasoning: json['ai_reasoning'],
      aiHighlights: (json['ai_highlights'] as List<dynamic>?)?.cast<String>(),
      hasAiImage: hasAiImage,
    );
  }

  /// Helper methods
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(startDate.year, startDate.month, startDate.day);
    return today == eventDay;
  }

  bool get isThisWeekend {
    final now = DateTime.now();
    final daysUntilWeekend = 6 - now.weekday; // Saturday = 6
    final weekendStart = now.add(Duration(days: daysUntilWeekend));
    final weekendEnd = weekendStart.add(const Duration(days: 1)); // Sunday
    
    // Include both Saturday and Sunday events
    final eventDate = DateTime(startDate.year, startDate.month, startDate.day);
    final saturdayDate = DateTime(weekendStart.year, weekendStart.month, weekendStart.day);
    final sundayDate = DateTime(weekendEnd.year, weekendEnd.month, weekendEnd.day);
    
    return eventDate.isAtSameMomentAs(saturdayDate) || eventDate.isAtSameMomentAs(sundayDate);
  }

  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final eventDay = DateTime(startDate.year, startDate.month, startDate.day);
    return tomorrow == eventDay;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday
    
    final eventDate = DateTime(startDate.year, startDate.month, startDate.day);
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weekEnd = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
    
    return (eventDate.isAtSameMomentAs(weekStart) || eventDate.isAfter(weekStart)) &&
           (eventDate.isAtSameMomentAs(weekEnd) || eventDate.isBefore(weekEnd));
  }

  bool get isNextWeek {
    final now = DateTime.now();
    final startOfNextWeek = now.add(Duration(days: 7 - now.weekday + 1)); // Next Monday
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6)); // Next Sunday
    
    final eventDate = DateTime(startDate.year, startDate.month, startDate.day);
    final weekStart = DateTime(startOfNextWeek.year, startOfNextWeek.month, startOfNextWeek.day);
    final weekEnd = DateTime(endOfNextWeek.year, endOfNextWeek.month, endOfNextWeek.day);
    
    return (eventDate.isAtSameMomentAs(weekStart) || eventDate.isAfter(weekStart)) &&
           (eventDate.isAtSameMomentAs(weekEnd) || eventDate.isBefore(weekEnd));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    final eventDate = DateTime(startDate.year, startDate.month, startDate.day);
    return eventDate.year == now.year && eventDate.month == now.month;
  }

  bool get isUpcoming {
    return startDate.isAfter(DateTime.now());
  }

  bool get isFree => pricing.basePrice == 0;

  Duration get duration {
    return endDate?.difference(startDate) ?? const Duration(hours: 2);
  }

  String get displayPrice {
    if (pricing.basePrice == 0) {
      return 'Free';
    } else {
      return 'From AED ${pricing.basePrice.toStringAsFixed(0)}';
    }
  }

  String get ageRange {
    if (familySuitability.minAge == null && familySuitability.maxAge == null) {
      return 'All ages';
    } else if (familySuitability.minAge != null && familySuitability.maxAge != null) {
      return '${familySuitability.minAge}-${familySuitability.maxAge} years';
    } else if (familySuitability.minAge != null) {
      return '${familySuitability.minAge}+ years';
    } else {
      return 'Up to ${familySuitability.maxAge} years';
    }
  }

  bool get hasAvailableSlots {
    return availableSlots == null || availableSlots! > 0;
  }

  /// AI-Enhanced helper methods
  String get displaySummary {
    return aiSummary ?? shortDescription ?? description;
  }

  String get familyScoreText {
    if (familyScore == null) return 'Great for families';
    if (familyScore! >= 80) return 'Perfect for families';
    if (familyScore! >= 60) return 'Great for families';
    if (familyScore! >= 40) return 'Good for families';
    return 'Suitable for families';
  }

  Color get familyScoreColor {
    if (familyScore == null) return Colors.green;
    if (familyScore! >= 80) return Colors.green.shade600;
    if (familyScore! >= 60) return Colors.green;
    if (familyScore! >= 40) return Colors.orange;
    return Colors.red;
  }

  bool get hasAiEnhancement {
    return aiSummary != null || familyScore != null || categories.isNotEmpty;
  }
}

/// AI-Enhanced Content model
@JsonSerializable()
class EnhancedContent {
  @JsonKey(name: 'family_summary')
  final String? familySummary;
  @JsonKey(name: 'kids_description')
  final String? kidsDescription;
  @JsonKey(name: 'practical_info')
  final String? practicalInfo;
  final String? highlights;
  final String? tips;

  const EnhancedContent({
    this.familySummary,
    this.kidsDescription,
    this.practicalInfo,
    this.highlights,
    this.tips,
  });

  factory EnhancedContent.fromJson(Map<String, dynamic> json) {
    return EnhancedContent(
      familySummary: json['family_summary'],
      kidsDescription: json['kids_description'],
      practicalInfo: json['practical_info'],
      highlights: json['highlights'],
      tips: json['tips'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'family_summary': familySummary,
      'kids_description': kidsDescription,
      'practical_info': practicalInfo,
      'highlights': highlights,
      'tips': tips,
    };
  }
}

/// Venue information
@JsonSerializable()
class Venue {
  final String id;
  final String name;
  final String address;
  final String area;
  final String? district;
  final String? city;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final Map<String, dynamic>? amenities;
  @JsonKey(name: 'parking_available')
  final bool parkingAvailable;
  @JsonKey(name: 'public_transport_access')
  final bool publicTransportAccess;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
    this.district,
    this.city,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.amenities,
    required this.parkingAvailable,
    required this.publicTransportAccess,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      area: json['area'] ?? '',
      district: json['district'],
      city: json['city'],
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      amenities: json['amenities'],
      parkingAvailable: json['parking_available'] ?? false,
      publicTransportAccess: json['public_transport_access'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'area': area,
      'district': district,
      'city': city,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'amenities': amenities,
      'parking_available': parkingAvailable,
      'public_transport_access': publicTransportAccess,
    };
  }

  String get fullAddress {
    final parts = <String>[address];
    if (district != null) parts.add(district!);
    parts.add(area);
    if (city != null) parts.add(city!);
    return parts.join(', ');
  }
}

/// Pricing information
@JsonSerializable()
class Pricing {
  @JsonKey(name: 'base_price')
  final double basePrice;
  @JsonKey(name: 'max_price')
  final double? maxPrice;
  @JsonKey(name: 'child_price')
  final double? childPrice;
  @JsonKey(name: 'senior_price')
  final double? seniorPrice;
  @JsonKey(name: 'group_discount')
  final double? groupDiscount;
  @JsonKey(name: 'group_discounts')
  final Map<String, double> groupDiscounts;
  @JsonKey(name: 'early_bird_discount')
  final double? earlyBirdDiscount;
  final String currency;
  @JsonKey(name: 'booking_fee')
  final double? bookingFee;
  @JsonKey(name: 'cancellation_fee')
  final double? cancellationFee;
  @JsonKey(name: 'pricing_notes')
  final String? pricingNotes;
  @JsonKey(name: 'price_categories')
  final Map<String, double> priceCategories;
  @JsonKey(name: 'is_refundable')
  final bool isRefundable;

  const Pricing({
    required this.basePrice,
    this.maxPrice,
    this.childPrice,
    this.seniorPrice,
    this.groupDiscount,
    this.groupDiscounts = const {},
    this.earlyBirdDiscount,
    required this.currency,
    this.bookingFee,
    this.cancellationFee,
    this.pricingNotes,
    this.priceCategories = const {},
    this.isRefundable = true,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      basePrice: (json['base_price'] ?? 0).toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      childPrice: json['child_price']?.toDouble(),
      seniorPrice: json['senior_price']?.toDouble(),
      groupDiscount: json['group_discount']?.toDouble(),
      groupDiscounts: Map<String, double>.from(json['group_discounts'] ?? {}),
      earlyBirdDiscount: json['early_bird_discount']?.toDouble(),
      currency: json['currency'] ?? 'AED',
      bookingFee: json['booking_fee']?.toDouble(),
      cancellationFee: json['cancellation_fee']?.toDouble(),
      pricingNotes: json['pricing_notes'],
      priceCategories: Map<String, double>.from(json['price_categories'] ?? {}),
      isRefundable: json['is_refundable'] ?? true,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'base_price': basePrice,
      'max_price': maxPrice,
      'child_price': childPrice,
      'senior_price': seniorPrice,
      'group_discount': groupDiscount,
      'group_discounts': groupDiscounts,
      'early_bird_discount': earlyBirdDiscount,
      'currency': currency,
      'booking_fee': bookingFee,
      'cancellation_fee': cancellationFee,
      'pricing_notes': pricingNotes,
      'price_categories': priceCategories,
      'is_refundable': isRefundable,
    };
  }

  bool get isFree => basePrice == 0;
  
  double get effectiveChildPrice => childPrice ?? basePrice * 0.7;
}

/// Family suitability information
@JsonSerializable()
class FamilySuitability {
  @JsonKey(name: 'min_age')
  final int? minAge;
  @JsonKey(name: 'max_age')
  final int? maxAge;
  @JsonKey(name: 'recommended_age_range')
  final String? recommendedAgeRange;
  @JsonKey(name: 'stroller_friendly')
  final bool strollerFriendly;
  @JsonKey(name: 'baby_changing')
  final bool babyChanging;
  @JsonKey(name: 'nursing_friendly')
  final bool nursingFriendly;
  @JsonKey(name: 'kid_menu_available')
  final bool kidMenuAvailable;
  @JsonKey(name: 'educational_content')
  final bool educationalContent;
  final String? notes;

  const FamilySuitability({
    this.minAge,
    this.maxAge,
    this.recommendedAgeRange,
    required this.strollerFriendly,
    required this.babyChanging,
    required this.nursingFriendly,
    required this.kidMenuAvailable,
    required this.educationalContent,
    this.notes,
  });

  factory FamilySuitability.fromJson(Map<String, dynamic> json) {
    return FamilySuitability(
      minAge: json['min_age'],
      maxAge: json['max_age'],
      recommendedAgeRange: json['recommended_age_range'],
      strollerFriendly: json['stroller_friendly'] ?? false,
      babyChanging: json['baby_changing'] ?? false,
      nursingFriendly: json['nursing_friendly'] ?? false,
      kidMenuAvailable: json['kid_menu_available'] ?? false,
      educationalContent: json['educational_content'] ?? false,
      notes: json['notes'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'min_age': minAge,
      'max_age': maxAge,
      'recommended_age_range': recommendedAgeRange,
      'stroller_friendly': strollerFriendly,
      'baby_changing': babyChanging,
      'nursing_friendly': nursingFriendly,
      'kid_menu_available': kidMenuAvailable,
      'educational_content': educationalContent,
      'notes': notes,
    };
  }

  bool get isAllAges => minAge == null && maxAge == null;
  
  bool get isBabyFriendly => minAge == null || minAge! <= 2;
  
  bool get isToddlerFriendly => minAge == null || minAge! <= 5;
}

/// Organizer information
@JsonSerializable()
class OrganizerInfo {
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;
  @JsonKey(name: 'social_media')
  final Map<String, String>? socialMedia;
  @JsonKey(name: 'verification_status')
  final String verificationStatus;

  const OrganizerInfo({
    required this.name,
    this.description,
    this.phone,
    this.email,
    this.website,
    this.socialMedia,
    required this.verificationStatus,
  });

  factory OrganizerInfo.fromJson(Map<String, dynamic> json) {
    return OrganizerInfo(
      name: json['name'] ?? '',
      description: json['description'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      socialMedia: json['social_media'] != null ? Map<String, String>.from(json['social_media']) : null,
      verificationStatus: json['verification_status'] ?? 'pending',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'phone': phone,
      'email': email,
      'website': website,
      'social_media': socialMedia,
      'verification_status': verificationStatus,
    };
  }

  bool get isVerified => verificationStatus == 'verified';
}

/// Events response wrapper
@JsonSerializable()
class EventsResponse {
  final List<Event> events;
  final int total;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  const EventsResponse({
    required this.events,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      events: (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      totalPages: json['total_pages'] ?? 1,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'per_page': perPage,
      'total_pages': totalPages,
    };
  }

  bool get hasMore => page < totalPages;
}

/// Social Media Links model for enhanced extraction
@JsonSerializable()
class SocialMediaLinks {
  final String? instagram;
  final String? facebook;
  final String? twitter;
  final String? tiktok;
  final String? youtube;
  final String? whatsapp;
  final String? telegram;

  const SocialMediaLinks({
    this.instagram,
    this.facebook,
    this.twitter,
    this.tiktok,
    this.youtube,
    this.whatsapp,
    this.telegram,
  });

  factory SocialMediaLinks.fromJson(Map<String, dynamic> json) {
    return SocialMediaLinks(
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      tiktok: json['tiktok'] as String?,
      youtube: json['youtube'] as String?,
      whatsapp: json['whatsapp'] as String?,
      telegram: json['telegram'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'instagram': instagram,
      'facebook': facebook,
      'twitter': twitter,
      'tiktok': tiktok,
      'youtube': youtube,
      'whatsapp': whatsapp,
      'telegram': telegram,
    };
  }

  List<String> get availablePlatforms {
    final platforms = <String>[];
    if (instagram != null) platforms.add('Instagram');
    if (facebook != null) platforms.add('Facebook');
    if (twitter != null) platforms.add('Twitter');
    if (tiktok != null) platforms.add('TikTok');
    if (youtube != null) platforms.add('YouTube');
    if (whatsapp != null) platforms.add('WhatsApp');
    if (telegram != null) platforms.add('Telegram');
    return platforms;
  }

  bool get hasAnyLinks => availablePlatforms.isNotEmpty;
}

/// Quality Metrics model for enhanced extraction
@JsonSerializable()
class QualityMetrics {
  @JsonKey(name: 'extraction_confidence')
  final double extractionConfidence;
  @JsonKey(name: 'data_completeness')
  final double dataCompleteness;
  @JsonKey(name: 'source_reliability')
  final String sourceReliability;
  @JsonKey(name: 'last_verified')
  final String lastVerified;
  @JsonKey(name: 'extraction_method')
  final String extractionMethod;
  @JsonKey(name: 'validation_warnings')
  final List<String> validationWarnings;

  const QualityMetrics({
    required this.extractionConfidence,
    required this.dataCompleteness,
    required this.sourceReliability,
    required this.lastVerified,
    required this.extractionMethod,
    required this.validationWarnings,
  });

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      extractionConfidence: (json['extraction_confidence'] as num).toDouble(),
      dataCompleteness: (json['data_completeness'] as num).toDouble(),
      sourceReliability: json['source_reliability'] as String,
      lastVerified: json['last_verified'] as String,
      extractionMethod: json['extraction_method'] as String,
      validationWarnings: (json['validation_warnings'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'extraction_confidence': extractionConfidence,
      'data_completeness': dataCompleteness,
      'source_reliability': sourceReliability,
      'last_verified': lastVerified,
      'extraction_method': extractionMethod,
      'validation_warnings': validationWarnings,
    };
  }

  /// Get confidence level as text
  String get confidenceLevel {
    if (extractionConfidence >= 0.8) return 'High';
    if (extractionConfidence >= 0.6) return 'Medium';
    return 'Low';
  }

  /// Get completeness level as text
  String get completenessLevel {
    if (dataCompleteness >= 0.8) return 'Complete';
    if (dataCompleteness >= 0.6) return 'Good';
    return 'Basic';
  }

  /// Get overall quality score
  double get overallQuality {
    return (extractionConfidence * 0.6) + (dataCompleteness * 0.4);
  }

  /// Get quality color
  Color get qualityColor {
    final quality = overallQuality;
    if (quality >= 0.8) return Colors.green;
    if (quality >= 0.6) return Colors.orange;
    return Colors.red;
  }

  /// Check if source is reliable
  bool get isReliableSource => sourceReliability == 'high';
  
  /// Check if data has warnings
  bool get hasWarnings => validationWarnings.isNotEmpty;
}

/// Event filter for search and filtering
@JsonSerializable()
class EventsFilter {
  final String? category;
  final String? location;
  final String? area;
  final String? date;
  @JsonKey(name: 'price_min')
  final double? priceMin;
  @JsonKey(name: 'price_max')
  final double? priceMax;
  @JsonKey(name: 'age_min')
  final int? ageMin;
  @JsonKey(name: 'age_max')
  final int? ageMax;
  @JsonKey(name: 'family_friendly')
  final bool? familyFriendly;
  @JsonKey(name: 'free_only')
  final bool? freeOnly;
  @JsonKey(name: 'featured_only')
  final bool? featuredOnly;
  @JsonKey(name: 'has_availability')
  final bool? hasAvailability;
  @JsonKey(name: 'sort_by')
  final String? sortBy;
  @JsonKey(name: 'sort_order')
  final String? sortOrder;

  const EventsFilter({
    this.category,
    this.location,
    this.area,
    this.date,
    this.priceMin,
    this.priceMax,
    this.ageMin,
    this.ageMax,
    this.familyFriendly,
    this.freeOnly,
    this.featuredOnly,
    this.hasAvailability,
    this.sortBy,
    this.sortOrder,
  });

  factory EventsFilter.fromJson(Map<String, dynamic> json) {
    return EventsFilter(
      category: json['category'],
      location: json['location'],
      area: json['area'],
      date: json['date'],
      priceMin: json['price_min']?.toDouble(),
      priceMax: json['price_max']?.toDouble(),
      ageMin: json['age_min'],
      ageMax: json['age_max'],
      familyFriendly: json['family_friendly'],
      freeOnly: json['free_only'],
      featuredOnly: json['featured_only'],
      hasAvailability: json['has_availability'],
      sortBy: json['sort_by'],
      sortOrder: json['sort_order'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'location': location,
      'area': area,
      'date': date,
      'price_min': priceMin,
      'price_max': priceMax,
      'age_min': ageMin,
      'age_max': ageMax,
      'family_friendly': familyFriendly,
      'free_only': freeOnly,
      'featured_only': featuredOnly,
      'has_availability': hasAvailability,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
  }
} 