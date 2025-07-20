import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/view_models/StartupViewModel.dart';
import 'package:shweeshaungdaily/views/main_screen.dart';
import 'package:shweeshaungdaily/views/signReg/landing.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // Ensure the system UI is styled correctly when this page appears.
    // Use addPostFrameCallback to ensure it runs after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Make status bar transparent
          statusBarIconBrightness: Brightness.light, // For dark icons on light content
          statusBarBrightness: Brightness.dark, // For iOS: `dark` for dark text/icons, `light` for light text/icons
          systemNavigationBarColor: Color(0xFF1b1b1b), // Match your background color
          systemNavigationBarIconBrightness: Brightness.light, // Set icon brightness
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StartupViewModel>(context);

    if (viewModel.isLoggedIn == null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final imageWidth = screenWidth * 0.7;

      return Scaffold(
        backgroundColor: const Color(0xFF1b1b1b), // Your desired dark background
        body: Center(
          child: Image.asset(
            "assets/icons/45.png",
            width: imageWidth,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return viewModel.isLoggedIn! ? const HomePage() : const LandingPage();
  }
}