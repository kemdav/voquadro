import 'package:flutter/material.dart';

enum AppState {
  firstLaunch,
  registration,
  login,
  unauthenticated,
  authenticating,
  authenticated,
}

enum AppMode {
  modeSelection,
  publicSpeaking
}

class AppFlowController with ChangeNotifier {
  AppState _appState = AppState.firstLaunch;
  AppState get appState => _appState;

  AppMode _currentMode = AppMode.publicSpeaking;
  AppMode get currentMode => _currentMode;

  String? loginErrorMessage;

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

  void goBackToLaunchScreen(){
    _appState = AppState.firstLaunch;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _appState = AppState.authenticating;
    loginErrorMessage = null;
    notifyListeners();

    // --- Replace this with authentication logic ---
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    final bool success = (email == 'test' && password == 'pass');
    // ---------------------------------------------------------

    if (success) {
      _appState = AppState.authenticated;
    } else {
      _appState = AppState.unauthenticated;
      loginErrorMessage = 'Wrong, try again bucko. TEST';
    }
    notifyListeners();
  }

  void logout() {
    _appState = AppState.unauthenticated;
    notifyListeners();
  }
}
