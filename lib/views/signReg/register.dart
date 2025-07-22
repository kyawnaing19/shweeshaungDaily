import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/view_models/auth_viewmodel.dart';
import 'package:shweeshaungdaily/view_models/reg_viewmodel.dart';
import 'package:shweeshaungdaily/views/signReg/policy.dart';
import 'package:shweeshaungdaily/views/signReg/verifyemail.dart';
import 'package:shweeshaungdaily/views/signReg/login.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// This is the primary function for handling registration.
  /// It now uses the Form key to validate input and has a single loading state.
  void _onSignUp() async {
    // 1. Validate the form. If it's not valid, the function stops.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Unfocus any active text fields
    FocusScope.of(context).unfocus();

    setState(() {
      _isRegistering = true;
    });

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    // Update ViewModels
    Provider.of<RegistratinViewModel>(
      context,
      listen: false,
    ).updateNameEmail(name, email);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      // 2. Attempt to register. We assume `registerEmail` throws an
      // exception on failure, which we can catch.

      await authViewModel.registerEmail(email, name);

      // 3. On success, navigate to the verification page.
      if (mounted) {
        Navigator.pushReplacement(context, _createSlideRoute());
      }
    } catch (e) {
      // 4. Handle specific errors
      String errorMessage = 'Registration failed. Please try again.';
      // NOTE: Adjust 'EMAIL_ALREADY_IN_USE' to the actual error code or
      // message provided by your backend/authentication service (e.g., Firebase).
      if (e.toString().contains('EMAIL_ALREADY_IN_USE')) {
        errorMessage = 'This email is already registered. Please Sign In.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 5. Always turn off the loading indicator when done.
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  // Navigation route remains the same
  PageRouteBuilder _createSlideRoute() {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) => const VerifyEmailPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 500),
    );
  }

  // Define the custom slide route for navigation
  PageRouteBuilder _createSigninSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define the offset for the slide transition.
        // From Offset(1.0, 0.0) means the page starts completely off-screen to the right.
        // To Offset(0.0, 0.0) means the page ends at its normal position.
        const begin = Offset(1.0, 0.0); // Starts from the right
        const end = Offset.zero; // Ends at the center

        // Define the curve for the animation (e.g., easeOutCubic for a smooth feel).
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
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFD4F7F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0, // Increased horizontal padding
                  vertical: 50.0, // Increased top padding
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 20), // Reduced spacing
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 42, // Slightly larger font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced spacing
                      const Text(
                        'Sign up to start your journey with us!',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 19, // Slightly larger font size
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(
                        height: 70,
                      ), // Increased spacing before inputs

                      _buildModernInputField(
                        controller: _nameController,
                        hintText: 'Nick Name',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nick Name is required!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15), // Increased spacing

                      _buildModernInputField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required!';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@[\w-]+\.edu\.mm$',
                          ).hasMatch(value)) {
                            return 'A valid .edu.mm email is required!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25), // Adjusted spacing

                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ), // Slightly smaller for dense legal text
                          children: [
                            TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'User Agreement',
                              style: TextStyle(
                                color: kPrimaryColor,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PrivacyPolicyPage(),
                                        ),
                                      );
                                    },
                            ),
                            TextSpan(
                              text: ' and acknowledge that you understand the ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: kPrimaryColor,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PrivacyPolicyPage(),
                                        ),
                                      );
                                    },
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15), // Increased spacing

                      _buildModernRegisterButton(
                        onPressed: _isRegistering ? null : _onSignUp,
                        isRegistering: _isRegistering,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                bottom: 25.0,
              ), // Increased bottom padding
              child: TextButton(
                onPressed:
                    _isRegistering
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            _createSigninSlideRoute(const SignInPage()),
                          );
                        },
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  foregroundColor: const Color(0xFF4C878B),
                ),
                child: const Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                    ), // Slightly larger font size
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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

  /// Updated to accept and use a validator function.
  Widget _buildModernInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator, // Use the validator here
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: const Color(0xFF317575).withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFF317575)),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 10.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF57C5BE), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF317575), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        // The error text style is handled by the theme, but you can customize it
        errorStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      style: const TextStyle(color: Color(0xFF317575), fontSize: 18),
      cursorColor: const Color(0xFF317575),
    );
  }

  // This widget remains the same
  Widget _buildModernRegisterButton({
    required VoidCallback? onPressed,
    required bool isRegistering,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF317575),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: const Color(0xFF317575).withOpacity(0.5),
        disabledBackgroundColor: const Color(0xFF317575).withOpacity(0.6),
        disabledForegroundColor: Colors.white.withOpacity(0.7),
      ),
      child:
          isRegistering
              ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
              : const Text(
                'Create Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
    );
  }
}
