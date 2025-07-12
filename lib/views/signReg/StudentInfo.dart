import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/view_models/auth_viewmodel.dart';
import 'package:shweeshaungdaily/view_models/reg_viewmodel.dart';
import 'package:shweeshaungdaily/views/Home.dart';
import 'package:shweeshaungdaily/views/signReg/login.dart' show SignInPage;

class StudendInfoPage extends StatefulWidget {
  const StudendInfoPage({super.key});

  @override
  State<StudendInfoPage> createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudendInfoPage> {
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _semesterError;
  String? _classError;
  String? _majorError;

  Future<void> _onSignIn() async {
    String semester = _semesterController.text;
    String stuclass = _classController.text;
    String major = _majorController.text;

    setState(() {
      _semesterError = semester.isEmpty ? 'Semester is required' : null;
      _classError = stuclass.isEmpty ? 'Class is required' : null;
      _majorError = major.isEmpty ? 'Major is required' : null;
    });

    if (_semesterError != null || _classError != null || _majorError != null) {
      return;
    }

    Provider.of<RegistratinViewModel>(
      context,
      listen: false,
    ).updateSemesterClassMajor(semester, stuclass, major);

    final regViewModel = Provider.of<RegistratinViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    bool success = false;
    try {
      success = await authViewModel.register(regViewModel.user);
    } catch (e) {
      success = false;
    }

    print('Attempting sign-in with:');
    print('Semester: $semester');
    print('Class: $stuclass');
    print('Major: $major');

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register. Please try again.')),
      );
      return;
    }
    await authViewModel.login(regViewModel.email, regViewModel.password);
    // All validations passed
    if (!mounted) {
      return; // Check if the widget is still mounted before navigating
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreenPage()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: kBackgroundColor,
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
                          'Start Here',
                          style: TextStyle(
                            color: kPrimaryDarkColor,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Get ready for learning - enter your details to begin',
                          style: TextStyle(
                            color: kPrimaryDarkColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        // ...existing code for fields and button...
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              opacity: _semesterError == null ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  bottom: 6.0,
                                ),
                                child: Text(
                                  _semesterError ?? '',
                                  style: const TextStyle(
                                    color: kErrorColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Inside your build method:
                            Container(
                              decoration: BoxDecoration(
                                color: kAccentColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: kShadowColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 2,
                              ),
                              child: DropdownButtonFormField2<int>(
                                value:
                                    _semesterController.text.isNotEmpty
                                        ? int.tryParse(_semesterController.text)
                                        : null,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                hint: const Row(
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Semester',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                selectedItemBuilder: (context) {
                                  return [1, 2, 3, 4, 5, 6, 7, 8, 9].map((
                                    value,
                                  ) {
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.school_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          value.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 100, // Custom dropdown width
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF57C5BE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  offset: const Offset(235, 2),
                                  scrollbarTheme: ScrollbarThemeData(
                                    thumbColor: WidgetStateProperty.all<Color>(
                                      Color(0xFF317575),
                                    ),
                                    trackColor: WidgetStateProperty.all<Color>(
                                      Colors.white24,
                                    ),
                                    radius: const Radius.circular(10),
                                    thickness: WidgetStateProperty.all<double>(
                                      4,
                                    ),
                                  ),
                                ),
                                buttonStyleData: const ButtonStyleData(
                                  height: 60,
                                  padding: EdgeInsets.only(right: 10),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                items:
                                    [
                                      1,
                                      2,
                                      3,
                                      4,
                                      5,
                                      6,
                                      7,
                                      8,
                                      9,
                                    ].asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final value = entry.value;
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 5.0,
                                                    ),
                                                child: Text(
                                                  value.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (index <
                                                  8) // Don't draw divider after last item
                                                const Divider(
                                                  color: Colors.white,
                                                  thickness: 1,
                                                  height: 1,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _semesterController.text =
                                          newValue.toString();
                                      _semesterError = null;
                                    });
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
                              opacity: _classError == null ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  bottom: 6.0,
                                ),
                                child: Text(
                                  _classError ?? '',
                                  style: const TextStyle(
                                    color: kErrorColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: kAccentColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: kShadowColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 2,
                              ),
                              child: DropdownButtonFormField2<String>(
                                value:
                                    _classController.text.isNotEmpty
                                        ? (_classController.text)
                                        : null,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                hint: const Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Class',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                selectedItemBuilder: (context) {
                                  return ['A', 'B', 'C', 'D'].map((value) {
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.menu_book_outlined,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          value.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 100, // Custom dropdown width
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF57C5BE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  offset: const Offset(235, 2),
                                  scrollbarTheme: ScrollbarThemeData(
                                    thumbColor: WidgetStateProperty.all<Color>(
                                      Color(0xFF317575),
                                    ),
                                    trackColor: WidgetStateProperty.all<Color>(
                                      Colors.white24,
                                    ),
                                    radius: const Radius.circular(10),
                                    thickness: WidgetStateProperty.all<double>(
                                      4,
                                    ),
                                  ),
                                ),
                                buttonStyleData: const ButtonStyleData(
                                  height: 60,
                                  padding: EdgeInsets.only(right: 10),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                items:
                                    ['A', 'B', 'C', 'D'].asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final value = entry.value;
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 5.0,
                                                    ),
                                                child: Text(
                                                  value.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (index <
                                                  3) // Don't draw divider after last item
                                                const Divider(
                                                  color: Colors.white,
                                                  thickness: 1,
                                                  height: 1,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _classController.text = newValue;
                                      _classError = null;
                                    });
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
                              opacity: _majorError == null ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  bottom: 6.0,
                                ),
                                child: Text(
                                  _majorError ?? '',
                                  style: const TextStyle(
                                    color: kErrorColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: kAccentColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: kShadowColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 2,
                              ),
                              child: DropdownButtonFormField2<String>(
                                value:
                                    _majorController.text.isNotEmpty
                                        ? (_majorController.text)
                                        : null,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                hint: const Row(
                                  children: [
                                    Icon(
                                      Icons.computer_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Major',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                selectedItemBuilder: (context) {
                                  return ['CST', 'CS', 'CT'].map((value) {
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.computer_outlined,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          value.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 100, // Custom dropdown width
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF57C5BE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  offset: const Offset(235, 2),
                                  scrollbarTheme: ScrollbarThemeData(
                                    thumbColor: WidgetStateProperty.all<Color>(
                                      Color(0xFF317575),
                                    ),
                                    trackColor: WidgetStateProperty.all<Color>(
                                      Colors.white24,
                                    ),
                                    radius: const Radius.circular(10),
                                    thickness: WidgetStateProperty.all<double>(
                                      4,
                                    ),
                                  ),
                                ),
                                buttonStyleData: const ButtonStyleData(
                                  height: 60,
                                  padding: EdgeInsets.only(right: 10),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                items:
                                    ['CST', 'CS', 'CT'].asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final value = entry.value;
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 5.0,
                                                    ),
                                                child: Text(
                                                  value.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (index <
                                                  2) // Don't draw divider after last item
                                                const Divider(
                                                  color: Colors.white,
                                                  thickness: 1,
                                                  height: 1,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _majorController.text = newValue;
                                      _majorError = null;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: _onSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryDarkColor,
                            foregroundColor: kWhite,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: kShadowColor.withOpacity(1),
                          ),
                          child: const Text(
                            'Sign In',
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
                            color: kPrimaryColor,
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
}
