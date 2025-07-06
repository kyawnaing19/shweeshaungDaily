// views/profile_router.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/view_models/StartupViewModel.dart';
import 'package:shweeshaungdaily/views/teacherprofile.dart';
import 'package:shweeshaungdaily/views/userprofile.dart';
// Example: if you have this page

class ProfileRouterPage extends StatelessWidget {
  const ProfileRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final startupViewModel = Provider.of<StartupViewModel>(context, listen: false);
    
    // You can customize this condition based on user role, login status, etc.
    final isTeacher = startupViewModel.isTeacher; // Assuming isTeacher is a boolean in your StartupViewModel

    if (isTeacher == true) {
      return TeacherProfilePage();
    } else {
      return ProfileScreen(); // Or another widget
    }
  }
}
