import 'dart:async'; // Still needed for Timer, but we'll remove its auto-clear functionality
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/view_models/auth_viewmodel.dart';
import 'package:shweeshaungdaily/views/main_screen.dart'; // Assuming HomePage is now MainScreenPage
import 'package:shweeshaungdaily/views/signReg/register.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  String? _emailError;
  String? _passwordError;
  // Removed _errorTimer as auto-clear animation is no longer desired
  // Timer? _errorTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // Removed _errorTimer?.cancel();
    super.dispose();
  }

  // Modified to remove auto-clear animation
  void _setEmailError(String? message) {
    setState(() {
      _emailError = message;
    });
    // Removed Timer logic
  }

  // Modified to remove auto-clear animation
  void _setPasswordError(String? message) {
    setState(() {
      _passwordError = message;
    });
    // Removed Timer logic
  }

  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Reset errors before validation
    _setEmailError(null);
    _setPasswordError(null);

    bool hasError = false;

    if (email.isEmpty) {
      _setEmailError('Email is required!');
      hasError = true;
    } else if (!RegExp(r'^[\w-\.]+@[\w-]+\.edu\.mm$').hasMatch(email)) {
      _setEmailError('Edu mail only!');
      hasError = true;
    }

    if (password.isEmpty) {
      _setPasswordError('Password is required!');
      hasError = true;
    } else if (password.length < 8) {
      // Added a basic length check for consistency
      _setPasswordError('Password must be at least 8 characters.');
      hasError = true;
    }

    if (hasError) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 16),
            Text('Signing in...', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xFF317575),
        duration: Duration(minutes: 1), // Long duration for ongoing process
      ),
    );

    bool success = false;
    try {
      success = await authViewModel.login(email, password);
    } catch (e) {
      print('Login error: $e');
    } finally {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    if (success) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ), // Changed to MainScreenPage
        (Route<dynamic> route) => false, // This removes all previous routes
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
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
                      const SizedBox(height: 30),
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 38, // Consistent font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start, // Left-align header
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome back! Let\'s see if you remember the magic words.',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 18, // Consistent font size
                        ),
                        textAlign: TextAlign.start, // Left-align subtitle
                      ),
                      const SizedBox(height: 60),

                      /// Email Input Field
                      _buildErrorText(_emailError), // Non-animated error text
                      _buildModernInputField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _setEmailError('Email is required!');
                          } else if (!RegExp(
                            r'^[\w-\.]+@[\w-]+\.edu\.mm$',
                          ).hasMatch(value)) {
                            _setEmailError('Edu mail only!');
                          } else {
                            _setEmailError(null);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Password Input Field
                      _buildErrorText(
                        _passwordError,
                      ), // Non-animated error text
                      _buildModernInputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscureText,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _setPasswordError('Password is required!');
                          } else if (value.length < 8) {
                            _setPasswordError(
                              'Password must be at least 8 characters.',
                            );
                          } else {
                            _setPasswordError(null);
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      /// Forgot Password?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password page or show dialog
                            print('Forgot Password tapped');
                          },
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            foregroundColor: const Color(
                              0xFF317575,
                            ), // Consistent color
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration:
                                  TextDecoration
                                      .underline, // Added underline for clarity
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25), // Adjusted spacing
                      /// Sign In Button
                      _buildModernSignInButton(
                        onPressed: authViewModel.isLoading ? null : _onSignIn,
                        isLoading: authViewModel.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Don't have an account? Sign up
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextButton(
                onPressed:
                    authViewModel.isLoading
                        ? null
                        : () {
                          // Disable if loading
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  foregroundColor: const Color(0xFF4C878B),
                ),
                child: const Text.rich(
                  TextSpan(
                    text: 'Don\'t have an account? ',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign up',
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

  // Reusable input field widget (copied from CreatePasswordPage, now with onChanged)
  Widget _buildModernInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text, // Added default
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    required ValueChanged<String> onChanged, // Added onChanged
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      onChanged: onChanged, // Pass onChanged to TextFormField
    );
  }

  // Reusable button widget (adapted from RegisterPage's _buildModernRegisterButton)
  Widget _buildModernSignInButton({
    required VoidCallback? onPressed,
    required bool isLoading,
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
          isLoading
              ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
              : const Text(
                'Sign In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
    );
  }

  // Non-animated error text widget (copied from CreatePasswordPage)
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
