import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/views/fullscreen_loading.dart';
import 'package:shweeshaungdaily/views/teacher_profile_view.dart';
import 'package:shweeshaungdaily/views/user_profile_view.dart';

class ViewRouter extends StatelessWidget {
  final String email;
  const ViewRouter({super.key, required this.email});

  Future<bool> _checkIfTeacher() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    return await ApiService.isTeacher(email);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTeacher(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display the full-screen shimmer skeleton while loading
          return const FullScreenShimmerSkeleton();
        } else if (snapshot.hasError) {
          return const Center(child: Text('❌ Failed to load profile'));
        } else {
          final isTeacher = snapshot.data ?? false;

          return isTeacher
              ? TeacherProfileViewPage(email: email)
              : UserProfileView(email: email);
        }
      },
    );
  }
}
