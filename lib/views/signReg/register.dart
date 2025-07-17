import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/view_models/auth_viewmodel.dart';
import 'package:shweeshaungdaily/view_models/reg_viewmodel.dart';
import 'package:shweeshaungdaily/views/signReg/verifyemail.dart';
import 'package:shweeshaungdaily/views/signReg/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _emailError;
  String? _nameError;
  Timer? _errorTimer;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _setEmailError(String? message) {
    setState(() {
      _emailError = message;
    });

    if (message != null) {
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _emailError = null;
          });
        }
      });
    }
  }

  void _setNameError(String? message) {
    setState(() {
      _nameError = message;
    });

    if (message != null) {
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _nameError = null;
          });
        }
      });
    }
  }

  // Modified _createSlideRoute to navigate to VerifyEmailPage
  PageRouteBuilder _createSlideRoute() {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) =>
              const VerifyEmailPage(), // Changed to VerifyEmailPage()
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Starts from the right
        const end = Offset.zero; // Ends at the center
        const curve =
            Curves.easeOutCubic; // Smooth acceleration and deceleration

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

  void _onSignUp() async {
    FocusScope.of(context).unfocus();

    String email = _emailController.text.trim();
    String name = _nameController.text.trim();

    _setEmailError(null);
    _setNameError(null);

    bool hasError = false;
    if (name.isEmpty) {
      _setNameError('Name is required!');
      hasError = true;
    }
    if (email.isEmpty) {
      _setEmailError('Email is required!');
      hasError = true;
    } else if (!RegExp(r'^[\w-\.]+@[\w-]+\.edu\.mm$').hasMatch(email)) {
      _setEmailError('Edu mail only!');
      hasError = true;
    }

    if (hasError) {
      return;
    }

    Provider.of<RegistratinViewModel>(
      context,
      listen: false,
    ).updateNameEmail(name, email);

    setState(() {
      _isRegistering = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 16),
            Text(
              'Registering $name...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF317575),
        duration: const Duration(minutes: 1),
      ),
    );

    bool success = false;
    try {
      success = await authViewModel.registerEmail(email, name);
    } catch (e) {
      success = false;
      print('Registration error: $e');
    } finally {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _isRegistering = false;
      });
    }

    if (success) {
      // Use the custom slide transition
      Navigator.pushReplacement(
        context,
        _createSlideRoute(), // Call the function to get the PageRouteBuilder
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Sign up to start your journey with us!',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 60),

                      /// Name Input Field
                      _buildErrorText(_nameError),
                      _buildModernInputField(
                        controller: _nameController,
                        hintText: 'Full Name',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _setNameError('Name is required!');
                          } else {
                            _setNameError(null);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Email Input Field
                      _buildErrorText(_emailError),
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
                      const SizedBox(height: 40),

                      /// Create Account Button
                      _buildModernRegisterButton(
                        onPressed: _isRegistering ? null : _onSignUp,
                        isRegistering: _isRegistering,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Already have an account text
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextButton(
                onPressed:
                    _isRegistering
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
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
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      ),
      style: const TextStyle(color: Color(0xFF317575), fontSize: 18),
      cursorColor: const Color(0xFF317575),
      onChanged: onChanged,
    );
  }

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

  Widget _buildErrorText(String? error) {
    return AnimatedOpacity(
      opacity: error == null ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
        child: Text(
          error ?? '',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
