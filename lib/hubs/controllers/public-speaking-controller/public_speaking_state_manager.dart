import 'package:flutter/material.dart';

enum PublicSpeakingState {
  home,
  profile,
  status,
  journey,
  micTest, // The gameplay mic test
  micTestOnly,
  readying,
  speaking,
  inFeedback,
  underConstruction,
}

enum FeedbackStep {
  transcript,
  speakFeedback,
  statFeedback,
  progressionDisplay,
}

mixin PublicSpeakingStateManager on ChangeNotifier {
  PublicSpeakingState _currentState = PublicSpeakingState.home;
  PublicSpeakingState get currentState => _currentState;

  FeedbackStep _currentFeedbackStep = FeedbackStep.transcript;
  FeedbackStep get currentFeedbackStep => _currentFeedbackStep;

  void showHome() {
    setPublicSpeakingState(PublicSpeakingState.home);
  }

  void showJourney() {
    setPublicSpeakingState(PublicSpeakingState.journey);
  }

  void showStatus() {
    setPublicSpeakingState(PublicSpeakingState.status);
  }

  void startMicTest() {
    setPublicSpeakingState(PublicSpeakingState.micTest);
  }

  void startMicTestOnly() {
    setPublicSpeakingState(PublicSpeakingState.micTestOnly);
  }

  void goToNextFeedbackStep() {
    if (_currentFeedbackStep == FeedbackStep.progressionDisplay) {
      setPublicSpeakingState(PublicSpeakingState.home);
    } else {
      int nextIndex = _currentFeedbackStep.index + 1;
      _currentFeedbackStep = FeedbackStep.values[nextIndex];
      notifyListeners();
    }
  }

  void setPublicSpeakingState(PublicSpeakingState newState) {
    _currentState = newState;
    notifyListeners();
  }

  void setFeedbackStep(FeedbackStep newStep) {
    _currentFeedbackStep = newStep;
    notifyListeners();
  }

  void showUnderConstruction() {
    setPublicSpeakingState(PublicSpeakingState.underConstruction);
  }
}
