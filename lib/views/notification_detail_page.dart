import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/authorize_image.dart';
import 'package:shweeshaungdaily/services/authorized_network_image.dart';
import 'package:shweeshaungdaily/views/audio_post/audio_view.dart';
import 'package:shweeshaungdaily/views/notification_list_view.dart';

// -----------------------------------------------------------------------------
// General Notification Detail Page
// -----------------------------------------------------------------------------
class GeneralNotificationDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const GeneralNotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notification.type),
        backgroundColor: kAccentColor,
        foregroundColor: kWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _DefaultGeneralSection(notification: notification),
      ),
    );
  }
}

Widget _buildInfoRow(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kGrey),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? kLightTextColor,
            ),
          ),
        ),
      ],
    ),
  );
}

// -----------------------------------------------------------------------------
// Default General Section Layout
// -----------------------------------------------------------------------------
class _DefaultGeneralSection extends StatelessWidget {
  final NotificationItem notification;

  const _DefaultGeneralSection({required this.notification});

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = notification.imageUrl;
final String fullImageUrl = (imageUrl != null && imageUrl.isNotEmpty) 
    ? 'https://shweeshaung.mooo.com/$imageUrl'  // Add your prefix here
    : '';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AuthorizedNetworkImage(
            imageUrl: fullImageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
      ],
      Row(
        children: [
          const Icon(Icons.notifications, color: kAccentColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              notification.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
            ),
          ),
        ],
      ),
      const Divider(height: 30, thickness: 1),
      Text(
        'Details:',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
      ),
      const SizedBox(height: 8),
      Text(
        notification.message,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: kLightTextColor,
            ),
      ),
      const SizedBox(height: 20),
      _buildInfoRow(
        context,
        Icons.access_time,
        'Time Received:',
        DateFormat('MMM d, y - hh:mm a').format(notification.createdAt),
      ),
      const SizedBox(height: 10),
      // _buildInfoRow(
      //   context,
      //   notification.isRead ? Icons.check_circle_outline : Icons.info_outline,
      //   'Status:',
      //   notification.isRead ? 'Read' : 'Unread',
      //   valueColor: notification.isRead ? Colors.green : kErrorColor,
      // ),
      const SizedBox(height: 20),
      // Center(
      //   child: ElevatedButton.icon(
      //     onPressed: () {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(content: Text('Action for ${notification.title}')),
      //       );
      //     },
      //     icon: const Icon(Icons.info_outline),
      //     label: const Text('More Info'),
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: kPrimaryColor,
      //       foregroundColor: kWhite,
      //       padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(10),
      //       ),
      //     ),
      //   ),
      // ),
    ],
  );
}

}

// -----------------------------------------------------------------------------
// Voicemail Notification Detail Page
// -----------------------------------------------------------------------------
class VoicemailDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const VoicemailDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voicemail'),
        backgroundColor: kAccentColor,
        foregroundColor: kWhite,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: kShadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  notification.imageUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 150,
                    color: kGrey.withOpacity(0.2),
                    child: const Center(
                      child: Icon(Icons.broken_image, color: kGrey, size: 50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Icon(Icons.voicemail, size: 60, color: kAccentColor),
            const SizedBox(height: 20),
            Text(
              notification.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: kLightTextColor,
              ),
            ),
            const Divider(height: 30, thickness: 1),
          
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReactorAudioPage()),
    );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Voicemail'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kGrey),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kLightTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
