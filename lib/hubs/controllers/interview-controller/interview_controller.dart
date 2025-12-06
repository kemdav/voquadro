import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/services/sound_service.dart';
import 'interview_gameplay.dart';

enum InterviewState {
  home,
  profile,
  status,
  journey,
  micTest,
  loading, // AI Loading Buffer
  readying,
  interviewing,
  inFeedback,
  underConstruction,
}

class InterviewController with ChangeNotifier, InterviewGameplay {
  final AudioController _audioController;

  InterviewState _currentState = InterviewState.home;
  InterviewState get currentState => _currentState;

  // Dependencies getter
  AudioController get audioController => _audioController;

  InterviewController({
    required AudioController audioController,
    required AppFlowController appFlowController,
    required SoundService soundService,
  }) : _audioController = audioController;

  @override
  void dispose() {
    disposeGameplay();
    super.dispose();
  }

  /// Updates the AppFlowController when the provider updates
  void update(AppFlowController appFlowController) {
    // Update logic if needed
  }

  /// Changes the current state of the interview hub
  @override
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