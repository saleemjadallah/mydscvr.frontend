import 'package:json_annotation/json_annotation.dart';

part 'venue.g.dart';

/// Venue model for Dubai event locations with amenities and location data
@JsonSerializable()
class Venue {
  final String name;
  final String address;
  final String area;
  final double? latitude;
  final double? longitude;
  final List<String> amenities;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  final String? website;
  @JsonKey(name: 'parking_available')
  final bool? parkingAvailable;
  @JsonKey(name: 'wheelchair_accessible')
  final bool? wheelchairAccessible;
  @JsonKey(name: 'public_transport_nearby')
  final bool? publicTransportNearby;

  const Venue({
    required this.name,
    required this.address,
    required this.area,
    this.latitude,
    this.longitude,
    required this.amenities,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.parkingAvailable,
    this.wheelchairAccessible,
    this.publicTransportNearby,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
  Map<String, dynamic> toJson() => _$VenueToJson(this);

  /// Helper methods for UI
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasContact => contactPhone != null || contactEmail != null;
  
  /// Get formatted amenities list for display
  String get amenitiesText => amenities.join(', ');
  
  /// Check if venue has specific amenity
  bool hasAmenity(String amenity) {
    return amenities.any((a) => a.toLowerCase().contains(amenity.toLowerCase()));
  }
} 