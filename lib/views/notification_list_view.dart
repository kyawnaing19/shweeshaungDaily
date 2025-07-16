import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationList();
}

class _NotificationList extends State<NotificationList> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'New Message',
      description: 'You have received a new message from Alex Johnson',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      icon: Icons.message,
      color: const Color(0xFF4E6AFF),
    ),
    NotificationItem(
      id: '2',
      title: 'Payment Received',
      description: '\$1,250.00 has been deposited to your account',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      icon: Icons.attach_money,
      color: const Color(0xFF00C853),
    ),
    NotificationItem(
      id: '3',
      title: 'Event Reminder',
      description: 'Team meeting starts in 15 minutes',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.calendar_today,
      color: const Color(0xFFFF7043),
    ),
    NotificationItem(
      id: '4',
      title: 'Security Alert',
      description: 'New login detected from a new device',
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      icon: Icons.security,
      color: const Color(0xFFFF3D00),
    ),
    NotificationItem(
      id: '5',
      title: 'System Update',
      description: 'New version 2.3.4 is available to download',
      time: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
      icon: Icons.system_update,
      color: const Color(0xFF6200EA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAccentColor, // Using kAccentColor
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/mark-all-read.svg',
              width: 24,
              color: const Color.fromARGB(255, 9, 9, 9),
            ),
            onPressed: _markAllAsRead,
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // _buildHeader(),
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
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              notification.isRead = true;
            });
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
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.time),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
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
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      notifications.sort((a, b) => b.time.compareTo(a.time));
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  bool isRead;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    required this.icon,
    required this.color,
  });
}
