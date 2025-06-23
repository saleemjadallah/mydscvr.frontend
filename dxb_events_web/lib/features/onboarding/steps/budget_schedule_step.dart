import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../onboarding_controller.dart';

class BudgetScheduleStep extends ConsumerStatefulWidget {
  const BudgetScheduleStep({Key? key}) : super(key: key);
  
  @override
  ConsumerState<BudgetScheduleStep> createState() => _BudgetScheduleStepState();
}

class _BudgetScheduleStepState extends ConsumerState<BudgetScheduleStep> {
  RangeValues _priceRange = const RangeValues(0, 500);
  List<String> _selectedDays = [];
  String _selectedTimePreference = 'Afternoon';
  
  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
    'Friday', 'Saturday', 'Sunday'
  ];
  
  final List<Map<String, dynamic>> _timePreferences = [
    {
      'name': 'Morning',
      'description': '8 AM - 12 PM',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'name': 'Afternoon',
      'description': '12 PM - 4 PM',
      'icon': Icons.wb_sunny_outlined,
      'color': AppColors.dubaiGold,
    },
    {
      'name': 'Evening',
      'description': '4 PM - 8 PM',
      'icon': Icons.wb_twilight,
      'color': AppColors.dubaiCoral,
    },
    {
      'name': 'Night',
      'description': 'After 8 PM',
      'icon': Icons.nightlight,
      'color': AppColors.dubaiTeal,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with any existing preferences
    final existingMinPrice = ref.read(onboardingProvider).preferences['minPrice'] as double?;
    final existingMaxPrice = ref.read(onboardingProvider).preferences['maxPrice'] as double?;
    
    if (existingMinPrice != null && existingMaxPrice != null) {
      _priceRange = RangeValues(existingMinPrice, existingMaxPrice);
    }
    
    final existingDays = ref.read(onboardingProvider).preferences['preferredDays'] as List<String>?;
    if (existingDays != null) {
      _selectedDays = List.from(existingDays);
    } else {
      // Default to weekends
      _selectedDays = ['Friday', 'Saturday'];
    }
    
    final existingTime = ref.read(onboardingProvider).preferences['preferredTime'] as String?;
    if (existingTime != null) {
      _selectedTimePreference = existingTime;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget & Availability',
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            'Tell us about your budget and when you\'re available',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 32),
          
          // Budget section
          _buildBudgetSection().animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 32),
          
          // Days section
          _buildDaysSection().animate().fadeIn(delay: 500.ms),
          
          const SizedBox(height: 32),
          
          // Time preference section
          _buildTimePreferenceSection().animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
  
  Widget _buildBudgetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiGold.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiGold.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.attach_money,
                  color: AppColors.dubaiGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Event Budget',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'What\'s your budget range for family events? (AED)',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AED ${_priceRange.start.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dubaiGold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AED ${_priceRange.end.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dubaiGold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.dubaiGold,
            labels: RangeLabels(
              'AED ${_priceRange.start.round()}',
              'AED ${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
              
              // Update preferences
              ref.read(onboardingProvider.notifier).updatePreference(
                'minPrice',
                _priceRange.start,
              );
              
              ref.read(onboardingProvider.notifier).updatePreference(
                'maxPrice',
                _priceRange.end,
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Free',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'AED 1,000+',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Budget insights
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.dubaiGold.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.dubaiGold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getBudgetInsight(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.dubaiGold,
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
  
  Widget _buildDaysSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiTeal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppColors.dubaiTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferred Days',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_selectedDays.length} days selected',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daysOfWeek.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isSelected = _selectedDays.contains(day);
              final isWeekend = day == 'Friday' || day == 'Saturday';
              
              return GestureDetector(
                onTap: () => _toggleDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.dubaiTeal
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.dubaiTeal
                          : (isWeekend ? AppColors.dubaiCoral.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? AppColors.dubaiTeal.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 6 : 2,
                        offset: Offset(0, isSelected ? 3 : 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.substring(0, 3).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (isWeekend) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.dubaiCoral,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: index * 100))
               .fadeIn(duration: 300.ms)
               .scale(begin: const Offset(0.8, 0.8));
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimePreferenceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiCoral.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiCoral.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiCoral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.dubaiCoral,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Preferred Time',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'What time of day works best for your family?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Column(
            children: _timePreferences.asMap().entries.map((entry) {
              final index = entry.key;
              final timeOption = entry.value;
              final timeName = timeOption['name'] as String;
              final isSelected = _selectedTimePreference == timeName;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (timeOption['color'] as Color).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (timeOption['color'] as Color)
                        : Colors.grey.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(
                        timeOption['icon'] as IconData,
                        color: isSelected 
                            ? (timeOption['color'] as Color)
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timeName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                              ? (timeOption['color'] as Color)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      timeOption['description'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  value: timeName,
                  groupValue: _selectedTimePreference,
                  activeColor: timeOption['color'] as Color,
                  onChanged: (value) {
                    setState(() {
                      _selectedTimePreference = value!;
                    });
                    
                    // Update preferences
                    ref.read(onboardingProvider.notifier).updatePreference(
                      'preferredTime',
                      _selectedTimePreference,
                    );
                  },
                ),
              ).animate(delay: Duration(milliseconds: index * 150))
               .fadeIn(duration: 400.ms)
               .slideX(begin: 20, end: 0);
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
    
    // Update preferences
    ref.read(onboardingProvider.notifier).updatePreference(
      'preferredDays',
      _selectedDays,
    );
  }
  
  String _getBudgetInsight() {
    final minPrice = _priceRange.start;
    final maxPrice = _priceRange.end;
    
    if (maxPrice == 0) {
      return 'Great! You\'ll see only free events and activities.';
    } else if (maxPrice <= 100) {
      return 'Perfect for budget-friendly family activities and local events.';
    } else if (maxPrice <= 300) {
      return 'Good range for most family activities and mid-range experiences.';
    } else if (maxPrice <= 600) {
      return 'Allows for premium experiences and special family outings.';
    } else {
      return 'Opens up luxury experiences and exclusive family events.';
    }
  }
}