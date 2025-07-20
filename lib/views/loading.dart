import 'package:flutter/material.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StartupViewModel>(context);

    if (viewModel.isLoggedIn == null) {
      // Get the screen size

      final screenWidth = MediaQuery.of(context).size.width;

      final screenHeight = MediaQuery.of(context).size.height;

      // Calculate the desired width based on a percentage of the screen width.

      // You might need to adjust 0.7 (70%) based on your splash screen's exact scaling.

      final imageWidth = screenWidth * 0.7; // Example: 70% of screen width

      return Scaffold(
        backgroundColor: const Color(0xFF1b1b1b),

        body: Center(
          child: Image.asset(
            "assets/icons/45.png",

            width: imageWidth,

            // You can optionally set a height if your splash screen fixes height,

            // but usually setting width with BoxFit.contain/fitWidth is enough to maintain aspect ratio.

            // For a logo like this, BoxFit.contain is usually the best fit.
            fit: BoxFit.contain, // Ensures the image maintains its aspect ratio
          ),
        ),
      );
    }

    return viewModel.isLoggedIn! ? const HomePage() : const LandingPage();
  }
}
