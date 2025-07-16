import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import 'package:shweeshaungdaily/views/teacherprofile.dart';
import 'package:shweeshaungdaily/views/user_profile.dart';
import 'package:shweeshaungdaily/views/user_profile_view.dart';
import 'package:shweeshaungdaily/views/userprofile.dart';

class ProfileRouterPage extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onGoToProfileTab; // NEW callback

  const ProfileRouterPage({super.key, this.onBack, this.onGoToProfileTab});

  Future<bool> _checkIfTeacher() async {
    final role = await TokenService.getRole();
    return role == 'teacher';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTeacher(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('❌ Failed to load profile'));
        } else {
          final isTeacher = snapshot.data ?? false;

          // ✅ Pass onBack down to the actual screen
          return isTeacher
              ? TeacherProfilePage(
                onBack: onBack,
                //onGoToProfileTab: onGoToProfileTab,   // Pass down
              )
              : UserProfile(
                onBack: onBack, // Pass down
              );
        }
      },
    );
  }
}
