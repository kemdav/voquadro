import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'interview_controller.dart';

mixin InterviewGameplay on ChangeNotifier {
  // --- REQUIRED DEPENDENCIES (from InterviewController) ---
  void changeState(InterviewState newState);
  
  // --- GAMEPLAY STATE ---
  
  // AI Generated Info
  String _role = "";
  String _scenario = "";
  String _interviewerName = "";
  
  String get role => _role;
  String get scenario => _scenario;
  String get interviewerName => _interviewerName;

  // Interviewer Speaking Indicator
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  // Readying Timer
  Timer? _readyingTimer;
  static const int _maxReadyingTime = 120; // 2 minutes
  int _readyingTimeRemaining = _maxReadyingTime;
  
  int get readyingTimeRemaining => _readyingTimeRemaining;
  int get maxReadyingTime => _maxReadyingTime;

  // Interview State
  bool _isMicMuted = false;
  bool get isMicMuted => _isMicMuted;

  String _interviewerSubtitle = "";
  String get interviewerSubtitle => _interviewerSubtitle;

  // --- FLOW METHODS ---

  void updateSubtitle(String text) {
    _interviewerSubtitle = text;
    notifyListeners();
  }

  void clearSubtitle() {
    _interviewerSubtitle = "";
    notifyListeners();
  }

  void toggleMic() {
    if (_isSpeaking) return; // Prevent toggling while AI is speaking
    _isMicMuted = !_isMicMuted;
    notifyListeners();
  }

  /// Called when Mic Test is successful.
  /// Starts the "Loading" phase where AI generates content.
  void onMicTestPassed() {
    changeState(InterviewState.loading);
    _simulateAiGeneration();
  }

  /// Simulates AI generation delay, then moves to Readying.
  void _simulateAiGeneration() {
    // Simulate 2-3 seconds delay
    Future.delayed(const Duration(seconds: 3), () {
      // Mock Data Generation
      _role = "Senior Flutter Developer";
      _scenario = "You are applying for a senior position at a tech startup. "
          "The company values clean code and scalable architecture.";
      _interviewerName = "Sarah Jenkins";
      
      // Move to Readying
      _startReadyingPhase();
    });
  }

  void _startReadyingPhase() {
    changeState(InterviewState.readying);
    _readyingTimeRemaining = _maxReadyingTime;
    notifyListeners();
    
    _readyingTimer?.cancel();
    _readyingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_readyingTimeRemaining > 0) {
        _readyingTimeRemaining--;
        notifyListeners();
      } else {
        enterInterviewRoom();
      }
    });
  }

  /// User clicks "I'm Ready" or timer runs out.
  void enterInterviewRoom() {
    _readyingTimer?.cancel();
    changeState(InterviewState.interviewing);
    
    // Start the mock conversation using the dynamic subtitle system
    Future.delayed(const Duration(seconds: 1), () {
      playAiResponse(
        "Hello! Thanks for joining me today. "
        "I've reviewed your resume and I'm excited to chat. "
        "Let's start with a simple question Tell me about yourself Let's start with a simple question Tell me about yourself."
      );
    });
  }

  // Control flag for speech playback
  bool _isPlayingResponse = false;

  /// Simulates the AI speaking a response with synchronized subtitles.
  /// This function takes the full response text and updates subtitles sequentially
  /// to mimic the flow of speech.
  Future<void> playAiResponse(String fullResponse) async {
    _isPlayingResponse = true;
    _isSpeaking = true;
    _isMicMuted = true; // Mute user while AI speaks
    notifyListeners();

    // 1. Split into sentences first
    final sentences = fullResponse.split(RegExp(r'(?<=[.!?])\s+'));

    for (final sentence in sentences) {
      if (!_isPlayingResponse) break;

      // 2. Check if sentence is too long (e.g. > 80 chars) and needs chunking
      if (sentence.length > 80) {
        final chunks = _splitIntoChunks(sentence, 80);
        for (final chunk in chunks) {
          if (!_isPlayingResponse) break;
          await _displaySubtitleChunk(chunk);
        }
      } else {
        await _displaySubtitleChunk(sentence);
      }
    }

    if (_isPlayingResponse) {
      clearSubtitle();
      _isSpeaking = false;
      _isPlayingResponse = false;
      _isMicMuted = false; // Unmute user so they can answer
      notifyListeners();
    }
  }

  Future<void> _displaySubtitleChunk(String text) async {
    updateSubtitle(text);
    // Calculate duration: ~50ms per character + 600ms buffer
    // Slightly faster per char for reading flow
    final duration = Duration(milliseconds: (text.length * 50) + 600);
    await Future.delayed(duration);
  }

  /// Helper to split long text into smaller chunks at word boundaries
  List<String> _splitIntoChunks(String text, int maxLength) {
    final List<String> chunks = [];
    final words = text.split(' ');
    String currentChunk = "";

    for (final word in words) {
      if ((currentChunk + word).length > maxLength) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
          currentChunk = "";
        }
      }
      currentChunk += "$word ";
    }
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    return chunks;
  }

  /// Stops any ongoing AI speech and clears subtitles
  void stopSpeaking() {
    _isPlayingResponse = false;
    _isSpeaking = false;
    _isMicMuted = false;
    clearSubtitle();
  }

  /// Clean up timers when exiting or disposing
  void disposeGameplay() {
    _readyingTimer?.cancel();
    stopSpeaking();
  }

  /// Resets all gameplay state to default
  void resetGameplay() {
    _readyingTimer?.cancel();
    stopSpeaking();
    _role = "";
    _scenario = "";
    _interviewerName = "";
    _readyingTimeRemaining = _maxReadyingTime;
    _isMicMuted = false;
    _interviewerSubtitle = "";
    notifyListeners();
  }
}
