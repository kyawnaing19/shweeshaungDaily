import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/view_models/reg_viewmodel.dart';
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

  @override
  void dispose() {
    _passwordController.dispose();
    _conPasswordController.dispose();
    super.dispose();
  }

  String? _passwordError;
  String? _conPasswordError;

  // Password validation function
  bool _isPasswordValid(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  // Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[400],
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onCreateAccount() {
    final String password = _passwordController.text;
    final String confirmPassword = _conPasswordController.text;

    if (!_isPasswordValid(password)) {
      _showErrorMessage(
        'Password must be at least 8 characters, include uppercase, lowercase, and a number.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showErrorMessage('Passwords do not match.');
      return;
    }

    Provider.of<RegistratinViewModel>(
      context,
      listen: false,
    ).updatePassword(password);
    // Navigate to the next page (dummy here)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StudendInfoPage()),
    );
  }

  void _setPasswordError(String? message) {
    setState(() {
      _passwordError = message;
      _conPasswordError = message;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(height: 50),
                              Text(
                                'Creat New Password',
                                style: TextStyle(
                                  color: Color(0xFF317575),
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create a Legend. Or at least a legendary password.',
                                style: TextStyle(
                                  color: Color(0xFF317575),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                        // ...existing code for fields and button...
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
                                obscureText: _obscureText1,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
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
                                      _obscureText1
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText1 = !_obscureText1;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                cursorColor: Colors.white,
                                onChanged: (value) {
                                  if (value.length < 8) {
                                    _setPasswordError(
                                      'Password must be at least 8 characters',
                                    );
                                  } else {
                                    _setPasswordError(null);
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
                              opacity: _conPasswordError == null ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  bottom: 6.0,
                                ),
                                child: Text(
                                  _conPasswordError ?? '',
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
                                controller: _conPasswordController,
                                obscureText: _obscureText2,
                                decoration: InputDecoration(
                                  hintText: 'confirm Password',
                                  hintStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.key,
                                    color: Colors.white,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18.0,
                                    horizontal: 10.0,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText2
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText2 = !_obscureText2;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                cursorColor: Colors.white,
                                onChanged: (value) {
                                  if (value.length < 8) {
                                    _setPasswordError(
                                      'Password must be at least 8 characters',
                                    );
                                  } else {
                                    _setPasswordError(null);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: _onCreateAccount,
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
                            'Continue',
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
                        builder: (context) => const SignInPage(),
                      ),
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
      ),
    );
  }

  // Reusable input field widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFA5E6DD),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 10.0,
          ),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 18),
        cursorColor: Colors.white,
      ),
    );
  }
}
