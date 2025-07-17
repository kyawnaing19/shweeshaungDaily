import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shweeshaungdaily/views/signReg/login.dart';
import 'package:shweeshaungdaily/views/signReg/register.dart';

// Placeholder for your main application page
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // Define the custom slide route for navigation
  PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define the offset for the slide transition.
        // From Offset(1.0, 0.0) means the page starts completely off-screen to the right.
        // To Offset(0.0, 0.0) means the page ends at its normal position.
        const begin = Offset(1.0, 0.0); // Starts from the right
        const end = Offset.zero; // Ends at the center

        // Define the curve for the animation (e.g., easeOutBack for a slight bounce).
        const curve =
            Curves.easeOutCubic; // Smooth acceleration and deceleration

        // Create a Tween for the offset.
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        // Use SlideTransition to apply the animation to the child page.
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFD4F7F5,
      ), // Light greenish-blue background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Your Day,\nSorted.\nInstantly.',
                    style: TextStyle(
                      color: Color(0xFF4C878B),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Streaming your schedule with our easy-to-use student timetable app.',
                    style: TextStyle(
                      color: Color(0xFF4C878B),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      // Apply the custom slide transition to RegisterPage
                      Navigator.push(
                        context,
                        _createSlideRoute(
                          const RegisterPage(),
                        ), // Use the custom route
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF317575),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: Color(0xFF4C878B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // Start a timer for 2 seconds
    Timer(const Duration(seconds: 3), () {
      // After 2 seconds, navigate to the HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(
          0xFFD4F7F5,
        ), // The greenish-blue color from your image
        child: const Center(
          child: Column(
            // Use Column to arrange widgets vertically
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Shwee Shaung Daily',
                style: TextStyle(
                  color: Color(0xFF317575),
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
                  color: Color(0xFF317575),
                  fontSize: 18,
                  // You can also apply a fontFamily here if desired, e.g., fontFamily: 'Pacifico',
                ),
              ),
              SizedBox(
                height: 20,
              ), // Space between "Loading..." and the indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF317575),
                ), // White loading indicator
              ),
            ],
          ),
        ),
      ),
    );
  }
}
