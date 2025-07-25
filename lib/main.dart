import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/view_models/StartupViewModel.dart';
import 'package:shweeshaungdaily/view_models/auth_viewmodel.dart';
import 'package:shweeshaungdaily/view_models/reg_viewmodel.dart';
import 'package:shweeshaungdaily/views/Home.dart';
import 'package:shweeshaungdaily/views/loading.dart';
import 'package:shweeshaungdaily/views/teacherprofile.dart';
import 'package:shweeshaungdaily/views/timetablepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder:
          (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => StartupViewModel()..initializeApp(),
                ),
                ChangeNotifierProvider(create: (_) => AuthViewModel()),
                ChangeNotifierProvider(create: (_) => RegistratinViewModel()),
              ],
              child: MaterialApp(
                title: 'Flutter MVVM Auth',
                theme: ThemeData(primarySwatch: Colors.blue),
                debugShowCheckedModeBanner: false,
                home: const LoadingPage(),
                routes: {
                  '/home': (context) => HomePage(),
                  '/timetable': (context) => TimeTablePage(),
                  // '/notes': (context) => NotesPage(),
                  '/profile': (context) => TeacherProfilePage(),
                },
              ),
            ),
          ),
    );
  }
}
