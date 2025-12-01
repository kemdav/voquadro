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

enum AppMode { modeSelection, publicSpeaking, interview }

class AppFlowController with ChangeNotifier {
  AppState _appState = AppState.authenticating;
  AppState get appState => _appState;

  AppMode _currentMode = AppMode.publicSpeaking;
  AppMode get currentMode => _currentMode;

  String? loginErrorMessage;
  User? currentUser; // Stores the custom User object from UserService

  AppFlowController() {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final userId = UserService.getCurrentUserId();
    if (userId != null) {
      try {
        final user = await UserService.getFullUserProfile(userId);
        currentUser = user;
        _appState = AppState.authenticated;
      } catch (e) {
        await UserService.signOut();
        _appState = AppState.firstLaunch;
      }
    } else {
      _appState = AppState.firstLaunch;
    }
    notifyListeners();
  }

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

  void updateUser(User newUser) {
    currentUser = newUser;
    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint('AppFlowController: Logout initiated');
    try {
      //Call the service to sign the user out from the backend (Supabase)
      await UserService.signOut();
      debugPrint('AppFlowController: UserService.signOut completed');

      //Clear the local user state
      currentUser = null;
      //Set the app state to show the first launch screen
      _appState = AppState.firstLaunch;
      debugPrint(
        'AppFlowController: State set to firstLaunch, notifying listeners',
      );
      notifyListeners();
      debugPrint('AppFlowController: Listeners notified');
    } catch (e) {
      debugPrint('AppFlowController: Error during logout: $e');
      // Force state reset anyway
      _appState = AppState.firstLaunch;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    // Call the service to perform the backend deletion.
    await UserService.deleteCurrentUserAccount();

    // Clear the local user state, just like in logout().
    currentUser = null;
    _appState = AppState.firstLaunch;
    notifyListeners();
  }
}
