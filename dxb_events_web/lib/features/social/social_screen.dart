import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/notifications/notification_panel.dart';
import '../../widgets/notifications/notification_bell.dart';
import '../../providers/notification_provider.dart';
import '../../services/notifications/notification_service.dart';
import '../../widgets/common/curved_container.dart';
import '../../widgets/common/glass_container.dart';

/// Social Features Demo Screen for Phase 6
/// Showcases notifications, reviews, social interactions, and community features
class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showNotificationPanel = false;

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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFEDF2FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildTabBar(),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsTab(),
                      _buildSocialFeedTab(),
                      _buildReviewsTab(),
                      _buildCommunityTab(),
                    ],
                  ),
                ),
              ],
            ),
            
            // Floating notification panel overlay
            if (_showNotificationPanel)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showNotificationPanel = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: NotificationPanel(
                        onClose: () => setState(() => _showNotificationPanel = false),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.dubaiGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Social Hub',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect & Share Experiences',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showNotificationPanel = true),
                    child: const NotificationBell(
                      color: Colors.white,
                      size: 28,
                      showPanel: false,
                    ),
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
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Iconsax.notification), text: 'Notifications'),
            Tab(icon: Icon(Iconsax.activity), text: 'Feed'),
            Tab(icon: Icon(Iconsax.star), text: 'Reviews'),
            Tab(icon: Icon(Iconsax.people), text: 'Community'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Notification Management', 'Manage your preferences and view activity'),
          const SizedBox(height: 16),
          
          // Notification Controls
          _buildNotificationControls(),
          const SizedBox(height: 24),
          
          // Recent Notifications Preview
          _buildRecentNotifications(),
        ],
      ),
    );
  }

  Widget _buildNotificationControls() {
    return CurvedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.setting,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Notification Controls',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          
          _buildActionButton(
            'Mark All as Read',
            Iconsax.tick_circle,
            () => ref.read(notificationsProvider.notifier).markAllAsRead(),
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          
          _buildActionButton(
            'Clear All Notifications',
            Iconsax.trash,
            () => ref.read(notificationsProvider.notifier).clearAll(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed, {required Color color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotifications() {
    final notifications = ref.watch(notificationsProvider);
    final recentNotifications = notifications.take(3).toList();

    return CurvedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.notification_bing,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (recentNotifications.isEmpty)
            _buildEmptyState('No notifications yet', 'You\'ll see notifications here when there are updates')
          else
            ...recentNotifications.asMap().entries.map((entry) {
              final index = entry.key;
              final notification = entry.value;
              return NotificationItem(
                notification: notification,
                onTap: () => ref.read(notificationsProvider.notifier).markAsRead(notification.id),
                onDismiss: () => ref.read(notificationsProvider.notifier).removeNotification(notification.id),
              ).animate(delay: Duration(milliseconds: index * 100))
               .slideX(begin: 1, curve: Curves.easeOut)
               .fadeIn();
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSocialFeedTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionHeader('Social Activity Feed', 'See what\'s happening in the community'),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => _buildFeedItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(int index) {
    final feedTypes = [
      ('New Review Posted', 'Sarah shared her experience at Dubai Aquarium', Iconsax.star, Colors.orange),
      ('Event Attended', 'Ahmed checked in at Global Village', Iconsax.location, Colors.green),
      ('Photo Shared', 'Family day at JBR Beach - amazing sunset!', Iconsax.camera, Colors.blue),
      ('Event Saved', 'Maria saved "Desert Safari Adventure"', Iconsax.heart, Colors.red),
      ('Achievement Unlocked', 'Earned "Explorer" badge for visiting 10 events', Iconsax.award, Colors.purple),
    ];
    
    final feedItem = feedTypes[index % feedTypes.length];
    
    return CurvedContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: feedItem.$4.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feedItem.$3,
              color: feedItem.$4,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedItem.$1,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedItem.$2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${index + 1}h ago',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
     .slideX(begin: 1, curve: Curves.easeOut)
     .fadeIn();
  }

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionHeader('Reviews & Ratings', 'Community feedback and experiences'),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => _buildReviewItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(int index) {
    final reviews = [
      ('Dubai Aquarium & Underwater Zoo', 4.8, 'Amazing experience with kids! The tunnel walk was breathtaking.', 'Sarah M.'),
      ('Global Village Cultural Show', 4.5, 'Great cultural diversity and food. Perfect for families.', 'Ahmed K.'),
      ('JBR Beach Family Day', 4.9, 'Beautiful beach, great facilities, kids loved the activities.', 'Maria L.'),
      ('Desert Safari Adventure', 4.7, 'Thrilling experience! Camel ride was the highlight for kids.', 'John D.'),
      ('Dubai Mall Family Fun', 4.6, 'Huge mall with lots of entertainment options for families.', 'Fatima A.'),
    ];
    
    final review = reviews[index % reviews.length];
    
    return CurvedContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  review.$4[0],
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.$4,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          Icons.star,
                          size: 16,
                          color: i < review.$2 ? Colors.amber : Colors.grey[300],
                        )),
                        const SizedBox(width: 8),
                        Text(
                          review.$2.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.$1,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.$3,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
     .slideY(begin: 0.5, curve: Curves.easeOut)
     .fadeIn();
  }

  Widget _buildCommunityTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionHeader('Community Features', 'Connect with other families and share experiences'),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCommunityStats(),
                  const SizedBox(height: 20),
                  _buildTrendingContent(),
                  const SizedBox(height: 20),
                  _buildSocialRecommendations(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityStats() {
    return CurvedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildStatItem('2.5K', 'Active Families', Iconsax.people, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem('890', 'Reviews', Iconsax.star, Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('156', 'Events This Week', Iconsax.calendar, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem('4.8', 'Average Rating', Iconsax.heart, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingContent() {
    return CurvedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.trend_up, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Trending This Week',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...['#FamilyFun', '#DubaiLife', '#WeekendVibes', '#KidsActivities'].map((tag) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.hashtag, size: 16, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    tag.substring(1),
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(tag.hashCode % 1000).abs()} posts',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildSocialRecommendations() {
    return CurvedContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.magicpen, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recommended for You',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...['Dubai Fountain Show', 'IMG Worlds of Adventure', 'Dubai Creek Harbour'].map((event) =>
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.dubaiGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on your interests and similar families',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.notification_status,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
} 