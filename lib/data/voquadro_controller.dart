import 'package:flutter/material.dart';

enum VoquadroState { idle, ready, speaking, feedback }

class VoquadroController with ChangeNotifier {
  VoquadroController._();

  static final VoquadroController instance = VoquadroController._();

  VoquadroState _voquadroState = VoquadroState.idle;
  VoquadroState get voquadroState => _voquadroState;

  void changeVoquadroState(VoquadroState newState) {
    _voquadroState = newState;
    notifyListeners();
  }
}
