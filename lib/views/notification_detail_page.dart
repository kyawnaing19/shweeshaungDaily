import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shweeshaungdaily/colors.dart'; // Ensure this path is correct
import 'package:shweeshaungdaily/views/notification_list_view.dart'; // Import NotificationItem model

// -----------------------------------------------------------------------------
// General Notification Detail Page (Simplified after removing subType)
// -----------------------------------------------------------------------------
class GeneralNotificationDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const GeneralNotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // Now that subType is removed from NotificationItem,
    // GeneralNotificationDetailPage will always show the default general layout.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          notification.title,
        ), // AppBar title can be dynamic based on notification title
        backgroundColor: kAccentColor, // Using kAccentColor
        foregroundColor: kWhite, // Text color for AppBar title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _DefaultGeneralSection(notification: notification),
      ),
    );
  }
}

// Helper widget for common info rows
Widget _buildInfoRow(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  Color? valueColor,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: kGrey), // Using kGrey
      const SizedBox(width: 10),
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: kTextColor, // Using kTextColor
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor ?? kLightTextColor, // Using kLightTextColor
          ),
        ),
      ),
    ],
  );
}

// -----------------------------------------------------------------------------
// Default Section for General Notifications (remains as the only general layout)
// -----------------------------------------------------------------------------

class _DefaultGeneralSection extends StatelessWidget {
  final NotificationItem notification;

  const _DefaultGeneralSection({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display image if available
        if (notification.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              notification.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: kGrey.withOpacity(0.2),
                  child: Center(
                    child: Icon(Icons.broken_image, color: kGrey, size: 50),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            Icon(notification.icon, color: notification.color, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                notification.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kTextColor, // Using kTextColor
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
            color: kPrimaryColor, // Using kPrimaryColor
          ),
        ),
        const SizedBox(height: 8),
        Text(
          notification.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: kLightTextColor,
          ), // Using kLightTextColor
        ),
        const SizedBox(height: 20),
        _buildInfoRow(
          context,
          Icons.access_time,
          'Time Received:',
          DateFormat('MMM d, y - hh:mm a').format(notification.time),
        ),
        const SizedBox(height: 10),
        _buildInfoRow(
          context,
          notification.isRead ? Icons.check_circle_outline : Icons.info_outline,
          'Status:',
          notification.isRead ? 'Read' : 'Unread',
          valueColor:
              notification.isRead
                  ? Colors.green
                  : kErrorColor, // Using kErrorColor
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action for ${notification.title}')),
              );
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('More Info'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor, // Using kPrimaryColor
              foregroundColor: kWhite, // Using kWhite
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Type-Specific Detail Page: Voicemail (Remains largely unchanged, colors updated)
// -----------------------------------------------------------------------------

class VoicemailDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const VoicemailDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voicemail'),
        backgroundColor: notification.color, // Notification's specific color
        foregroundColor: kWhite, // Text color for AppBar title
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: kWhite, // Using kWhite
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: notification.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display image if available
            if (notification.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  notification.imageUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 150,
                      color: kGrey.withOpacity(0.2),
                      child: Center(
                        child: Icon(Icons.broken_image, color: kGrey, size: 50),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            Icon(
              notification.icon,
              size: 60,
              color: notification.color, // Notification's specific color
            ),
            const SizedBox(height: 20),
            Text(
              notification.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: notification.color, // Notification's specific color
              ),
            ),
            const SizedBox(height: 10),
            Text(
              notification.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: kLightTextColor,
              ), // Using kLightTextColor
            ),
            const Divider(height: 30, thickness: 1),
            _buildInfoRow(
              context,
              Icons.phone,
              'From:',
              'Unknown Caller (555-1234)', // Example caller
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              context,
              Icons.access_time,
              'Duration:',
              '00:45', // Example duration
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playing voicemail...')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Voicemail'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    notification.color, // Notification's specific color
                foregroundColor: kWhite, // Using kWhite
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
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

  // This _buildInfoRow is specific to VoicemailDetailPage,
  // it's a good practice to keep it within the class or make it a global helper
  // if used across multiple detail pages.
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kGrey), // Using kGrey
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: kTextColor, // Using kTextColor
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: kLightTextColor, // Using kLightTextColor
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Removed BulletinDetailPage as it's no longer needed.
// Removed _AppMaintenanceSection, _GeneralKnowledgeSection, _QuoteSection,
// and _SweetMessageSection as subType is no longer used for dynamic content.
