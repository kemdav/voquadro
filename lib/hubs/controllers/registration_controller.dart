import 'package:flutter/material.dart';
import 'package:voquadro/services/user_service.dart';

enum RegistrationStage { username, password, confirmation, submitting }

class RegistrationController with ChangeNotifier {
  RegistrationStage _stage = RegistrationStage.username;
  RegistrationStage get stage => _stage;

  String? username;
  String? email;
  String? password;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> submitUsername(String name, String emailAddress) async {
    _errorMessage = null;

    try {
      // Check if username is already taken
      final isUsernameTaken = await UserService.isUsernameTaken(name);
      if (isUsernameTaken) {
        _errorMessage = 'Username is already taken';
        notifyListeners();
        return;
      }

      // Check if email is already taken
      final isEmailTaken = await UserService.isEmailTaken(emailAddress);
      if (isEmailTaken) {
        _errorMessage = 'Email is already taken';
        notifyListeners();
        return;
      }

      username = name;
      email = emailAddress;
      _stage = RegistrationStage.password;
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Unable to create account. Please try again or contact support.';
      notifyListeners();
    }
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
    _errorMessage = null;
    notifyListeners();

    try {
      // Create user in database
      await UserService.createUser(
        username: username!,
        email: email!,
        password: password!,
      );

      // Registration successful - the Main App Controller takes over
    } catch (e) {
      _errorMessage = 'Failed to create account: ${e.toString()}';
      _stage = RegistrationStage.confirmation; // Go back to confirmation stage
      notifyListeners();
    }
  }
}
