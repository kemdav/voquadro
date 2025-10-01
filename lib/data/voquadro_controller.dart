import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();

enum VoquadroState { idle, ready, speaking, feedback }

enum FeedbackState {
  transcript,
  speakFeedback,
  statFeedback,
  progressionDisplay,
  nextRankDisplay,
}

extension FeedbackStepExtension on FeedbackState {
  /// Returns the next step in the enum, or the first step if it's the last.
  FeedbackState get next {
    final nextIndex = (index + 1) % FeedbackState.values.length;
    return FeedbackState.values[nextIndex];
  }

  /// Returns the next step, or null if it's the last.
  FeedbackState? get nextOrNull {
    if (index == FeedbackState.values.length - 1) {
      return null;
    }
    return FeedbackState.values[index + 1];
  }
}

class VoquadroController with ChangeNotifier {
  VoquadroController._();

  static final VoquadroController instance = VoquadroController._();

  FeedbackState _feedbackState = FeedbackState.transcript;
  FeedbackState get feedbackState => _feedbackState;

  VoquadroState _voquadroState = VoquadroState.idle;
  VoquadroState get voquadroState => _voquadroState;

  void changeVoquadroState(VoquadroState newState) {
    _voquadroState = newState;
    notifyListeners();
  }

  void changeFeedbackState(FeedbackState newState) {
    _feedbackState = newState;
    notifyListeners();
  }

  void goToNextFeedbackState() {
    logger.d(
      'Going to next feedback state: from $feedbackState to ${feedbackState.next}',
    );
    _feedbackState = feedbackState.next;
    notifyListeners();
  }
}
