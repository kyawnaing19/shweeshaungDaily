import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/views/teacher_profile_view.dart';
import 'package:shweeshaungdaily/views/teacherprofile.dart';
import 'package:shweeshaungdaily/views/user_profile_view.dart';

class ViewRouter extends StatelessWidget {
  final String email;
  const ViewRouter({super.key,required this.email});
   Future<bool> _checkIfTeacher() async {
    return await ApiService.isTeacher(email);
  
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
              ? TeacherProfileViewPage(email: email)
                
                //onGoToProfileTab: onGoToProfileTab,   // Pass down
              
              : UserProfileView(email: email);
        }
      },
    );
  }
}