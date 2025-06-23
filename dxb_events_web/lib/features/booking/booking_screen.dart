import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Core imports
import '../../core/constants/app_colors.dart';
import '../../core/themes/app_typography.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../core/widgets/curved_container.dart';

// Model imports
import '../../models/event.dart';
import '../../models/user.dart';

// Service imports
import '../../services/providers/auth_provider_mongodb.dart';
import '../../services/providers/preferences_provider.dart';

/// Booking state management
class BookingState {
  final int adultTickets;
  final int childTickets;
  final double totalPrice;
  final List<FamilyMember> attendees;
  final bool isLoading;
  final String? error;

  const BookingState({
    this.adultTickets = 1,
    this.childTickets = 0,
    this.totalPrice = 0.0,
    this.attendees = const [],
    this.isLoading = false,
    this.error,
  });

  BookingState copyWith({
    int? adultTickets,
    int? childTickets,
    double? totalPrice,
    List<FamilyMember>? attendees,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      adultTickets: adultTickets ?? this.adultTickets,
      childTickets: childTickets ?? this.childTickets,
      totalPrice: totalPrice ?? this.totalPrice,
      attendees: attendees ?? this.attendees,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Booking notifier
class BookingNotifier extends StateNotifier<BookingState> {
  final Event event;

  BookingNotifier(this.event) : super(const BookingState()) {
    _calculateTotal();
  }

  void updateAdultTickets(int count) {
    state = state.copyWith(adultTickets: count);
    _calculateTotal();
  }

  void updateChildTickets(int count) {
    state = state.copyWith(childTickets: count);
    _calculateTotal();
  }

  void _calculateTotal() {
    final adultPrice = event.pricing.basePrice * state.adultTickets;
    final childPrice = (event.pricing.childPrice ?? event.pricing.basePrice * 0.7) * state.childTickets;
    state = state.copyWith(totalPrice: adultPrice + childPrice);
  }

  Future<void> confirmBooking() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate booking API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, we'll just show success
      // In real app, would call booking API
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Booking failed. Please try again.',
      );
    }
  }
}

/// Booking provider
final bookingProvider = StateNotifierProvider.family<BookingNotifier, BookingState, Event>((ref, event) {
  return BookingNotifier(event);
});

/// Event Booking Screen
class BookingScreen extends ConsumerStatefulWidget {
  final Event event;

  const BookingScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final booking = ref.watch(bookingProvider(widget.event));

