import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../onboarding_controller.dart';

class InterestsStep extends ConsumerStatefulWidget {
  const InterestsStep({Key? key}) : super(key: key);
  
  @override
  ConsumerState<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends ConsumerState<InterestsStep> {
  List<String> _selectedInterests = [];
  
  final List<Map<String, dynamic>> _interestCategories = [
    {
      'title': 'Activities',
      'color': AppColors.dubaiTeal,
      'interests': [
        {'name': 'Outdoor Adventures', 'icon': Icons.hiking},
        {'name': 'Sports Events', 'icon': Icons.sports_soccer},
        {'name': 'Swimming & Water Sports', 'icon': Icons.pool},
        {'name': 'Arts & Crafts', 'icon': Icons.color_lens},
        {'name': 'Music & Dance', 'icon': Icons.music_note},
        {'name': 'Yoga & Fitness', 'icon': Icons.self_improvement},
      ],
    },
    {
      'title': 'Learning',
      'color': AppColors.dubaiCoral,
      'interests': [
        {'name': 'Educational Workshops', 'icon': Icons.school},
        {'name': 'Science & Technology', 'icon': Icons.science},
        {'name': 'Cultural Experiences', 'icon': Icons.language},
        {'name': 'Museums & Exhibitions', 'icon': Icons.museum},
        {'name': 'Reading & Storytelling', 'icon': Icons.book},
        {'name': 'Cooking Classes', 'icon': Icons.restaurant_menu},
      ],
    },
    {
      'title': 'Entertainment',
      'color': AppColors.dubaiGold,
      'interests': [
        {'name': 'Theme Parks', 'icon': Icons.attractions},
        {'name': 'Movies & Shows', 'icon': Icons.movie},
        {'name': 'Gaming & Arcades', 'icon': Icons.sports_esports},
        {'name': 'Comedy Shows', 'icon': Icons.theater_comedy},
        {'name': 'Live Performances', 'icon': Icons.mic},
        {'name': 'Festivals', 'icon': Icons.celebration},
      ],
    },
    {
      'title': 'Nature & Animals',
      'color': Colors.green,
      'interests': [
        {'name': 'Parks & Gardens', 'icon': Icons.park},
        {'name': 'Beaches', 'icon': Icons.beach_access},
        {'name': 'Wildlife & Zoos', 'icon': Icons.pets},
        {'name': 'Desert Activities', 'icon': Icons.terrain},
        {'name': 'Boating & Fishing', 'icon': Icons.sailing},
        {'name': 'Nature Walks', 'icon': Icons.directions_walk},
      ],
    },
    {
      'title': 'Food & Shopping',
      'color': Colors.orange,
      'interests': [
        {'name': 'Food Festivals', 'icon': Icons.fastfood},
        {'name': 'Shopping Experiences', 'icon': Icons.shopping_bag},
        {'name': 'Local Markets', 'icon': Icons.store},
        {'name': 'Dining Experiences', 'icon': Icons.restaurant},
        {'name': 'Cafes & Desserts', 'icon': Icons.cake},
        {'name': 'Food Tours', 'icon': Icons.tour},
      ],
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with any existing preferences
    final existingInterests = ref.read(onboardingProvider).preferences['interests'] as List<String>?;
    if (existingInterests != null) {
      _selectedInterests = List.from(existingInterests);
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
            'What do you enjoy?',
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            'Select activities your family loves to do together',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 24),
          
          // Selected interests count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.dubaiTeal.withOpacity(0.1),
                  AppColors.dubaiCoral.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.dubaiTeal.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiTeal,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${_selectedInterests.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedInterests.length < 3
                        ? 'Select at least 3 interests (${3 - _selectedInterests.length} more needed)'
                        : 'Great! ${_selectedInterests.length} interests selected',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedInterests.length < 3 
                          ? Colors.orange.shade700
                          : AppColors.dubaiTeal,
                    ),
                  ),
                ),
                if (_selectedInterests.length >= 3)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.dubaiTeal,
                    size: 20,
                  ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 32),
          
          // Categories
          ..._interestCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return _buildCategorySection(
              category['title'] as String,
              category['interests'] as List<Map<String, dynamic>>,
              category['color'] as Color,
              index,
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildCategorySection(
    String title, 
    List<Map<String, dynamic>> interests, 
    Color categoryColor,
    int categoryIndex,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(title),
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ).animate(delay: Duration(milliseconds: 400 + (categoryIndex * 100)))
           .fadeIn(duration: 400.ms)
           .slideX(begin: -20, end: 0),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: interests.asMap().entries.map((entry) {
              final index = entry.key;
              final interest = entry.value;
              final interestName = interest['name'] as String;
              final isSelected = _selectedInterests.contains(interestName);
              
              return GestureDetector(
                onTap: () => _toggleInterest(interestName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? categoryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? categoryColor
                          : categoryColor.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? categoryColor.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 8 : 4,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        interest['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : categoryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        interestName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 500 + (categoryIndex * 100) + (index * 50)))
               .fadeIn(duration: 400.ms)
               .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0));
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  void _toggleInterest(String interestName) {
    setState(() {
      if (_selectedInterests.contains(interestName)) {
        _selectedInterests.remove(interestName);
      } else {
        _selectedInterests.add(interestName);
      }
    });
    
    // Update preferences
    ref.read(onboardingProvider.notifier).updatePreference(
      'interests',
      _selectedInterests,
    );
    
    // Haptic feedback would be nice here on mobile
    // HapticFeedback.lightImpact();
  }
  
  IconData _getCategoryIcon(String title) {
    switch (title.toLowerCase()) {
      case 'activities':
        return Icons.directions_run;
      case 'learning':
        return Icons.school;
      case 'entertainment':
        return Icons.celebration;
      case 'nature & animals':
        return Icons.nature;
      case 'food & shopping':
        return Icons.shopping_cart;
      default:
        return Icons.star;
    }
  }
}