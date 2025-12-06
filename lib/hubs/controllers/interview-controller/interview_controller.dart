import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/services/sound_service.dart';

enum InterviewState {
  home,
  profile,
  status,
  journey,
  micTest,
  readying,
  interviewing,
  inFeedback,
  underConstruction,
}

class InterviewController with ChangeNotifier {
  final AudioController _audioController;
  final SoundService _soundService;
  AppFlowController _appFlowController;

  InterviewState _currentState = InterviewState.home;
  InterviewState get currentState => _currentState;

  // Gameplay State
  String? _currentQuestion;
  String? get currentQuestion => _currentQuestion;

  int _readyingTimeRemaining = 0;
  int get readyingTimeRemaining => _readyingTimeRemaining;

  int _maxReadyingDuration = 30;
  int get maxReadyingDuration => _maxReadyingDuration;

  double _speakingProgress = 0.0;
  double get speakingProgress => _speakingProgress;

  // Dependencies getter
  AudioController get audioController => _audioController;

  InterviewController({
    required AudioController audioController,
    required AppFlowController appFlowController,
    required SoundService soundService,
  }) : _audioController = audioController,
       _appFlowController = appFlowController,
       _soundService = soundService;

  /// Updates the AppFlowController when the provider updates
  void update(AppFlowController appFlowController) {
    _appFlowController = appFlowController;
  }

  /// Changes the current state of the interview hub
  void changeState(InterviewState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      notifyListeners();
    }
  }

  // --- Navigation Methods ---

  void showHome() => changeState(InterviewState.home);
  void showProfile() => changeState(InterviewState.profile);
  void showStatus() => changeState(InterviewState.status);
  void showJourney() => changeState(InterviewState.journey);
  void showUnderConstruction() => changeState(InterviewState.underConstruction);

  // --- Gameplay Flow Stubs ---

  void startMicTest() {
    changeState(InterviewState.micTest);
  }

  void startReadying() {
    changeState(InterviewState.readying);
    // Temporary mock logic for UI testing
    _currentQuestion = "Tell me about a time you failed.";
    _readyingTimeRemaining = 30;
    notifyListeners();
  }

  void startInterview() {
    changeState(InterviewState.interviewing);
  }

  void endInterview() {
    changeState(InterviewState.inFeedback);
  }

  void exitGameplay() {
    changeState(InterviewState.home);
  }
}