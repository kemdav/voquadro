import 'package:flutter/material.dart';
import 'dart:async';

import 'package:voquadro/hubs/controllers/audio_controller.dart';

enum PublicSpeakingState {
  home, //0 
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
  final AudioController _audioController;

  PublicSpeakingController({required AudioController audioController})
      : _audioController = audioController;
  
  PublicSpeakingState _currentState = PublicSpeakingState.home;

  PublicSpeakingState get currentState => _currentState;

  Timer? _readyingTimer;
  Timer? _speakingTimer;

  FeedbackStep _currentFeedbackStep = FeedbackStep.transcript;
  FeedbackStep get currentFeedbackStep => _currentFeedbackStep;

  static const readyingDuration = Duration(seconds: 5);
  static const speakingDuration = Duration(seconds: 10);

  double _speakingProgress = 0.0;
  double get speakingProgress => _speakingProgress;

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
    _readyingTimer = Timer(readyingDuration, () {
      _startSpeakingCountdown();
    });
  }

  void _startSpeakingCountdown() {
    _currentState = PublicSpeakingState.speaking;
    _speakingProgress = 0.0; // Reset progress

    _audioController.startRecording();
    
    int elapsedMilliseconds = 0;
    const tickInterval = Duration(milliseconds: 50); // Update 20 times per second

    _speakingTimer = Timer.periodic(tickInterval, (timer) {
      elapsedMilliseconds += tickInterval.inMilliseconds;

      _speakingProgress = elapsedMilliseconds / speakingDuration.inMilliseconds;
      
      if (_speakingProgress >= 1.0) {
        _speakingProgress = 1.0; 
        notifyListeners();
        _onGameplayTimerEnd(); 
      } else {
        notifyListeners();
      }
    });
  }

  /// Cancels any active timers and stops the gameplay flow.
  void _cancelGameplaySequence() {
    _readyingTimer?.cancel();
    _speakingTimer?.cancel();
    _speakingProgress = 0.0;
  }

  Future<void> _onGameplayTimerEnd() async {
    // Instead of going home, start the feedback flow
    _speakingTimer?.cancel();
    await _audioController.stopRecording();
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