    if (!isAuthenticated) {
      return _buildLoginRequired();
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.surface : AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dubaiGold,
        foregroundColor: Colors.white,
        title: Text(
          'Book Event',
          style: AppTypography.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildTicketSelectionStep(),
                _buildAttendeeDetailsStep(),
                _buildPaymentStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          
          // Bottom Navigation
          _buildBottomNavigation(booking),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dubaiGold,
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiGold.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            _buildStepIndicator(
              i + 1,
              i <= _currentStep,
              _getStepTitle(i),
            ),
            if (i < 3) _buildStepConnector(i < _currentStep),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive, String title) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? Icon(
                      step <= _currentStep ? Icons.check : Icons.circle,
                      color: AppColors.dubaiGold,
                      size: 20,
                    )
                  : Text(
                      step.toString(),
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      height: 2,
      width: 20,
      color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 24),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Tickets';
      case 1: return 'Details';
      case 2: return 'Payment';
      case 3: return 'Confirm';
      default: return '';
    }
  }

  Widget _buildTicketSelectionStep() {
    final booking = ref.watch(bookingProvider(widget.event));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Summary
          _buildEventSummary(),
          
          const SizedBox(height: 32),
          
          // Ticket Selection
          Text(
            'Select Tickets',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Adult Tickets
          _buildTicketSelector(
            'Adult Tickets',
            'Ages 18 and above',
            'AED ${widget.event.pricing.basePrice.toStringAsFixed(0)}',
            booking.adultTickets,
            LucideIcons.user,
            (count) => ref.read(bookingProvider(widget.event).notifier).updateAdultTickets(count),
          ),
          
          const SizedBox(height: 16),
          
          // Child Tickets
          if (widget.event.pricing.childPrice != null) ...[
            _buildTicketSelector(
              'Child Tickets',
              'Under 18 years',
              'AED ${widget.event.pricing.childPrice!.toStringAsFixed(0)}',
              booking.childTickets,
              LucideIcons.baby,
              (count) => ref.read(bookingProvider(widget.event).notifier).updateChildTickets(count),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Total Summary
          CurvedContainer(
            padding: const EdgeInsets.all(20),
            backgroundColor: AppColors.dubaiGold.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${booking.adultTickets + booking.childTickets} tickets',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'AED ${booking.totalPrice.toStringAsFixed(0)}',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.dubaiGold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Terms Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.dubaiGold.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.info,
                  size: 20,
                  color: AppColors.dubaiGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Terms',
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tickets are non-refundable. Free cancellation up to 24 hours before the event.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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

  Widget _buildAttendeeDetailsStep() {
    final user = ref.watch(currentUserProvider);
    final familyMembers = ref.watch(familyMembersProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendee Information',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Please provide details for all attendees',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Primary Attendee (User)
          _buildAttendeeCard(
            'Primary Attendee',
            user?.name ?? 'User',
            user?.email ?? '',
            true,
          ),
          
          const SizedBox(height: 16),
          
          // Additional Attendees from Family
          if (familyMembers.isNotEmpty) ...[
            Text(
              'Family Members',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ...familyMembers.take(2).map((member) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAttendeeCard(
                  member.relationship.toUpperCase(),
                  member.name,
                  '${member.age} years old',
                  false,
                ),
              );
            }).toList(),
          ],
          
          const SizedBox(height: 24),
          
          // Special Requirements
          Text(
            'Special Requirements',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          CurvedContainer(
            padding: const EdgeInsets.all(16),
            backgroundColor: AppColors.surfaceVariant,
            child: TextFormField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requirements or dietary restrictions...',
                border: InputBorder.none,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    final booking = ref.watch(bookingProvider(widget.event));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Order Summary
          CurvedContainer(
            padding: const EdgeInsets.all(20),
            backgroundColor: AppColors.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (booking.adultTickets > 0) ...[
                  _buildOrderItem(
                    'Adult Tickets (${booking.adultTickets})',
                    'AED ${(widget.event.pricing.basePrice * booking.adultTickets).toStringAsFixed(0)}',
                  ),
                ],
                
                if (booking.childTickets > 0) ...[
                  _buildOrderItem(
                    'Child Tickets (${booking.childTickets})',
                    'AED ${((widget.event.pricing.childPrice ?? widget.event.pricing.basePrice * 0.7) * booking.childTickets).toStringAsFixed(0)}',
                  ),
                ],
                
                const Divider(),
                
                _buildOrderItem(
                  'Total',
                  'AED ${booking.totalPrice.toStringAsFixed(0)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment Methods
          Text(
            'Payment Method',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildPaymentMethodCard(
            'Credit/Debit Card',
            'Visa, Mastercard, American Express',
            LucideIcons.creditCard,
            true,
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentMethodCard(
            'Apple Pay',
            'Pay with Touch ID or Face ID',
            LucideIcons.smartphone,
            false,
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentMethodCard(
            'Google Pay',
            'Quick and secure payment',
            LucideIcons.wallet,
            false,
          ),
          
          const SizedBox(height: 24),
          
          // Security Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.shield,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your payment information is encrypted and secure',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.checkCircle,
              size: 60,
              color: AppColors.success,
            ),
          ).animate()
            .scale(duration: 600.ms, curve: Curves.bounceOut)
            .fade(),
          
          const SizedBox(height: 32),
          
          Text(
            'Booking Confirmed!',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ).animate()
            .slideY(duration: 500.ms, begin: 0.3)
            .fade(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'Your tickets have been sent to your email',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .slideY(duration: 500.ms, begin: 0.3)
            .fade(delay: 300.ms),
          
          const SizedBox(height: 40),
          
          // Booking Details
          CurvedContainer(
            padding: const EdgeInsets.all(20),
            backgroundColor: AppColors.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Details',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildConfirmationItem(
                  'Booking ID',
                  '#DXB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                ),
                
                _buildConfirmationItem(
                  'Event',
                  widget.event.title,
                ),
                
                _buildConfirmationItem(
                  'Date & Time',
                  _formatDateTime(widget.event.startDate),
                ),
                
                _buildConfirmationItem(
                  'Venue',
                  widget.event.venue.name,
                ),
              ],
            ),
          ).animate()
            .slideY(duration: 500.ms, begin: 0.3)
            .fade(delay: 400.ms),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadTickets(),
                  icon: const Icon(LucideIcons.download),
                  label: const Text('Download Tickets'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dubaiGold,
                    side: const BorderSide(color: AppColors.dubaiGold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.home),
                  label: const Text('Go Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dubaiGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ).animate()
            .slideY(duration: 500.ms, begin: 0.3)
            .fade(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildEventSummary() {
    return CurvedContainer(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceVariant,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.event.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.dubaiGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    color: AppColors.dubaiGold,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(widget.event.startDate),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.event.venue.area,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelector(
    String title,
    String subtitle,
    String price,
    int count,
    IconData icon,
    Function(int) onChanged,
  ) {
    return CurvedContainer(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceVariant,
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.dubaiGold),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.dubaiGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.dubaiGold,
              ),
              Container(
                width: 40,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.dubaiGold),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: count < 10 ? () => onChanged(count + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.dubaiGold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeCard(String title, String name, String info, bool isPrimary) {
    return CurvedContainer(
      padding: const EdgeInsets.all(16),
      backgroundColor: isPrimary 
          ? AppColors.dubaiGold.withOpacity(0.1)
          : AppColors.surfaceVariant,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.dubaiGold,
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  info,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isPrimary) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'PRIMARY',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
                ? AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.bodyMedium,
          ),
          Text(
            amount,
            style: isTotal 
                ? AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.dubaiGold,
                  )
                : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String title, String subtitle, IconData icon, bool isSelected) {
    return CurvedContainer(
      padding: const EdgeInsets.all(16),
      backgroundColor: isSelected 
          ? AppColors.dubaiGold.withOpacity(0.1)
          : AppColors.surfaceVariant,
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? AppColors.dubaiGold : AppColors.textSecondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            onChanged: (value) {},
            activeColor: AppColors.dubaiGold,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BookingState booking) {
    final canProceed = _canProceedToNextStep(booking);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _previousStep(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dubaiGold,
                  side: const BorderSide(color: AppColors.dubaiGold),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: canProceed ? () => _nextStep(booking) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: booking.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dubaiGold,
        foregroundColor: Colors.white,
        title: const Text('Book Event'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.lock,
                size: 80,
                color: AppColors.dubaiGold,
              ),
              const SizedBox(height: 24),
              Text(
                'Sign In Required',
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please sign in to book this event.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.logIn),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dubaiGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  bool _canProceedToNextStep(BookingState booking) {
    switch (_currentStep) {
      case 0: // Ticket selection
        return booking.adultTickets > 0 || booking.childTickets > 0;
      case 1: // Attendee details
        return true; // Always allow for demo
      case 2: // Payment
        return true; // Always allow for demo
      case 3: // Confirmation
        return false; // Final step
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0: return 'Continue';
      case 1: return 'Continue';
      case 2: return 'Confirm Booking';
      case 3: return 'Done';
      default: return 'Next';
    }
  }

  void _nextStep(BookingState booking) {
    if (_currentStep < 3) {
      if (_currentStep == 2) {
        // Trigger booking confirmation
        ref.read(bookingProvider(widget.event).notifier).confirmBooking().then((_) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day at $hour:$minute';
  }

  void _downloadTickets() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tickets downloaded successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
} 