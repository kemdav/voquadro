import 'package:flutter/material.dart';
import 'package:voquadro/services/user_service.dart';
import 'package:voquadro/utils/exceptions.dart';

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
  User? currentUser; // Stores the custom User object from UserService

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

  void updateCurrentUser(User updatedUser) {
    currentUser = updatedUser;
    notifyListeners();
  }

  void goBackToLaunchScreen() {
    _appState = AppState.firstLaunch;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _appState = AppState.authenticating;
    loginErrorMessage = null;
    notifyListeners();

    try {
      // Call secure UserService to perform authentication
      final user = await UserService.signInWithUsernameAndPassword(
        username: username,
        password: password,
      );

      currentUser = user; // Store the user data
      _appState = AppState.authenticated;
    } on AuthException catch (e) {
      //Catch the specific, structured error type.
      _appState = AppState.login;
      //Assign the clean message directly
      loginErrorMessage = e.message;
    } catch (e) {
      //Catch any other unexpected errors.
      _appState = AppState.login;
      loginErrorMessage =
          'An unexpected error occurred. Please try again later.';
    }

    notifyListeners();
  }

  void logout() {
    // session to clear. Just clearing the local state
    currentUser = null;
    _appState = AppState.unauthenticated;
    notifyListeners();
  }
}
