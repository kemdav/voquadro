import 'package:flutter/material.dart';

enum RegistrationStage {
  username,
  password,
  confirmation,
  submitting,
}

class RegistrationController with ChangeNotifier {
  RegistrationStage _stage = RegistrationStage.username;
  RegistrationStage get stage => _stage;

  String? username;
  String? password;

  void submitUsername(String name) {
    username = name;
    _stage = RegistrationStage.password;
    notifyListeners();
  }

  void submitPassword(String pass) {
    password = pass;
    _stage = RegistrationStage.confirmation;
    notifyListeners();
  }

  void goBack() {
    if (_stage == RegistrationStage.password) {
      _stage = RegistrationStage.username;
    } else if (_stage == RegistrationStage.confirmation) {
      _stage = RegistrationStage.password;
    }
    notifyListeners();
  }

  Future<void> completeRegistration() async {
    _stage = RegistrationStage.submitting;
    notifyListeners();

    // Imagine API call here...
    await Future.delayed(const Duration(seconds: 2));

    // After success, the Main App Controller takes over.
    // The registration flow is now complete.
  }
}