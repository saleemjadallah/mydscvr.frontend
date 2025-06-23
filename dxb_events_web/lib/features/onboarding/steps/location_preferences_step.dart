import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../onboarding_controller.dart';

class LocationPreferencesStep extends ConsumerStatefulWidget {
  const LocationPreferencesStep({Key? key}) : super(key: key);
  
  @override
  ConsumerState<LocationPreferencesStep> createState() => _LocationPreferencesStepState();
}

class _LocationPreferencesStepState extends ConsumerState<LocationPreferencesStep> {
  List<String> _selectedLocations = [];
  double _maxTravelDistance = 20.0; // km
  
  final List<Map<String, dynamic>> _dubaiAreas = [
    {
      'name': 'Dubai Marina',
      'icon': Icons.sailing,
      'description': 'Waterfront dining & entertainment',
      'color': Colors.blue,
    },
    {
      'name': 'JBR (Jumeirah Beach Residence)',
      'icon': Icons.beach_access,
      'description': 'Beach activities & family fun',
      'color': Colors.cyan,
    },
    {
      'name': 'Downtown Dubai',
      'icon': Icons.location_city,
      'description': 'Shopping, dining & attractions',
      'color': AppColors.dubaiTeal,
    },
    {
      'name': 'Palm Jumeirah',
      'icon': Icons.terrain,
      'description': 'Luxury resorts & experiences',
      'color': Colors.orange,
    },
    {
      'name': 'Jumeirah',
      'icon': Icons.villa,
      'description': 'Cultural sites & beaches',
      'color': Colors.pink,
    },
    {
      'name': 'Business Bay',
      'icon': Icons.business,
      'description': 'Modern attractions & dining',
      'color': Colors.purple,
    },
    {
      'name': 'Dubai Hills',
      'icon': Icons.landscape,
      'description': 'Family-friendly community',
      'color': Colors.green,
    },
    {
      'name': 'Arabian Ranches',
      'icon': Icons.home,
      'description': 'Suburban family activities',
      'color': Colors.brown,
    },
    {
      'name': 'Al Barsha',
      'icon': Icons.apartment,
      'description': 'Shopping & entertainment hubs',
      'color': Colors.indigo,
    },
    {
      'name': 'Mirdif',
      'icon': Icons.house,
      'description': 'Family parks & activities',
      'color': Colors.teal,
    },
    {
      'name': 'Dubai Silicon Oasis',
      'icon': Icons.computer,
      'description': 'Tech hub with family venues',
      'color': Colors.grey,
    },
    {
      'name': 'Dubai Festival City',
      'icon': Icons.celebration,
      'description': 'Shopping & entertainment',
      'color': Colors.red,
    },
    {
      'name': 'Motor City',
      'icon': Icons.directions_car,
      'description': 'Automotive theme & sports',
      'color': Colors.orange,
    },
    {
      'name': 'Dubai Creek',
      'icon': Icons.water,
      'description': 'Historical & cultural area',
      'color': Colors.blue,
    },
    {
      'name': 'Deira',
      'icon': Icons.store,
      'description': 'Traditional markets & culture',
      'color': Colors.amber,
    },
    {
      'name': 'DIFC',
      'icon': Icons.attach_money,
      'description': 'Financial district dining',
      'color': Colors.green,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with any existing preferences
    final existingLocations = ref.read(onboardingProvider).preferences['preferredLocations'] as List<String>?;
    if (existingLocations != null) {
      _selectedLocations = List.from(existingLocations);
    }
    
    final existingDistance = ref.read(onboardingProvider).preferences['maxTravelDistance'] as double?;
    if (existingDistance != null) {
      _maxTravelDistance = existingDistance;
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
            'Where in Dubai?',
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            'Select areas in Dubai where you prefer to attend events',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 32),
          
          // Map visualization placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.dubaiTeal.withOpacity(0.1),
                  AppColors.dubaiCoral.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.dubaiTeal.withOpacity(0.2),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 48,
                        color: AppColors.dubaiTeal.withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dubai Events Map',
                        style: GoogleFonts.comfortaa(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dubaiTeal,
                        ),
                      ),
                      Text(
                        'Discover events across the city',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Decorative location pins
                Positioned(
                  left: 30,
                  top: 40,
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.dubaiCoral,
                    size: 20,
                  ),
                ),
                Positioned(
                  right: 50,
                  top: 60,
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.dubaiGold,
                    size: 20,
                  ),
                ),
                Positioned(
                  left: 100,
                  bottom: 40,
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.dubaiTeal,
                    size: 20,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 500.ms,
          ),
          
          const SizedBox(height: 32),
          
          // Max travel distance
          _buildTravelDistanceSection(),
          
          const SizedBox(height: 32),
          
          // Dubai areas
          _buildAreasSection(),
        ],
      ),
    );
  }
  
  Widget _buildTravelDistanceSection() {
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  Icons.directions_car,
                  color: AppColors.dubaiTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Maximum Travel Distance',
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
            'How far are you willing to travel for events?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 km',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '50 km',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.dubaiTeal,
              thumbColor: AppColors.dubaiTeal,
              overlayColor: AppColors.dubaiTeal.withOpacity(0.2),
              valueIndicatorColor: AppColors.dubaiTeal,
            ),
            child: Slider(
              value: _maxTravelDistance,
              min: 5,
              max: 50,
              divisions: 9,
              label: '${_maxTravelDistance.toInt()} km',
              onChanged: (value) {
                setState(() {
                  _maxTravelDistance = value;
                });
                
                // Update preferences
                ref.read(onboardingProvider.notifier).updatePreference(
                  'maxTravelDistance',
                  _maxTravelDistance,
                );
              },
            ),
          ),
          
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_maxTravelDistance.toInt()} kilometers',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dubaiTeal,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
  
  Widget _buildAreasSection() {
    return Column(
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
                Icons.location_city,
                color: AppColors.dubaiCoral,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferred Areas',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_selectedLocations.length} areas selected',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _dubaiAreas.length,
          itemBuilder: (context, index) {
            final area = _dubaiAreas[index];
            final areaName = area['name'] as String;
            final isSelected = _selectedLocations.contains(areaName);
            
            return GestureDetector(
              onTap: () => _toggleLocation(areaName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (area['color'] as Color).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? (area['color'] as Color)
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                          ? (area['color'] as Color).withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 8 : 4,
                      offset: Offset(0, isSelected ? 4 : 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      area['icon'] as IconData,
                      size: 32,
                      color: isSelected 
                          ? (area['color'] as Color)
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      areaName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? (area['color'] as Color)
                            : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      area['description'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Icon(
                        Icons.check_circle,
                        color: area['color'] as Color,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 600 + (index * 50)))
             .fadeIn(duration: 400.ms)
             .scale(begin: const Offset(0.8, 0.8));
          },
        ),
      ],
    );
  }
  
  void _toggleLocation(String areaName) {
    setState(() {
      if (_selectedLocations.contains(areaName)) {
        _selectedLocations.remove(areaName);
      } else {
        _selectedLocations.add(areaName);
      }
    });
    
    // Update preferences
    ref.read(onboardingProvider.notifier).updatePreference(
      'preferredLocations',
      _selectedLocations,
    );
  }
}