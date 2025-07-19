import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/view_models/auth_viewmodel.dart';
import 'package:shweeshaungdaily/view_models/reg_viewmodel.dart';
import 'package:shweeshaungdaily/views/Home.dart';
import 'package:shweeshaungdaily/views/signReg/StudentInfo.dart';
import 'package:shweeshaungdaily/views/signReg/login.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText1 = true;
  bool _obscureText2 = true;

  String? _passwordError;
  String? _conPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _conPasswordController.dispose();
    super.dispose();
  }

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

  // Password validation function
  bool _isPasswordValid(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  // Set error message for password fields
  void _setPasswordError(String? message) {
    setState(() {
      _passwordError = message;
      _conPasswordError = message; // Apply to both for consistency
    });
    // Removed Timer for error message auto-clearance to match no-animation request.
    // Error will only clear on next valid input or explicit null.
  }

  // Show general error message (Snackbar)
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[400],
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _onCreateAccount() async {
    final String password = _passwordController.text;
    final String confirmPassword = _conPasswordController.text;

    // Reset errors before validation
    _setPasswordError(null);

    bool hasError = false;

    if (!_isPasswordValid(password)) {
      _setPasswordError(
        'Password must be at least 8 characters. Include uppercase, lowercase, and number.',
      );
      hasError = true;
    }

    if (password != confirmPassword) {
      _setPasswordError('Passwords do not match.');
      hasError = true;
    }

    if (hasError) {
      return;
    }

    FocusScope.of(context).unfocus(); // Dismiss keyboard

    Provider.of<RegistratinViewModel>(
      context,
      listen: false,
    ).updatePassword(password);

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final String email =
        Provider.of<RegistratinViewModel>(context, listen: false).email;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Creating account...', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xFF317575),
        duration: Duration(minutes: 1), // Long duration for ongoing process
      ),
    );

    bool success = false;
    try {
      if (await ApiService.isTeacher(email)) {
        print(
          "Teacher account detected, proceeding with teacher registration...",
        );
        print("Email: $email, Password: $password");

        final regViewModel = Provider.of<RegistratinViewModel>(
          context,
          listen: false,
        );
        success = await authViewModel.register(regViewModel.user);

        if (success) {
          await authViewModel.login(email, password);
          print("Login successful, navigating to HomePage...");
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pushAndRemoveUntil(
            context,
            _createSlideRoute(HomeScreenPage()), // Use custom route
            (Route<dynamic> route) => false,
          );
          return;
        }
      } else {
        // Assume this path is for students or general users
        final regViewModel = Provider.of<RegistratinViewModel>(
          context,
          listen: false,
        );
        success = await authViewModel.register(regViewModel.user);

        if (success) {
          await authViewModel.login(
            email,
            password,
          ); // Log in after successful registration
          print(
            "Registration and Login successful, navigating to StudentInfoPage...",
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pushReplacement(
            context,
            _createSlideRoute(const StudentInfoPage()), // Use custom route
          );
          return;
        }
      }
    } catch (e) {
      print('Registration/Login error: $e');
    } finally {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    // If we reach here, something failed
    _showErrorMessage('Account creation failed. Please try again.');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevents going back
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFD4F7F5),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 40.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        const Text(
                          'Create New Password',
                          style: TextStyle(
                            color: Color(0xFF317575),
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start, // Align left
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create a strong, secure password for your account.',
                          style: TextStyle(
                            color: Color(0xFF317575),
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.start, // Align left
                        ),
                        const SizedBox(height: 40),

                        /// Password Input Field
                        _buildErrorText(
                          _passwordError,
                        ), // Non-animated error text
                        _buildModernInputField(
                          controller: _passwordController,
                          hintText: 'New Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscureText1,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureText1 = !_obscureText1;
                            });
                          },
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _setPasswordError('Password is required!');
                            } else if (!_isPasswordValid(value)) {
                              _setPasswordError(
                                'Password must be at least 8 characters, include uppercase, lowercase, and a number.',
                              );
                            } else if (value != _conPasswordController.text &&
                                _conPasswordController.text.isNotEmpty) {
                              _setPasswordError('Passwords do not match.');
                            } else {
                              _setPasswordError(null);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        /// Confirm Password Input Field
                        _buildErrorText(
                          _conPasswordError,
                        ), // Non-animated error text
                        _buildModernInputField(
                          controller: _conPasswordController,
                          hintText: 'Confirm Password',
                          icon: Icons.lock,
                          obscureText: _obscureText2,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureText2 = !_obscureText2;
                            });
                          },
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _setPasswordError(
                                'Confirm password is required!',
                              );
                            } else if (value != _passwordController.text) {
                              _setPasswordError('Passwords do not match.');
                            } else {
                              _setPasswordError(null);
                            }
                          },
                        ),
                        const SizedBox(height: 40),

                        /// Continue Button
                        _buildModernContinueButton(onPressed: _onCreateAccount),
                      ],
                    ),
                  ),
                ),
              ),

              /// Already have an account text
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    _createSlideRoute(
                      const SignInPage(),
                    ), // Use the custom route
                  );
                  },
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    foregroundColor: const Color(0xFF4C878B),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
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
      ),
    );
  }

  // Reusable input field widget adapted from RegisterPage
  Widget _buildModernInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: const Color(0xFF317575).withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFF317575)),
        suffixIcon:
            onToggleVisibility != null
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF317575),
                  ),
                  onPressed: onToggleVisibility,
                )
                : null,
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
      ),
      style: const TextStyle(color: Color(0xFF317575), fontSize: 18),
      cursorColor: const Color(0xFF317575),
      onChanged: onChanged,
    );
  }

  // Reusable button widget adapted from RegisterPage
  Widget _buildModernContinueButton({required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF317575),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: const Color(0xFF317575).withOpacity(0.5),
        // No disabled state for this button in the original logic,
        // but adding for consistency if needed later.
        // disabledBackgroundColor: const Color(0xFF317575).withOpacity(0.6),
        // disabledForegroundColor: Colors.white.withOpacity(0.7),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Non-animated error text widget
  Widget _buildErrorText(String? error) {
    if (error == null) {
      return const SizedBox(height: 0); // No height when no error
    }
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
