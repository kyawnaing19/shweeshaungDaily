import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import 'package:shweeshaungdaily/views/teacherprofile.dart';
import 'package:shweeshaungdaily/views/userprofile.dart';

class ProfileRouterPage extends StatelessWidget {
  const ProfileRouterPage({super.key});

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
          // Still loading
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Error occurred
          return const Center(child: Text('❌ Failed to load profile'));
        } else {
          // Loaded successfully
          final isTeacher = snapshot.data ?? false;
          return isTeacher ? const TeacherProfilePage() : const ProfileScreen();
        }
      },
    );
  }
}
