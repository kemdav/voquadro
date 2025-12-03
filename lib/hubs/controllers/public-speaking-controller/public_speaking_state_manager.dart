import 'package:flutter/material.dart';

enum PublicSpeakingState {
  home,
  profile,
  status,
  journey,
  micTest, // The gameplay mic test
  micTestOnly, // [ADDED] The standalone utility mic test
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

  // [ADDED] Flag to track if we are in Practice Mode
  bool _isPracticeMode = false;
  bool get isPracticeMode => _isPracticeMode;

  void showHome() {
    setPublicSpeakingState(PublicSpeakingState.home);
    _isPracticeMode = false; // [ADDED] Reset flag when returning home
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

  // [ADDED] Trigger for the standalone mic test
  void startMicTestOnly() {
    setPublicSpeakingState(PublicSpeakingState.micTestOnly);
  }

  // [ADDED] Trigger for Practice Mode
  void startPracticeSession() {
    _isPracticeMode = true;
    startMicTest(); // Start standard flow, but the flag determines the outcome later
  }

  void goToNextFeedbackStep() {
    // [MODIFIED] Logic to handle Practice Mode flow
    if (_isPracticeMode) {
      // Practice Flow: Transcript -> SpeakFeedback -> Home
      // Skips StatFeedback and ProgressionDisplay
      if (_currentFeedbackStep == FeedbackStep.transcript) {
        setFeedbackStep(FeedbackStep.speakFeedback);
      } else {
        // End of practice session
        showHome();
      }
    } else {
      // Standard Ranked Flow
      if (_currentFeedbackStep == FeedbackStep.progressionDisplay) {
        setPublicSpeakingState(PublicSpeakingState.home);
      } else {
        int nextIndex = _currentFeedbackStep.index + 1;
        _currentFeedbackStep = FeedbackStep.values[nextIndex];
        notifyListeners();
      }
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
