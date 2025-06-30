import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/view_models/reg_viewmodel.dart';
import 'package:shweeshaungdaily/views/signReg/createpassword.dart';
import 'package:shweeshaungdaily/views/signReg/login.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  // A boolean to control the visibility of the "Verified" status.
  // In a real app, this would be updated based on actual email verification.
  // ignore: prefer_typing_uninitialized_variables
  var _isVerified; // Set to true to show "Verified" initially for testing

  void _resendEmail() {
    // TODO: Implement logic to resend the verification email
    print('Resend Email button pressed!');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email resent!')));
    // In a real app, you might also reset _isVerified to false
    // or trigger a check for verification.
  }

  _onContinue(email) async {
    _isVerified = await ApiService.verifyMail(email);
    // TODO: Implement logic to check if email is actually verified
    // before navigating. For now, we'll just navigate..

    if (_isVerified == true) {
      setState(() {
        // Update the state to reflect verification
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreatePasswordPage()),
      );
    } else {
      // In a real app, you'd check backend for verification status
      // before allowing continuation. For this example, if _isVerified is false,
      // we might show a message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email first!')),
      );
      print('Continue button pressed, but email not verified yet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistratinViewModel>(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFD4F7F5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 70),
                  const Text(
                    'Check your email',
                    style: TextStyle(
                      color: Color(0xFF317575),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF317575),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'We have send a verification link to your personal email.',
                    style: TextStyle(
                      color: Color(0xFF317575),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'If email don\'t receive!',
                          style: TextStyle(
                            color: Color(0xFF317575),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: _resendEmail,
                          child: const Text(
                            'Resend Email',
                            style: TextStyle(
                              color: Color.fromARGB(255, 28, 95, 95),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (_isVerified == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Color(0xFF317575),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check_circle, color: Colors.green, size: 28),
                      ],
                    ),
                  if (_isVerified == null) const SizedBox(height: 24),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _onContinue(provider.email),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF317575),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
