import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart'; // Import your colors
import 'package:shweeshaungdaily/views/notification_detail_page.dart'; // Ensure this import is correct and points to notification_detail_pages.dart

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  // List of notification items with an added 'type' and 'subType' property
  final List<NotificationItem> notifications = [
    // General type - App Maintenance
    NotificationItem(
      id: '1',
      title: 'Scheduled Maintenance',
      description:
          'Our services will be briefly unavailable tonight from 2 AM to 4 AM EST for essential updates.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      icon: Icons.build,
      color: kPrimaryDarkColor, // Using a color from your palette
      type: 'general',
      subType: 'app_maintenance',
    ),
    // General type - General Knowledge
    NotificationItem(
      id: '2',
      title: 'Did You Know?',
      description:
          'The human brain weighs about 3 pounds but uses 20% of the body\'s oxygen and calories.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      icon: Icons.lightbulb_outline,
      color: kLunchIconBg, // Using a color from your palette
      type: 'general',
      subType: 'general_knowledge',
    ),
    // General type - Quote
    NotificationItem(
      id: '3',
      title: 'Daily Inspiration',
      description:
          '"The only way to do great work is to love what you do." - Steve Jobs',
      time: DateTime.now().subtract(const Duration(days: 0, hours: 8)),
      isRead: true,
      icon: Icons.format_quote,
      color: kPrimaryColor, // Using a color from your palette
      type: 'general',
      subType: 'quote',
    ),
    // General type - Sweet Message
    NotificationItem(
      id: '4',
      title: 'Good Morning!',
      description: 'Wishing you a day filled with joy, laughter, and success!',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      icon: Icons.sentiment_very_satisfied,
      color: kAccentColor, // Using a color from your palette
      type: 'general',
      subType: 'sweet_message',
    ),
    // Voicemail type
    NotificationItem(
      id: '5',
      title: 'New Voicemail',
      description:
          'You have a new voicemail from (555) 123-4567. Duration: 0:45.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      icon: Icons.voicemail,
      color: kLunchText, // Using kLunchText
      type: 'voicemail',
      subType: null, // No subType for voicemail
    ),
    // Bulletin type
    NotificationItem(
      id: '6',
      title: 'Company Bulletin: Holiday Schedule',
      description:
          'Please review the updated holiday schedule for Q4. Details inside.',
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.campaign,
      color: kPrimaryColor, // Using kPrimaryColor
      type: 'bulletin',
      subType: null, // No subType for bulletin
    ),
    // A 'general' type without a specific subType, will use default general UI
    NotificationItem(
      id: '7',
      title: 'Account Verification',
      description:
          'Please verify your email address to ensure account security.',
      time: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
      icon: Icons.verified_user,
      color: kPrimaryDarkColor, // Using a color from your palette
      type: 'general',
      subType: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Using kBackgroundColor
      appBar: AppBar(
        backgroundColor: kAccentColor, // Using kAccentColor
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/mark-all-read.svg', // Ensure this SVG asset exists or remove/replace
              width: 24,
              colorFilter: const ColorFilter.mode(
                kWhite, // Using kWhite
                BlendMode.srcIn,
              ), // For SVG color
            ),
            onPressed: _markAllAsRead,
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(notification);
                    }, childCount: notifications.length),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: kErrorColor, // Using kErrorColor for dismiss background
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: kWhite), // Using kWhite
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          notifications.removeWhere((item) => item.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dismissed ${notification.title}')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
          color: kWhite, // Using kWhite
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kShadowColor.withOpacity(0.05), // Using kShadowColor
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Mark as read and navigate to detail page based on type
            setState(() {
              notification.isRead = true;
            });
            _navigateToNotificationDetail(context, notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontWeight:
                                    notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color:
                                    Colors
                                        .blue, // Keeping blue dot for unread indicator
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kAccentColor, // Using kLightTextColor
                        ),
                        maxLines: 2, // Limit description to 2 lines
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.time),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kGrey, // Using kGrey
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigate to the detail page based on notification type
  void _navigateToNotificationDetail(
    BuildContext context,
    NotificationItem notification,
  ) {
    Widget detailPage;
    switch (notification.type) {
      case 'voicemail':
        detailPage = VoicemailDetailPage(notification: notification);
        break;
      case 'bulletin':
        detailPage = BulletinDetailPage(notification: notification);
        break;
      case 'general': // Explicitly handle 'general'
      default: // All other types will also fall back to General
        detailPage = GeneralNotificationDetailPage(notification: notification);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => detailPage),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, y').format(time);
    }
  }

  Future<void> _refreshNotifications() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Re-sort or fetch new notifications here
      notifications.sort((a, b) => b.time.compareTo(a.time));
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }
}

// Notification Item Model
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  bool isRead;
  final IconData icon;
  final Color color;
  final String type;
  final String? subType; // Added subType property, now nullable

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    required this.icon,
    required this.color,
    required this.type,
    this.subType, // Made optional
  });
}
