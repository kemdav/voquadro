import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'public_speaking_state_manager.dart';

mixin PublicSpeakingGameplay on ChangeNotifier {
  // --- REQUIRED DEPENDENCIES ---
  AudioController get audioController;
  void setPublicSpeakingState(PublicSpeakingState newState);
  void showFeedback();
  void clearSessionData();

  // --- INTERNAL STATE & METHODS ---

  Timer? _readyingTimer;
  Timer? _speakingTimer;

  static const readyingDuration = Duration(seconds: 30);
  static const speakingDuration = Duration(seconds: 60);

  double _speakingProgress = 0.0;
  double get speakingProgress => _speakingProgress;

  // NEW: Track the actual time spoken
  Duration _elapsedSpeakingDuration = Duration.zero;

  // NEW: Getter for the controller to access
  double get actualSpeakingDurationInSeconds => 
      _elapsedSpeakingDuration.inMilliseconds / 1000.0;

  int _readyingTimeRemaining = 0;
  int get readyingTimeRemaining => _readyingTimeRemaining;
  int get maxReadyingDuration => readyingDuration.inSeconds;

  void startGameplaySequence() {
    cancelGameplaySequence();
    clearSessionData();

    setPublicSpeakingState(PublicSpeakingState.readying);

    _readyingTimeRemaining = readyingDuration.inSeconds;
    notifyListeners();

    _readyingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_readyingTimeRemaining > 0) {
        _readyingTimeRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        _startSpeakingCountdown();
      }
    });
  }

  void skipReadying() {
    _readyingTimer?.cancel();
    _readyingTimeRemaining = 0;
    notifyListeners();
    _startSpeakingCountdown();
  }

  void _startSpeakingCountdown() {
    setPublicSpeakingState(PublicSpeakingState.speaking);
    _speakingProgress = 0.0;
    
    // NEW: Reset elapsed time
    _elapsedSpeakingDuration = Duration.zero;

    audioController.startRecording();

    // Use a simpler integer for progress calculation stability
    int elapsedMilliseconds = 0; 
    const tickInterval = Duration(milliseconds: 50);

    _speakingTimer = Timer.periodic(tickInterval, (timer) {
      // 1. Update local counter for progress calculation
      elapsedMilliseconds += tickInterval.inMilliseconds;
      _speakingProgress = elapsedMilliseconds / speakingDuration.inMilliseconds;

      // 2. NEW: Update the class-level duration tracker
      _elapsedSpeakingDuration += tickInterval;

      if (_speakingProgress >= 1.0) {
        _speakingProgress = 1.0;
        notifyListeners();
        _onGameplayTimerEnd();
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> finishSpeechEarly() async {
    _speakingTimer?.cancel();
    _speakingProgress = 1.0;
    notifyListeners();
    // The _elapsedSpeakingDuration now holds the exact time stopped at.
    await _onGameplayTimerEnd();
  }

  Future<void> _onGameplayTimerEnd() async {
    _speakingTimer?.cancel();
    await audioController.stopRecording();
    showFeedback();
  }

  void cancelGameplaySequence() {
    _readyingTimer?.cancel();
    _speakingTimer?.cancel();
    _speakingProgress = 0.0;
    _readyingTimeRemaining = 0;
    _elapsedSpeakingDuration = Duration.zero; // Reset on cancel
  }

  void disposeGameplay() {
    cancelGameplaySequence();
  }
}