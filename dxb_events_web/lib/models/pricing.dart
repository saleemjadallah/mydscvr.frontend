import 'package:json_annotation/json_annotation.dart';

part 'pricing.g.dart';

/// Pricing model for event costs and ticket information
@JsonSerializable()
class Pricing {
  @JsonKey(name: 'min_price')
  final double minPrice;
  @JsonKey(name: 'max_price')
  final double maxPrice;
  final String currency;
  @JsonKey(name: 'price_description')
  final String? priceDescription;
  @JsonKey(name: 'early_bird_price')
  final double? earlyBirdPrice;
  @JsonKey(name: 'group_discount_available')
  final bool? groupDiscountAvailable;
  @JsonKey(name: 'family_package_price')
  final double? familyPackagePrice;

  const Pricing({
    required this.minPrice,
    required this.maxPrice,
    this.currency = 'AED',
    this.priceDescription,
    this.earlyBirdPrice,
    this.groupDiscountAvailable,
    this.familyPackagePrice,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) => _$PricingFromJson(json);
  Map<String, dynamic> toJson() => _$PricingToJson(this);

  /// Helper methods for UI
  bool get isFree => minPrice == 0;
  bool get isPaid => minPrice > 0;
  bool get hasRange => minPrice != maxPrice;
  bool get hasFamilyPackage => familyPackagePrice != null;
  bool get hasEarlyBird => earlyBirdPrice != null;

  /// Get formatted price string for display
  String get formattedPrice {
    if (isFree) return 'FREE';
    
    if (hasRange) {
      return '$currency ${minPrice.toInt()} - ${maxPrice.toInt()}';
    } else {
      return '$currency ${minPrice.toInt()}';
    }
  }

  /// Get price display with early bird info
  String get fullPriceDisplay {
    String basePrice = formattedPrice;
    
    if (hasEarlyBird && !isFree) {
      basePrice += ' (Early Bird: $currency ${earlyBirdPrice!.toInt()})';
    }
    
    return basePrice;
  }
} 