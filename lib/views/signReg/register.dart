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
  State<RegisterPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _obscureText = true;

  String? _emailError;
  String? _nameError;
  Timer? _errorTimer;
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
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

  void _onSignUp() async {
    String email = _emailController.text;
    String name = _nameController.text;

    print('Attempting sign-in with:');
    print('Name: $name');
    print('Email: $email');

    // Manual email validation
    if (email.isEmpty && name.isEmpty) {
      _setEmailError('Email is required');
      _setNameError('Name is required');
      return;
    }
    if (email.isEmpty && name.isNotEmpty) {
      _setEmailError('Email is required');
      return;
    }
    if (name.isEmpty && email.isNotEmpty) {
      _setNameError('Name is required');
      return;
    } else if (!RegExp(r'^[\w-\.]+@[\w-]+\.edu\.mm$').hasMatch(email)) {
      _setEmailError('Edu mail only');
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
      const SnackBar(
        content: Text('Registering...'),
        duration: Duration(
          days: 1,
        ), // Effectively keeps it until manually hidden
      ),
    );
    bool success = false;
    try {
      success = await authViewModel.registerEmail(email, name);
    } catch (e) {
      success = false;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _isRegistering = false;
    });
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerifyEmailPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
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
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 50),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue your journey',
                        style: TextStyle(
                          color: Color(0xFF317575),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 80),
                      // ...existing code for fields and button...
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            opacity: _nameError == null ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 12.0,
                                bottom: 6.0,
                              ),
                              child: Text(
                                _nameError ?? '',
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
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                hintText: 'Full Name',
                                hintStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.person,
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
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  _setNameError('Name is required!');
                                } else {
                                  _setNameError(null);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
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
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  _setEmailError('Email is required!');
                                } else if (!RegExp(
                                  r'^[\w-\.]+@[\w-]+\.edu\.mm$',
                                ).hasMatch(value)) {
                                  _setEmailError('Edu mail only !');
                                } else {
                                  _setEmailError(null);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      ElevatedButton(
                        onPressed: _isRegistering ? null : _onSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF317575),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(1),
                          disabledBackgroundColor: const Color(0xFF317575),
                          disabledForegroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Create',
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
