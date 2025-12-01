import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'public_speaking_state_manager.dart';

mixin PublicSpeakingGameplay on ChangeNotifier {
  // --- REQUIRED DEPENDENCIES ---
  AudioController get audioController;
  void setPublicSpeakingState(PublicSpeakingState newState);
  void showFeedback([Duration? duration]);
  void clearSessionData();

  // --- INTERNAL STATE & METHODS ---

  Timer? _readyingTimer;
  Timer? _speakingTimer;

  static const readyingDuration = Duration(seconds: 30);
  static const speakingDuration = Duration(seconds: 60);

  double _speakingProgress = 0.0;
  double get speakingProgress => _speakingProgress;

  // NEW: Track the actual time spoken using Stopwatch for accuracy
  final Stopwatch _speakingStopwatch = Stopwatch();

  // NEW: Getter for the controller to access
  double get actualSpeakingDurationInSeconds =>
      _speakingStopwatch.elapsedMilliseconds / 1000.0;

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

    // NEW: Reset and start stopwatch
    _speakingStopwatch.reset();
    _speakingStopwatch.start();

    audioController.startRecording();

    const tickInterval = Duration(milliseconds: 50);

    _speakingTimer = Timer.periodic(tickInterval, (timer) {
      // 1. Update progress based on wall-clock time
      final elapsedMilliseconds = _speakingStopwatch.elapsedMilliseconds;
      _speakingProgress = elapsedMilliseconds / speakingDuration.inMilliseconds;

      if (_speakingProgress >= 1.0) {
        _speakingProgress = 1.0;
        _speakingStopwatch.stop();
        notifyListeners();
        _onGameplayTimerEnd(_speakingStopwatch.elapsed);
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> finishSpeechEarly() async {
    _speakingTimer?.cancel();
    _speakingStopwatch.stop();
    final duration = _speakingStopwatch.elapsed;
    _speakingProgress = 1.0;
    notifyListeners();
    // The _speakingStopwatch now holds the exact time stopped at.
    await _onGameplayTimerEnd(duration);
  }

  Future<void> _onGameplayTimerEnd([Duration? duration]) async {
    _speakingTimer?.cancel();
    _speakingStopwatch.stop(); // Ensure it's stopped
    final finalDuration = duration ?? _speakingStopwatch.elapsed;
    await audioController.stopRecording();
    showFeedback(finalDuration);
  }

  void cancelGameplaySequence() {
    _readyingTimer?.cancel();
    _speakingTimer?.cancel();
    _speakingStopwatch.stop();
    // Do NOT reset the stopwatch here, so we can read the final duration
    // in showFeedback() -> onEnterFeedbackFlow().
    // _speakingStopwatch.reset(); 
    _speakingProgress = 0.0;
    _readyingTimeRemaining = 0;
  }

  void disposeGameplay() {
    cancelGameplaySequence();
  }
}