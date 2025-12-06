import 'dart:async';
import 'package:flutter/material.dart';
import 'interview_controller.dart';

mixin InterviewGameplay on ChangeNotifier {
  // --- REQUIRED DEPENDENCIES (from InterviewController) ---
  void changeState(InterviewState newState);
  
  // --- GAMEPLAY STATE ---
  
  // AI Generated Info
  String _role = "";
  String _scenario = "";
  String _interviewerName = "";
  
  String get role => _role;
  String get scenario => _scenario;
  String get interviewerName => _interviewerName;

  // Readying Timer
  Timer? _readyingTimer;
  static const int _maxReadyingTime = 120; // 2 minutes
  int _readyingTimeRemaining = _maxReadyingTime;
  
  int get readyingTimeRemaining => _readyingTimeRemaining;
  int get maxReadyingTime => _maxReadyingTime;

  // Interview State
  bool _isMicMuted = false;
  bool get isMicMuted => _isMicMuted;

  // --- FLOW METHODS ---

  void toggleMic() {
    _isMicMuted = !_isMicMuted;
    notifyListeners();
  }

  /// Called when Mic Test is successful.
  /// Starts the "Loading" phase where AI generates content.
  void onMicTestPassed() {
    changeState(InterviewState.loading);
    _simulateAiGeneration();
  }

  /// Simulates AI generation delay, then moves to Readying.
  void _simulateAiGeneration() {
    // Simulate 2-3 seconds delay
    Future.delayed(const Duration(seconds: 3), () {
      // Mock Data Generation
      _role = "Senior Flutter Developer";
      _scenario = "You are applying for a senior position at a tech startup. "
          "The company values clean code and scalable architecture.";
      _interviewerName = "Sarah Jenkins";
      
      // Move to Readying
      _startReadyingPhase();
    });
  }

  void _startReadyingPhase() {
    changeState(InterviewState.readying);
    _readyingTimeRemaining = _maxReadyingTime;
    notifyListeners();
    
    _readyingTimer?.cancel();
    _readyingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_readyingTimeRemaining > 0) {
        _readyingTimeRemaining--;
        notifyListeners();
      } else {
        enterInterviewRoom();
      }
    });
  }

  /// User clicks "I'm Ready" or timer runs out.
  void enterInterviewRoom() {
    _readyingTimer?.cancel();
    changeState(InterviewState.interviewing);
  }

  /// Clean up timers when exiting or disposing
  void disposeGameplay() {
    _readyingTimer?.cancel();
  }

  /// Resets all gameplay state to default
  void resetGameplay() {
    _readyingTimer?.cancel();
    _role = "";
    _scenario = "";
    _interviewerName = "";
    _readyingTimeRemaining = _maxReadyingTime;
    _isMicMuted = false;
    notifyListeners();
  }
}
