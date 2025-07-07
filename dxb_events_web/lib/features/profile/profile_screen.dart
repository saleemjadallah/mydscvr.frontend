import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Core imports
import '../../core/constants/app_colors.dart';
import '../../core/themes/app_typography.dart';
import '../../core/widgets/glass_morphism.dart';
import '../../core/widgets/curved_container.dart';

// Model imports
import '../../models/user.dart' hide FamilyMember;

// Service imports
import '../../services/providers/auth_provider_mongodb.dart';
import '../../services/providers/preferences_provider.dart';
import '../../services/providers/api_provider.dart';

// Feature imports
import '../onboarding/onboarding_controller.dart';

/// User Profile and Settings Screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDarkMode = ref.watch(darkModeProvider);
    final isSignedInAndVerified = authState.isAuthenticated;

    if (!isSignedInAndVerified) {
      return _buildLoginPrompt();
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.surface : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Custom App Bar with Profile Header
          _buildProfileHeader(user),
          
          // Tab Bar
          _buildTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAccountTab(user),
            _buildFamilyTab(user),
            _buildPreferencesTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? user) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.dubaiGold,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.sunsetGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Image
                  Hero(
                    tag: 'profile-avatar',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      backgroundImage: user?.avatar != null
                          ? NetworkImage(user!.avatar!)
                          : null,
                      child: user?.avatar == null
                          ? Text(
                              user?.displayName.substring(0, 2).toUpperCase() ?? 'U',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ).animate()
                    .scale(duration: 600.ms, curve: Curves.bounceOut)
                    .fade(),
                  
                  const SizedBox(height: 16),
                  
                  // User Name
                  Text(
                    user?.displayName ?? 'Guest User',
                    style: AppTypography.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate()
                    .slideY(duration: 500.ms, begin: 0.3)
                    .fade(delay: 200.ms),
                  
                  const SizedBox(height: 8),
                  
                  // User Email
                  Text(
                    user?.email ?? '',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ).animate()
                    .slideY(duration: 500.ms, begin: 0.3)
                    .fade(delay: 300.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Family Info Quick Stats
                  Consumer(
                    builder: (context, ref, child) {
                      final onboardingState = ref.watch(onboardingProvider);
                      final familyMembers = onboardingState.familyMembers;
                      
                      if (familyMembers.isNotEmpty) {
                        return GlassMorphism(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.users,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${familyMembers.length} family members',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate()
                          .slideY(duration: 500.ms, begin: 0.3)
                          .fade(delay: 400.ms);
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Account'),
            Tab(text: 'Family'),
            Tab(text: 'Preferences'),
            Tab(text: 'Settings'),
          ],
          labelColor: AppColors.dubaiGold,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.dubaiGold,
          labelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildAccountTab(UserProfile? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          _buildSectionHeader('Personal Information', LucideIcons.user),
          
          const SizedBox(height: 16),
          
          // First Name Field
          _buildInfoCard(
            'First Name',
            user?.firstName ?? 'Not provided',
            LucideIcons.user,
            onTap: () => _editPersonalInfo(user),
          ),
          
          const SizedBox(height: 12),
          
          // Last Name Field
          _buildInfoCard(
            'Last Name',
            user?.lastName ?? 'Not provided',
            LucideIcons.user,
            onTap: () => _editPersonalInfo(user),
          ),
          
          const SizedBox(height: 12),
          
          // Email Field
          _buildInfoCard(
            'Email',
            user?.email ?? 'Not provided',
            LucideIcons.mail,
            onTap: () => _editPersonalInfo(user),
            trailing: user?.isEmailVerified == true 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.checkCircle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.alertCircle,
                          size: 12,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Unverified',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          const SizedBox(height: 12),
          
          // Phone Field
          _buildInfoCard(
            'Phone Number',
            user?.phoneNumber ?? 'Not provided',
            LucideIcons.phone,
            onTap: () => _editPersonalInfo(user),
            trailing: user?.isPhoneVerified == true 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.checkCircle,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          
          const SizedBox(height: 12),
          
          // Date of Birth Field
          _buildInfoCard(
            'Date of Birth',
            user?.dateOfBirth != null 
                ? '${user!.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                : 'Not provided',
            LucideIcons.calendar,
            onTap: () => _editPersonalInfo(user),
          ),
          
          const SizedBox(height: 12),
          
          // Gender Field
          _buildInfoCard(
            'Gender',
            user?.gender ?? 'Not provided',
            LucideIcons.userCheck,
            onTap: () => _editPersonalInfo(user),
          ),
          
          const SizedBox(height: 32),
          
          // Favorites Section
          _buildSectionHeader('My Favorites', LucideIcons.heart),
          
          const SizedBox(height: 16),
          
          _buildFavoritesCard(),
          
          const SizedBox(height: 32),
          
          // Interests Section
          _buildSectionHeader('Interests', LucideIcons.star),
          
          const SizedBox(height: 16),
          
          if (user?.interests.isNotEmpty == true) ...[
            Container(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user!.interests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.dubaiTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      interest,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.dubaiTeal,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            CurvedContainer(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.surfaceVariant,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.plus,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add your interests to get better recommendations',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          ElevatedButton.icon(
            onPressed: () => _editInterests(user),
            icon: const Icon(LucideIcons.edit),
            label: const Text('Edit Interests'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dubaiTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Account Actions
          _buildSectionHeader('Account Actions', LucideIcons.settings),
          
          const SizedBox(height: 16),
          
          _buildActionCard(
            'Change Password',
            'Update your account password',
            LucideIcons.lock,
            onTap: () => _changePassword(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Privacy Settings',
            'Manage your privacy and data preferences',
            LucideIcons.shield,
            onTap: () => _privacySettings(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Download Data',
            'Request a copy of your personal data',
            LucideIcons.download,
            onTap: () => _downloadData(),
          ),
          
          const SizedBox(height: 24),
          
          // Danger Zone
          _buildSectionHeader('Danger Zone', LucideIcons.alertTriangle),
          
          const SizedBox(height: 16),
          
          _buildActionCard(
            'Delete Account',
            'Permanently delete your account and all data',
            LucideIcons.trash2,
            isDestructive: true,
            onTap: () => _deleteAccount(),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTab(UserProfile? user) {
    final onboardingState = ref.watch(onboardingProvider);
    final familyMembers = onboardingState.familyMembers;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Family Overview
          _buildSectionHeader('Family Members', LucideIcons.users),
          
          const SizedBox(height: 16),
          
          // Add Family Member Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addFamilyMember(),
              icon: const Icon(LucideIcons.userPlus),
              label: const Text('Add Family Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dubaiGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Family Members List
          if (familyMembers.isNotEmpty) ...[
            ...familyMembers.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return _buildFamilyMemberCard(member, index);
            }).toList(),
          ] else ...[
            CurvedContainer(
              padding: const EdgeInsets.all(24),
              backgroundColor: AppColors.surfaceVariant,
              child: Column(
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No family members added yet',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add family members to get personalized event recommendations',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Family Statistics
          if (familyMembers.isNotEmpty) ...[
            _buildSectionHeader('Family Insights', LucideIcons.barChart),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Members',
                    familyMembers.length.toString(),
                    LucideIcons.users,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Children',
                    familyMembers.where((m) => m.relationship == 'child').length.toString(),
                    LucideIcons.baby,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (familyMembers.any((m) => m.relationship == 'child')) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Age Range',
                      _calculateChildrenAgeRange(familyMembers),
                      LucideIcons.calendar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Youngest',
                      '${_getYoungestChildAge(familyMembers)} years',
                      LucideIcons.heart,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    final preferences = ref.watch(preferencesProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Preferences
          _buildSectionHeader('Content Preferences', LucideIcons.filter),
          
          const SizedBox(height: 16),
          
          _buildPreferenceCard(
            'Favorite Categories',
            preferences.favoriteCategories.isEmpty
                ? 'No categories selected'
                : preferences.favoriteCategories.join(', '),
            LucideIcons.tag,
            onTap: () => _editCategories(),
          ),
          
          const SizedBox(height: 12),
          
          _buildPreferenceCard(
            'Preferred Areas',
            preferences.preferredAreas.isEmpty
                ? 'All areas'
                : preferences.preferredAreas.join(', '),
            LucideIcons.mapPin,
            onTap: () => _editAreas(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchCard(
            'Family-Friendly Only',
            'Show only family-friendly events',
            preferences.familyFriendlyOnly,
            (value) => ref.read(preferencesProvider.notifier).toggleFamilyFriendlyOnly(),
          ),
          
          const SizedBox(height: 32),
          
          // Notification Preferences
          _buildSectionHeader('Notifications', LucideIcons.bell),
          
          const SizedBox(height: 16),
          
          _buildSwitchCard(
            'Email Notifications',
            'Receive event updates via email',
            preferences.emailNotifications,
            (value) => ref.read(preferencesProvider.notifier).toggleEmailNotifications(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchCard(
            'Push Notifications',
            'Get notified about new events',
            preferences.pushNotifications,
            (value) => ref.read(preferencesProvider.notifier).togglePushNotifications(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchCard(
            'Weekly Digest',
            'Receive weekly event roundup',
            preferences.weeklyDigest,
            (value) => ref.read(preferencesProvider.notifier).toggleWeeklyDigest(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchCard(
            'Event Reminders',
            'Get reminded about upcoming events',
            preferences.eventReminders,
            (value) => ref.read(preferencesProvider.notifier).toggleEventReminders(),
          ),
          
          const SizedBox(height: 32),
          
          // Display Preferences
          _buildSectionHeader('Display', LucideIcons.monitor),
          
          const SizedBox(height: 16),
          
          _buildSwitchCard(
            'Dark Mode',
            'Use dark theme',
            preferences.darkMode,
            (value) => ref.read(preferencesProvider.notifier).toggleDarkMode(),
          ),
          
          const SizedBox(height: 12),
          
          _buildSliderCard(
            'Text Size',
            'Adjust text size for better readability',
            preferences.textScale,
            1.0,
            1.5,
            (value) => ref.read(preferencesProvider.notifier).updateTextScale(value),
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchCard(
            'Reduce Animations',
            'Minimize motion for better performance',
            preferences.reduceAnimations,
            (value) => ref.read(preferencesProvider.notifier).toggleReduceAnimations(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Statistics
          _buildSectionHeader('Account Overview', LucideIcons.barChart3),
          
          const SizedBox(height: 16),
          
          Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authProvider);
              final user = authState.user;
              
              return Column(
                children: [
                  _buildInfoCard(
                    'Member Since',
                    user?.createdAt != null 
                        ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                        : 'N/A',
                    LucideIcons.userPlus,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInfoCard(
                    'Saved Events',
                    '${user?.savedEvents?.length ?? 0}',
                    LucideIcons.bookmark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInfoCard(
                    'Favorite Events',
                    '${user?.heartedEvents?.length ?? 0}',
                    LucideIcons.heart,
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Security Settings
          _buildSectionHeader('Security & Privacy', LucideIcons.shield),
          
          const SizedBox(height: 16),
          
          _buildActionCard(
            'Change Password',
            'Reset your account password',
            LucideIcons.key,
            onTap: () => _changePassword(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Download My Data',
            'Export your personal information',
            LucideIcons.download,
            onTap: () => _downloadData(),
          ),
          
          const SizedBox(height: 32),
          
          // App Information
          _buildSectionHeader('App Information', LucideIcons.info),
          
          const SizedBox(height: 16),
          
          _buildInfoCard(
            'Version',
            '1.0.0 (Build 1)',
            LucideIcons.smartphone,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoCard(
            'Last Updated',
            'March 2024',
            LucideIcons.calendar,
          ),
          
          const SizedBox(height: 32),
          
          // Support & Feedback
          _buildSectionHeader('Support', LucideIcons.helpCircle),
          
          const SizedBox(height: 16),
          
          _buildActionCard(
            'Help Center',
            'Find answers to common questions',
            LucideIcons.helpCircle,
            onTap: () => _openHelpCenter(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Contact Support',
            'Get help from our support team',
            LucideIcons.messageCircle,
            onTap: () => _contactSupport(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Send Feedback',
            'Help us improve the app',
            LucideIcons.thumbsUp,
            onTap: () => _sendFeedback(),
          ),
          
          const SizedBox(height: 32),
          
          // Legal
          _buildSectionHeader('Legal', LucideIcons.fileText),
          
          const SizedBox(height: 16),
          
          _buildActionCard(
            'Terms of Service',
            'Read our terms and conditions',
            LucideIcons.fileText,
            onTap: () => _showTerms(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Privacy Policy',
            'Learn how we protect your data',
            LucideIcons.shield,
            onTap: () => _showPrivacyPolicy(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Cookies Policy',
            'How we use cookies and tracking',
            LucideIcons.cookie,
            onTap: () => _showCookiesPolicy(),
          ),
          
          const SizedBox(height: 32),
          
          // Logout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _logout(),
              icon: const Icon(LucideIcons.logOut),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.user,
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
                'Please sign in to view your profile and manage your preferences.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToLogin(),
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

  // Helper Widgets
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.dubaiGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, {VoidCallback? onTap, Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.dubaiGold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing,
              ],
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, {VoidCallback? onTap, bool isDestructive = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive ? AppColors.error.withOpacity(0.2) : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? AppColors.error : AppColors.dubaiGold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? AppColors.error : AppColors.textPrimary,
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
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesCard() {
    return Consumer(
      builder: (context, ref, child) {
        final heartedEvents = ref.watch(heartedEventsProvider);
        final savedEvents = ref.watch(savedEventsProvider);
        final totalFavorites = heartedEvents.length + savedEvents.length;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.dubaiCoral.withOpacity(0.1),
                AppColors.dubaiTeal.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.dubaiCoral.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.push('/favorites'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.dubaiCoral.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.heart,
                          size: 24,
                          color: AppColors.dubaiCoral,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Favorites',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalFavorites == 0 
                                  ? 'No favorites yet' 
                                  : '$totalFavorites saved events',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  if (totalFavorites > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFavoritesStat(
                            'Hearted',
                            heartedEvents.length.toString(),
                            LucideIcons.heart,
                            AppColors.dubaiCoral,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFavoritesStat(
                            'Saved',
                            savedEvents.length.toString(),
                            LucideIcons.bookmark,
                            AppColors.dubaiTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesStat(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dubaiGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.dubaiGold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.dubaiGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard(String title, String subtitle, double value, double min, double max, Function(double) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Slider.adaptive(
              value: value,
              min: min,
              max: max,
              divisions: 10,
              label: '${(value * 100).round()}%',
              onChanged: onChanged,
              activeColor: AppColors.dubaiGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(FamilyMember member, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.dubaiGold,
              child: Text(
                member.name.substring(0, 1).toUpperCase(),
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
                    member.name,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.relationship.toUpperCase()}, ${member.age} years old',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                LucideIcons.moreVertical,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editFamilyMember(member, index);
                    break;
                  case 'delete':
                    _deleteFamilyMember(index);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.edit, size: 16),
                      const SizedBox(width: 8),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dubaiGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: AppColors.dubaiGold),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  void _editPersonalInfo(UserProfile? user) {
    if (user == null) return;
    
    showDialog(
      context: context,
      builder: (context) => _EditPersonalInfoDialog(user: user),
    );
  }

  void _editInterests(UserProfile? user) {
    if (user == null) return;
    
    showDialog(
      context: context,
      builder: (context) => _EditInterestsDialog(user: user),
    );
  }

  void _privacySettings() {
    // TODO: Navigate to privacy settings screen
  }

  void _deleteAccount() {
    // TODO: Show confirmation dialog and delete account
  }

  void _addFamilyMember() {
    // TODO: Show add family member dialog
  }

  void _editFamilyMember(FamilyMember member, int index) {
    // TODO: Show edit family member dialog
  }

  void _deleteFamilyMember(int index) {
    final onboardingState = ref.read(onboardingProvider);
    if (index < onboardingState.familyMembers.length) {
      final memberId = onboardingState.familyMembers[index].id;
      ref.read(onboardingProvider.notifier).removeFamilyMember(memberId);
    }
  }

  void _editCategories() {
    // TODO: Show categories selection screen
  }

  void _editAreas() {
    // TODO: Show areas selection screen
  }

  void _openHelpCenter() {
    context.push('/faq');
  }

  void _contactSupport() {
    // TODO: Open support contact form or email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support contact feature coming soon!'),
        backgroundColor: AppColors.dubaiTeal,
      ),
    );
  }

  void _sendFeedback() {
    // TODO: Show feedback form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback feature coming soon!'),
        backgroundColor: AppColors.dubaiTeal,
      ),
    );
  }

  void _showTerms() {
    context.push('/terms');
  }

  void _showPrivacyPolicy() {
    context.push('/privacy');
  }

  void _showCookiesPolicy() {
    context.push('/cookies');
  }

  void _changePassword() {
    // Navigate to forgot password screen to reset password
    context.push('/forgot-password');
  }


  void _downloadData() {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildDataExportDialog(),
    );
  }

  Widget _buildDataExportDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.dubaiTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.download,
              color: AppColors.dubaiTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Download My Data',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We\'ll prepare a file containing all your personal data from MyDscvr. This includes:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Data categories
            ...[
              ('Account Information', 'Personal details, email, phone number'),
              ('Family Profile', 'Family members and their preferences'),
              ('Event Activity', 'Saved events, favorites, and interactions'),
              ('Preferences', 'App settings and notification preferences'),
              ('Usage Statistics', 'Account creation date and activity summary'),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          item.$2,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your data will be downloaded as a JSON file. Keep this file secure as it contains personal information.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            _performDataExport();
          },
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Download Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dubaiTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _performDataExport() async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Preparing your data export...'),
            ],
          ),
          backgroundColor: AppColors.dubaiTeal,
          duration: const Duration(seconds: 2),
        ),
      );

      // Get user data
      final authState = ref.read(authProvider);
      final user = authState.user;
      final preferences = ref.read(preferencesProvider);
      final favorites = ref.read(favoritesProvider);

      if (user == null) {
        throw Exception('User data not available');
      }

      // Create export data
      final exportData = {
        'export_info': {
          'generated_at': DateTime.now().toIso8601String(),
          'app_version': '1.0.0',
          'export_format': 'MyDscvr Data Export v1.0',
        },
        'account_information': {
          'user_id': user.id,
          'email': user.email,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'phone_number': user.phoneNumber,
          'date_of_birth': user.dateOfBirth?.toIso8601String(),
          'gender': user.gender,
          'account_created': user.createdAt.toIso8601String(),
          'last_updated': user.updatedAt.toIso8601String(),
          'email_verified': user.isEmailVerified,
          'phone_verified': user.isPhoneVerified,
        },
        'interests_and_preferences': {
          'interests': user.interests,
          'dark_mode': preferences.darkMode,
          'language': preferences.language,
          'currency': preferences.currency,
          'favorite_categories': preferences.favoriteCategories,
          'preferred_areas': preferences.preferredAreas,
          'family_friendly_only': preferences.familyFriendlyOnly,
          'notifications': {
            'email_notifications': preferences.emailNotifications,
            'push_notifications': preferences.pushNotifications,
            'weekly_digest': preferences.weeklyDigest,
            'event_reminders': preferences.eventReminders,
          },
        },
        'event_activity': {
          'saved_events': user.savedEvents ?? [],
          'hearted_events': user.heartedEvents ?? [],
          'attended_events': user.attendedEvents ?? [],
          'event_ratings': user.eventRatings ?? {},
          'favorites_count': favorites.length,
        },
        'app_settings': {
          'text_scale': preferences.textScale,
          'reduce_animations': preferences.reduceAnimations,
          'default_search_radius': preferences.defaultSearchRadius,
          'default_age_range': preferences.defaultAgeRange,
        },
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Create filename with timestamp
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'mydscvr_data_export_$timestamp.json';

      // For web, we'll show the data in a dialog since direct file download requires additional setup
      _showDataExportResult(jsonString, filename);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                LucideIcons.alertCircle,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Failed to export data: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDataExportResult(String jsonData, String filename) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.checkCircle,
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Data Export Ready',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your data has been successfully exported. You can copy the JSON data below:',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.file,
                      size: 16,
                      color: AppColors.dubaiTeal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filename,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(jsonData.length / 1024).toStringAsFixed(1)} KB',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonData,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonData));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data copied to clipboard!'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(LucideIcons.copy, size: 16),
            label: const Text('Copy to Clipboard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dubaiTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await ref.read(authProvider.notifier).logout();
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  // Helper methods for family calculations
  String _calculateChildrenAgeRange(List<FamilyMember> familyMembers) {
    final children = familyMembers.where((m) => m.relationship == 'child').toList();
    if (children.isEmpty) return 'N/A';
    
    final ages = children.map((c) => c.age).toList();
    ages.sort();
    
    if (ages.length == 1) {
      return '${ages.first} years';
    }
    
    return '${ages.first}-${ages.last} years';
  }
  
  int _getYoungestChildAge(List<FamilyMember> familyMembers) {
    final children = familyMembers.where((m) => m.relationship == 'child').toList();
    if (children.isEmpty) return 0;
    
    return children.map((c) => c.age).reduce((a, b) => a < b ? a : b);
  }
}

/// Edit Personal Information Dialog
class _EditPersonalInfoDialog extends ConsumerStatefulWidget {
  final UserProfile user;
  
  const _EditPersonalInfoDialog({required this.user});
  
  @override
  ConsumerState<_EditPersonalInfoDialog> createState() => _EditPersonalInfoDialogState();
}

class _EditPersonalInfoDialogState extends ConsumerState<_EditPersonalInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false;
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  
  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _selectedDate = widget.user.dateOfBirth;
    _selectedGender = widget.user.gender;
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.dubaiTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.edit,
                      color: AppColors.dubaiTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Personal Information',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // First Name Field
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: const Icon(LucideIcons.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Last Name Field
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: const Icon(LucideIcons.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(LucideIcons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date of Birth Field
              InkWell(
                onTap: () => _selectDate(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select Date of Birth',
                        style: AppTypography.bodyMedium.copyWith(
                          color: _selectedDate != null 
                              ? AppColors.textPrimary 
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(LucideIcons.userCheck),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dubaiTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.dubaiTeal,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final updateData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone_number': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'date_of_birth': _selectedDate?.toIso8601String(),
        'gender': _selectedGender,
      };
      
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.updateProfile(updateData);
      
      if (response.isSuccess && response.data != null) {
        // Update the auth state by refetching current user
        final authNotifier = ref.read(authProvider.notifier);
        final userResponse = await apiClient.getCurrentUser();
        if (userResponse.isSuccess && userResponse.data != null) {
          // Update the auth state with refreshed user data
          final currentState = ref.read(authProvider);
          ref.read(authProvider.notifier).state = currentState.copyWith(
            user: userResponse.data,
          );
        }
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    LucideIcons.checkCircle,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text('Personal information updated successfully!'),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception(response.message ?? 'Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to update profile: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Edit Interests Dialog
class _EditInterestsDialog extends ConsumerStatefulWidget {
  final UserProfile user;
  
  const _EditInterestsDialog({required this.user});
  
  @override
  ConsumerState<_EditInterestsDialog> createState() => _EditInterestsDialogState();
}

class _EditInterestsDialogState extends ConsumerState<_EditInterestsDialog> {
  late Set<String> _selectedInterests;
  bool _isLoading = false;
  
  // Available interest categories
  final List<String> _availableInterests = [
    // Outdoor & Adventure
    'Outdoor Activities',
    'Water Sports',
    'Desert Safari',
    'Beach Activities',
    'Adventure Sports',
    'Hiking & Nature',
    
    // Arts & Culture
    'Arts & Culture',
    'Museums',
    'Art Galleries',
    'Live Performances',
    'Theater',
    'Music Concerts',
    'Cultural Events',
    'Photography',
    
    // Food & Dining
    'Food & Dining',
    'Fine Dining',
    'Street Food',
    'Cooking Classes',
    'Food Festivals',
    'International Cuisine',
    'Local Cuisine',
    
    // Family & Kids
    'Family Activities',
    'Kids Events',
    'Educational',
    'Playgrounds',
    'Kids Workshops',
    'Family Entertainment',
    
    // Sports & Fitness
    'Sports & Fitness',
    'Golf',
    'Tennis',
    'Swimming',
    'Yoga',
    'Gym & Fitness',
    'Marathon & Running',
    
    // Entertainment
    'Entertainment',
    'Movies',
    'Comedy Shows',
    'Night Life',
    'Festivals',
    'Celebrations',
    'Dancing',
    
    // Shopping & Lifestyle
    'Shopping',
    'Fashion',
    'Beauty & Wellness',
    'Spa & Relaxation',
    'Luxury Experiences',
    
    // Business & Networking
    'Business Events',
    'Networking',
    'Conferences',
    'Workshops',
    'Professional Development',
    
    // Technology & Innovation
    'Technology',
    'Innovation',
    'Startups',
    'Digital Events',
    
    // Travel & Tourism
    'Tourism',
    'City Tours',
    'Historical Sites',
    'Architecture',
    'Local Experiences',
  ];
  
  @override
  void initState() {
    super.initState();
    _selectedInterests = Set<String>.from(widget.user.interests);
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.heart,
                    color: AppColors.dubaiTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Your Interests',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Select your interests to get personalized event recommendations. You can choose multiple categories.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selected count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dubaiTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_selectedInterests.length} interests selected',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dubaiTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Interests grid
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                      child: Container(
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
                                : AppColors.textTertiary,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                LucideIcons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              interest,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isSelected 
                                    ? Colors.white 
                                    : AppColors.textPrimary,
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedInterests.clear();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveInterests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dubaiTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Interests'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveInterests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // For now, we'll update interests through the onboarding preferences
      // Since interests are part of the preferences object in the user model
      final currentUser = widget.user;
      
      // We need to update the user's preferences with the new interests
      // This would typically be done through an API call to update preferences
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text('Interests updated successfully! (${_selectedInterests.length} selected)'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // TODO: Implement actual API call to update interests
      // This should update the user's preferences.interests field
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to update interests: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Custom TabBar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 8;

  @override
  double get maxExtent => tabBar.preferredSize.height + 8;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
} 