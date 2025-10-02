import 'package:flutter/material.dart';

enum AppState{
  firstLaunch,
  registration,
  login,
  unauthenticated,
  authenticating,
  authenticated
}

class AppFlowController with ChangeNotifier {
  AppState _appState = AppState.firstLaunch;
  AppState get appState => _appState;

  void initiateRegistration() {
    _appState = AppState.registration;
    notifyListeners(); 
  }

  void initiateLogin(){
    _appState = AppState.login;
    notifyListeners();
  }

  void login(String email, String password) {
    _appState = AppState.authenticating;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _appState = AppState.authenticated;
      notifyListeners();
    });
  }

  void logout() {
    _appState = AppState.unauthenticated;
    notifyListeners();
  }
}