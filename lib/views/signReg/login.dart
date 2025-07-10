import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/view_models/auth_viewmodel.dart';
import 'package:shweeshaungdaily/views/Home.dart';
import 'package:shweeshaungdaily/views/main_screen.dart';
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
  Timer? _errorTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  // Add this to your state class if not already
  String? _passwordError;

  // In _onSignIn or inside onChanged, validate:
  void _setPasswordError(String? message) {
    setState(() {
      _passwordError = message;
    });

    if (message != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _passwordError = null;
          });
        }
      });
    }
  }

  // void _onSignIn() {
  //   String email = _emailController.text;
  //   String password = _passwordController.text;

  //   print('Attempting sign-in with:');
  //   print('Email: $email');
  //   print('Password: $password');

  //   // Manual email validation
  //   if (email.isEmpty) {
  //     _setEmailError('Email is required');
  //     return;
  //   } else if (!RegExp(r'^[\w-\.]+@[\w-]+\.edu\.mm$').hasMatch(email)) {
  //     _setEmailError('Edu mail only');
  //     return;
  //   }

  //   if (password.length < 8) {
  //     _setPasswordError('Password must be at least 4 characters');
  //     return;
  //   }
  //   // All validations passed
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const RegisterPage()),
  //   );
  // }

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
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 50),
                      const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome back! Let\'s see if you remember the magic words.',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      // ...existing code for fields and button...
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            opacity: _emailError == null ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 12.0,
                                bottom: 6.0,
                              ),
                              child: Text(
                                _emailError ?? '',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF57C5BE),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.mail_outline,
                                  color: Colors.white,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 18.0,
                                  horizontal: 10.0,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              cursorColor: Colors.white,
                              validator:
                                  (_) => null, // disable default validator
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            opacity: _passwordError == null ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 12.0,
                                bottom: 6.0,
                              ),
                              child: Text(
                                _passwordError ?? '',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF57C5BE),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(
                                  Icons.vpn_key_outlined,
                                  color: Colors.white,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18.0,
                                  horizontal: 10.0,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              cursorColor: Colors.white,
                              validator:
                                  (_) => null, // disable default validator
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password page or show dialog
                            print('Forgot Password tapped');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF317575),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed:
                            authViewModel.isLoading
                                ? null
                                : () async {
                                  String email = _emailController.text;
                                  String password = _passwordController.text;

                                  print('Attempting sign-in with:');
                                  print('Email: $email');
                                  print('Password: $password');

                                  // Manual email validation
                                  if (email.isEmpty) {
                                    _setEmailError('Email is required');
                                    return;
                                  }

                                  if (password.isEmpty) {
                                    _setPasswordError('Please fill password');
                                    return;
                                  }

                                  bool success = await authViewModel.login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                  if (success && context.mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                      (Route<dynamic> route) =>
                                          false, // This removes all previous routes
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Login failed'),
                                      ),
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF317575),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(1),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: 'Don\'t have an account? ',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign up',
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
