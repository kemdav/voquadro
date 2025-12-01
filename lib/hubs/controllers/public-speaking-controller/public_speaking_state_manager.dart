import 'package:flutter/material.dart';

enum PublicSpeakingState {
  home,
  profile,
  status,
  // [ADDED] 'journey' state.
  // We add this so the PublicSpeakingController can track when the user
  // is viewing the Journey screen. This allows us to switch tabs instead of pushing pages.
  journey,
  micTest,
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

  // [ADDED] showJourney method.
  // This method is called by the bottom navigation bar. It simply updates the state variable.
  // Because this uses 'notifyListeners()', the PublicSpeakingHub will rebuild and show the
  // Journey screen instantly via the IndexedStack.
  void showJourney() {
    setPublicSpeakingState(PublicSpeakingState.journey);
  }

  void showStatus() {
    setPublicSpeakingState(PublicSpeakingState.status);
  }

  void startMicTest() {
    setPublicSpeakingState(PublicSpeakingState.micTest);
  }

  void goToNextFeedbackStep() {
    if (_currentFeedbackStep == FeedbackStep.progressionDisplay) {
      // Assuming endGameplay() is in the main controller
      // This can be handled by a callback or by overriding this method.
      // For simplicity, we'll just move the core logic here.
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
