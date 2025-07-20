import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import the lottie package
import 'dart:async';

import 'package:shweeshaungdaily/views/loading.dart'; // For Timer

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set a timer to navigate to the main screen after a delay
    Timer(const Duration(seconds: 4), () { // Adjust duration as needed
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoadingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your desired background color
      body: Center(
        child: Lottie.asset(
          'assets/lottie/SplashScreen.json', // Path to your Lottie file
          width: 200, // Adjust size as needed
          height: 200,
          fit: BoxFit.contain, // How the animation should fit
          repeat: false, // Play once
          animate: true, // Start animation automatically
          // onLoaded: (composition) {
          //   // Optional: You can get information about the animation
          //   // print('Animation duration: ${composition.duration}');
          // },
        ),
      ),
    );
  }
}