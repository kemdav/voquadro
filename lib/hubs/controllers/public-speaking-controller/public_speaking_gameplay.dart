import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'public_speaking_state_manager.dart';

mixin PublicSpeakingGameplay on ChangeNotifier {
  // --- REQUIRED DEPENDENCIES (to be provided by the controller) ---

  /// Provides the audio controller for recording.
  AudioController get audioController;

  /// A method to change the overall state of the public speaking feature.
  void setPublicSpeakingState(PublicSpeakingState newState);

  /// A method to transition to the feedback view.
  void showFeedback();

  /// A method to clear session data when starting a new session.
  void clearSessionData();

  // --- INTERNAL STATE & METHODS ---

  Timer? _readyingTimer;
  Timer? _speakingTimer;

  static const readyingDuration = Duration(seconds: 5);
  static const speakingDuration = Duration(seconds: 10);

  double _speakingProgress = 0.0;
  double get speakingProgress => _speakingProgress;

  void startGameplaySequence() {
    cancelGameplaySequence(); // Stop any previous timers
    clearSessionData(); // Clear previous session data including transcript

    // Now correctly calls the method provided by the controller
    setPublicSpeakingState(PublicSpeakingState.readying);

    _readyingTimer = Timer(readyingDuration, _startSpeakingCountdown);
  }

  void _startSpeakingCountdown() {
    setPublicSpeakingState(PublicSpeakingState.speaking);
    _speakingProgress = 0.0;

    audioController.startRecording();

    int elapsedMilliseconds = 0;
    const tickInterval = Duration(milliseconds: 50);

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

  Future<void> _onGameplayTimerEnd() async {
    _speakingTimer?.cancel();
    await audioController.stopRecording();
    // Now correctly calls the method provided by the controller
    showFeedback();
  }

  /// Stops any active timers for the gameplay sequence.
  /// This is public so the controller can call it when needed (e.g., in endGameplay).
  void cancelGameplaySequence() {
    _readyingTimer?.cancel();
    _speakingTimer?.cancel();
    _speakingProgress = 0.0;
  }

  /// Cleans up resources when the controller is disposed.
  void disposeGameplay() {
    cancelGameplaySequence();
  }
}
