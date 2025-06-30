import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/models/user_reg_model.dart';

class RegistratinViewModel with ChangeNotifier {
  final UserRegistrationData _user = UserRegistrationData();

  UserRegistrationData get user => _user;

  get email => _user.email;

  get password => _user.password;

  void updateNameEmail(String name, String email) {
    _user.name = name;
    _user.email = email;
    notifyListeners();
  }

  void updatePassword(String password) {
    _user.password = password;
    notifyListeners();
  }

  void updateSemesterClassMajor(
    String semester,
    String userClass,
    String major,
  ) {
    _user.semester = semester;
    _user.userClass = userClass;
    _user.major = major;
    notifyListeners();
  }
}
