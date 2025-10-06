import 'package:flutter/material.dart';
import 'package:voquadro/services/user_service.dart'; // Import the user service

enum AppState {
  firstLaunch,
  registration,
  login,
  unauthenticated,
  authenticating,
  authenticated,
}

enum AppMode { modeSelection, publicSpeaking }

class AppFlowController with ChangeNotifier {
  AppState _appState = AppState.firstLaunch;
  AppState get appState => _appState;

  AppMode _currentMode = AppMode.publicSpeaking;
  AppMode get currentMode => _currentMode;

  String? loginErrorMessage;
  User? currentUser; // Store the logged-in user's data

  void initiateRegistration() {
    _appState = AppState.registration;
    notifyListeners();
  }

  void initiateLogin() {
    _appState = AppState.login;
    notifyListeners();
  }

  void selectMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  // --- THIS IS THE UPDATED LOGIN METHOD ---
  Future<void> login(String username, String password) async {
    _appState = AppState.authenticating;
    loginErrorMessage = null;
    notifyListeners();

    try {
      // Call the secure UserService to perform authentication
      final user = await UserService.signInWithUsernameAndPassword(
        username: username,
        password: password,
      );

      currentUser = user; // Store the user data
      _appState = AppState.authenticated;
    } catch (e) {
      // If authentication fails, the service throws an exception.
      _appState =
          AppState.login; // Go back to the login state so user can retry
      // Clean up the error message for display on the login page
      loginErrorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  void logout() {
    currentUser = null;
    _appState = AppState.unauthenticated;
    notifyListeners();
  }
}
