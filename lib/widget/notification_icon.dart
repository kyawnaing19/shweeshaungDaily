import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/views/notification_list_view.dart';

class NotificationIcon extends StatelessWidget {
  final int unreadCount;
  final BuildContext context; // Pass context from parent

  const NotificationIcon({
    super.key,
    required this.context,
    this.unreadCount = 0,
  });

  void _navigateToNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NotificationList()));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToNotifications,
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 35,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
