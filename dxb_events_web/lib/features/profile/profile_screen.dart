import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

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
          
          // Name Field
          _buildInfoCard(
            'Full Name',
            user?.displayName ?? 'Not provided',
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
          ),
          
          const SizedBox(height: 12),
          
          // Phone Field
          _buildInfoCard(
            'Phone Number',
            user?.phoneNumber ?? 'Not provided',
            LucideIcons.phone,
            onTap: () => _editPersonalInfo(user),
          ),
          
          const SizedBox(height: 32),
          
          // Interests Section
          _buildSectionHeader('Interests', LucideIcons.heart),
          
          const SizedBox(height: 16),
          
          if (user?.interests.isNotEmpty == true) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user!.interests.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dubaiGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.dubaiGold.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    interest,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.dubaiGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
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
          // App Information
          _buildSectionHeader('About', LucideIcons.info),
          
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

  Widget _buildInfoCard(String label, String value, IconData icon, {VoidCallback? onTap}) {
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

  // Action Methods (TODO: Implement actual functionality)
  void _editPersonalInfo(UserProfile? user) {
    // TODO: Navigate to edit personal info screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit personal info coming soon!'),
        backgroundColor: AppColors.dubaiTeal,
      ),
    );
  }

  void _editInterests(UserProfile? user) {
    // TODO: Show interests selection dialog
  }

  void _changePassword() {
    // TODO: Navigate to change password screen
  }

  void _privacySettings() {
    // TODO: Navigate to privacy settings screen
  }

  void _downloadData() {
    // TODO: Implement data download
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
    // TODO: Navigate to help center
  }

  void _contactSupport() {
    // TODO: Open support contact
  }

  void _sendFeedback() {
    // TODO: Show feedback form
  }

  void _showTerms() {
    // TODO: Show terms of service
  }

  void _showPrivacyPolicy() {
    // TODO: Show privacy policy
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