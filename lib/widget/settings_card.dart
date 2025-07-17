import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/views/user_profile_update.dart'; // Ensure this path is correct

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed fixed width for a more fluid layout
      margin: const EdgeInsets.symmetric(horizontal: 20.0), // Add some horizontal margin
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Adjusted padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Softer shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SettingsItem(
            icon: Icons.person_outline, // Outline icon for minimalist look
            text: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileUpdateScreen()),
              );
            },
          ),
          const Divider(height: 20, thickness: 0.5, color: Colors.grey), // Clean separator
          _SettingsItem(
            icon: Icons.headset_mic_outlined,
            text: 'Customer Support',
            onTap: () {
              // Add customer support logic
            },
          ),
          const Divider(height: 20, thickness: 0.5, color: Colors.grey),
          _SettingsItem(
            icon: Icons.logout, // More common logout icon
            text: 'Log out',
            onTap: () {
              // Add your logout logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10), // Add border radius for InkWell
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0), // Padding inside InkWell for touch area
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100], // Very light background for icon
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF317575)), // Slightly larger icon
            ),
            const SizedBox(width: 15), // Increased space between icon and text
            Expanded( // Use Expanded to ensure text takes available space
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF317575),
                  fontWeight: FontWeight.w500, // Slightly less bold for elegance
                  fontSize: 16,
                ),
              ),
            ),
            if (onTap != null) // Only show arrow if item is tappable
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}

// Example usage in a main function or another widget to see it in action:
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Settings'),
          backgroundColor: const Color(0xFF317575),
        ),
        body: const Center(
          child: SettingsCard(),
        ),
      ),
    );
  }
}