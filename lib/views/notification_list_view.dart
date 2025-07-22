import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/views/notification_detail_page.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;
  final String type;
  final String? imageUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    required this.type,
    this.imageUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isRead: json['seen'] ?? false,
      type: json['type'] ?? 'general',
      imageUrl: json['imageUrl'],
    );
  }
}

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final data = await ApiService.getAllNotifications();
      setState(() {
        notifications = data.map((json) => NotificationItem.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAccentColor,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/mark-all-read.svg',
              width: 24,
              colorFilter: const ColorFilter.mode(kWhite, BlendMode.srcIn),
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationItem(notification);
                      },
                      childCount: notifications.length,
                    ),
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
    const defaultIcon = Icons.notifications;
    const defaultColor = Colors.blue;

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: kErrorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: kWhite),
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
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kShadowColor.withOpacity(0.05),
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
                  decoration: const BoxDecoration(
                    color: defaultColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    defaultIcon,
                    color: kWhite,
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
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
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
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kAccentColor,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: kGrey,
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

  Future<void> _navigateToNotificationDetail(BuildContext context, NotificationItem notification) async {
    Widget detailPage;

    switch (notification.type) {
      case 'VOICE_MAIL':
        detailPage = VoicemailDetailPage(notification: notification);
        break;
      default:
        detailPage = GeneralNotificationDetailPage(notification: notification);
    }


    final bool = await ApiService.markNotificationAsSeen(notification.id);
    if(bool==true){
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => detailPage),
    );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('check network or something wrong')),
    );
    
    }

    
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
    await _fetchNotifications();
  }

  Future<void> _markAllAsRead() async {
    final bool = await ApiService.markNotificationsAsSeen();
    if(bool==true){
        setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
    });
    }else{

    }
    
    
  }
}
