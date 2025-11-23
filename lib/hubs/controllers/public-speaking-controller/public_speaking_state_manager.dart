import 'package:flutter/material.dart';

enum PublicSpeakingState {
  home,
  profile,
  status,
  micTest,
  readying,
  speaking,
  inFeedback,
}

enum FeedbackStep {
  transcript,
  speakFeedback,
  statFeedback,
  progressionDisplay,
  nextRankDisplay,
}

mixin PublicSpeakingStateManager on ChangeNotifier {
  PublicSpeakingState _currentState = PublicSpeakingState.home;
  PublicSpeakingState get currentState => _currentState;

  FeedbackStep _currentFeedbackStep = FeedbackStep.transcript;
  FeedbackStep get currentFeedbackStep => _currentFeedbackStep;

  void showHome() {
    _currentState = PublicSpeakingState.home;
    notifyListeners();
  }

  void showStatus() {
    _currentState = PublicSpeakingState.status;
    notifyListeners();
  }

  void startMicTest() {
    _currentState = PublicSpeakingState.micTest;
    notifyListeners();
  }

  void goToNextFeedbackStep() {
    if (_currentFeedbackStep == FeedbackStep.nextRankDisplay) {
      // Assuming endGameplay() is in the main controller
      // This can be handled by a callback or by overriding this method.
      // For simplicity, we'll just move the core logic here.
      _currentState = PublicSpeakingState.home;
    } else {
      int nextIndex = _currentFeedbackStep.index + 1;
      _currentFeedbackStep = FeedbackStep.values[nextIndex];
    }
    notifyListeners();
  }

  // This method would be called by other parts of the controller
  // to change the state.
  void setPublicSpeakingState(PublicSpeakingState newState) {
    _currentState = newState;
    notifyListeners();
  }

  void setFeedbackStep(FeedbackStep newStep) {
    _currentFeedbackStep = newStep;
    notifyListeners();
  }
}
