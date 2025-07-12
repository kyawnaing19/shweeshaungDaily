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
      return Scaffold(
        body: Container(
          color: const Color(
            0xFF4AC4BF,
          ), // The greenish-blue color from your image
          child: const Center(
            child: Column(
              // Use Column to arrange widgets vertically
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Shwee Shaung Daily',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily:
                        'Pacifico', // Ensure this font is added to your pubspec.yaml
                  ),
                ),
                SizedBox(
                  height: 100,
                ), // Space between "Shwee Shaung Daily" and "Loading..."
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    // You can also apply a fontFamily here if desired, e.g., fontFamily: 'Pacifico',
                  ),
                ),
                SizedBox(
                  height: 20,
                ), // Space between "Loading..." and the indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ), // White loading indicator
                ),
              ],
            ),
          ),
        ),
      );
    }
    return viewModel.isLoggedIn! ? const HomePage() : const LandingPage();
  }
}

// To run this example:
