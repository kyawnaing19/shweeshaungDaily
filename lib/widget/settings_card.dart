import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/views/user_profile_update.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SettingsItem(
            icon: Icons.person,
            text: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileUpdateScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          const _SettingsItem(
            icon: Icons.headset_mic_outlined,
            text: 'Customer Support',
          ),
          const SizedBox(height: 12),
          _SettingsItem(
            icon: Icons.power_settings_new_rounded,
            text: 'Log out',
            onTap: () {
              // Add your logout logic here
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
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // tap handler here
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF317575),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF317575),
                fontWeight: FontWeight.w600,
              ),
              // overflow: TextOverflow.ellipsis, // optional
            ),
          ),
        ],
      ),
    );
  }
}
