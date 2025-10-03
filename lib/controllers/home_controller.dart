import 'package:flutter/material.dart';

enum HomeStage { home, profile, statistics }

class HomeController with ChangeNotifier {
  HomeStage _stage = HomeStage.home;
  HomeStage get stage => _stage;

  void gotoProfile() {
    _stage = HomeStage.profile;
    notifyListeners();
  }

  void gotoStatistics() {
    _stage = HomeStage.statistics;
    notifyListeners();
  }

  void gotoHome() {
    _stage = HomeStage.home;
    notifyListeners();
  }

  void goBack() {
    if (_stage != HomeStage.home) {
      _stage = HomeStage.home;
    }
    notifyListeners();
  }
}
