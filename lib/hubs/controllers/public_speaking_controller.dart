import 'package:flutter/material.dart';
import 'dart:async';

enum PublicSpeakingState {
  home,
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

class PublicSpeakingController with ChangeNotifier {
  PublicSpeakingState _currentState = PublicSpeakingState.home;

  PublicSpeakingState get currentState => _currentState;

  Timer? _readyingTimer;
  Timer? _speakingTimer;

  FeedbackStep _currentFeedbackStep = FeedbackStep.transcript;
  FeedbackStep get currentFeedbackStep => _currentFeedbackStep;

  void showFeedback() {
    _cancelGameplaySequence();
    _currentFeedbackStep = FeedbackStep.transcript; // Reset to the first step
    _currentState = PublicSpeakingState.inFeedback;
    notifyListeners();
  }

  void goToNextFeedbackStep() {
    // If we are on the last step, finish and go home.
    if (_currentFeedbackStep == FeedbackStep.nextRankDisplay) {
      endGameplay();
    } else {
      // Otherwise, go to the next step in the enum list.
      int nextIndex = _currentFeedbackStep.index + 1;
      _currentFeedbackStep = FeedbackStep.values[nextIndex];
      notifyListeners();
    }
  }

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

  void startReadying() {
    _currentState = PublicSpeakingState.readying;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), startSpeaking);
  }

  void startSpeaking() {
    _currentState = PublicSpeakingState.speaking;
    notifyListeners();
  }


  /// Starts the entire gameplay sequence from the beginning.
  void startGameplaySequence() {
    _cancelGameplaySequence(); // Ensure no old timers are running

    _currentState = PublicSpeakingState.readying;
    notifyListeners();

    // After 5 seconds, transition from 'readying' to 'speaking'
    _readyingTimer = Timer(const Duration(seconds: 5), () {
      _currentState = PublicSpeakingState.speaking;
      notifyListeners();

      _speakingTimer = Timer(const Duration(seconds: 10), _onGameplayTimerEnd);
    });
  }

  /// Cancels any active timers and stops the gameplay flow.
  void _cancelGameplaySequence() {
    _readyingTimer?.cancel();
    _speakingTimer?.cancel();
  }

  void _onGameplayTimerEnd() {
    // Instead of going home, start the feedback flow
    showFeedback();
  }

  /// Ends the gameplay and returns to the mode's home screen.
  void endGameplay() {
    _cancelGameplaySequence();
    _currentState = PublicSpeakingState.home;
    notifyListeners();
  }

  // This is called when the provider is removed from the widget tree.
  // It's crucial for preventing memory leaks from active timers.
  @override
  void dispose() {
    _cancelGameplaySequence();
    super.dispose();
  }
}
