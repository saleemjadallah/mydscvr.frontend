import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../models/event.dart';

class EventPricingWidget extends StatelessWidget {
  final Pricing pricing;
  final bool isFeatured;

  const EventPricingWidget({
    super.key,
    required this.pricing,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      blur: 6,
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.dollarSign,
                  size: 20,
                  color: AppColors.dubaiGold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Pricing',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Featured',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Main price display
          _buildMainPrice(),
          
          const SizedBox(height: 16),
          
          // Price categories if available
          if (pricing.priceCategories.isNotEmpty) ...[
            _buildPriceCategories(),
            const SizedBox(height: 16),
          ],
          
          // Additional pricing info
          _buildPricingDetails(),
        ],
      ),
    );
  }

  Widget _buildMainPrice() {
    if (pricing.basePrice == 0) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.dubaiTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.dubaiTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.gift,
                  size: 16,
                  color: AppColors.dubaiTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'FREE',
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dubaiTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'From ',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'AED ${pricing.basePrice.toStringAsFixed(0)}',
              style: GoogleFonts.comfortaa(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (pricing.maxPrice != null && pricing.maxPrice! > pricing.basePrice) ...[
              Text(
                ' - ',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'AED ${pricing.maxPrice!.toStringAsFixed(0)}',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        
        if (pricing.currency != 'AED')
          Text(
            'Plus applicable taxes',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildPriceCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Categories',
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        ...pricing.priceCategories.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  entry.value == 0 
                      ? 'Free' 
                      : 'AED ${entry.value.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: entry.value == 0 
                        ? AppColors.dubaiTeal 
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPricingDetails() {
    final details = <Widget>[];
    
    // Currency info
    if (pricing.currency != 'AED') {
      details.add(
        _buildDetailRow(
          LucideIcons.banknote,
          'Currency',
          pricing.currency,
        ),
      );
    }
    
    // Group discounts
    if (pricing.groupDiscounts.isNotEmpty) {
      details.add(
        _buildDetailRow(
          LucideIcons.users,
          'Group Discounts',
          'Available',
          valueColor: AppColors.dubaiTeal,
        ),
      );
    }
    
    // Early bird discount
    if (pricing.earlyBirdDiscount != null && pricing.earlyBirdDiscount! > 0) {
      details.add(
        _buildDetailRow(
          LucideIcons.clock,
          'Early Bird',
          '${pricing.earlyBirdDiscount}% off',
          valueColor: AppColors.dubaiCoral,
        ),
      );
    }
    
    // Refund policy indicator
    details.add(
      _buildDetailRow(
        LucideIcons.shield,
        'Refund Policy',
        pricing.isRefundable ? 'Refundable' : 'Non-refundable',
        valueColor: pricing.isRefundable ? AppColors.dubaiTeal : AppColors.textSecondary,
      ),
    );
    
    if (details.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        const Divider(color: Colors.grey, height: 1),
        const SizedBox(height: 12),
        ...details,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
} 