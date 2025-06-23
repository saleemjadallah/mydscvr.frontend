import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../onboarding_controller.dart';

class FamilySetupStep extends ConsumerStatefulWidget {
  const FamilySetupStep({Key? key}) : super(key: key);
  
  @override
  ConsumerState<FamilySetupStep> createState() => _FamilySetupStepState();
}

class _FamilySetupStepState extends ConsumerState<FamilySetupStep> {
  final _nameController = TextEditingController();
  int _selectedAge = 30;
  String _selectedRelationship = 'Parent';
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final familyMembers = ref.watch(familyMembersProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Your Family Profile',
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 8),
          
          Text(
            'Add family members to personalize event recommendations',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 32),
          
          // Family members list
          if (familyMembers.isNotEmpty) ...[
            Text(
              'Family Members',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 16),
            
            ...familyMembers.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return _buildFamilyMemberCard(member, index);
            }),
            
            const SizedBox(height: 24),
          ],
          
          // Add new member form
          _buildAddMemberForm(),
        ],
      ),
    );
  }
  
  Widget _buildFamilyMemberCard(FamilyMember member, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(member.name, member.avatarSeed),
          
          const SizedBox(width: 16),
          
          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRelationshipColor(member.relationship).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.relationship,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getRelationshipColor(member.relationship),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${member.age} years old',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Delete button
          IconButton(
            onPressed: () {
              ref.read(onboardingProvider.notifier).removeFamilyMember(member.id);
            },
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade400,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 400 + (index * 100)))
     .fadeIn(duration: 500.ms)
     .slideX(begin: 20, end: 0, curve: Curves.easeOutBack);
  }
  
  Widget _buildAddMemberForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dubaiTeal.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  Icons.person_add,
                  color: AppColors.dubaiTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Add Family Member',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Enter family member name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.dubaiTeal),
              ),
              prefixIcon: Icon(
                Icons.person,
                color: AppColors.dubaiTeal,
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Age slider
          Text(
            'Age: $_selectedAge years',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.dubaiTeal,
              thumbColor: AppColors.dubaiTeal,
              overlayColor: AppColors.dubaiTeal.withOpacity(0.2),
              valueIndicatorColor: AppColors.dubaiTeal,
            ),
            child: Slider(
              value: _selectedAge.toDouble(),
              min: 0,
              max: 80,
              divisions: 80,
              label: _selectedAge.toString(),
              onChanged: (value) {
                setState(() {
                  _selectedAge = value.toInt();
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Relationship dropdown
          DropdownButtonFormField<String>(
            value: _selectedRelationship,
            decoration: InputDecoration(
              labelText: 'Relationship',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.dubaiTeal),
              ),
              prefixIcon: Icon(
                Icons.family_restroom,
                color: AppColors.dubaiTeal,
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            items: ['Parent', 'Child', 'Grandparent', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRelationship = value!;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addFamilyMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Add Member',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(
      begin: 20,
      end: 0,
      duration: 500.ms,
      curve: Curves.easeOutBack,
    );
  }
  
  void _addFamilyMember() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final uuid = const Uuid();
    final member = FamilyMember(
      id: uuid.v4(),
      name: _nameController.text.trim(),
      age: _selectedAge,
      relationship: _selectedRelationship,
      avatarSeed: _nameController.text.trim(), // Use name as seed for avatar
    );
    
    ref.read(onboardingProvider.notifier).addFamilyMember(member);
    _nameController.clear();
    setState(() {
      _selectedAge = 30;
      _selectedRelationship = 'Parent';
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.name} added to your family!'),
        backgroundColor: AppColors.dubaiTeal,
      ),
    );
  }
  
  Widget _buildAvatar(String name, String? seed) {
    // Using Dicebear Avatars API for beautiful, diverse avatars
    final avatarUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=${seed ?? name}';
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.dubaiTeal.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.dubaiTeal.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              backgroundColor: AppColors.dubaiTeal,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Color _getRelationshipColor(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'parent':
        return AppColors.dubaiTeal;
      case 'child':
        return AppColors.dubaiCoral;
      case 'grandparent':
        return AppColors.dubaiGold;
      default:
        return Colors.grey;
    }
  }
}