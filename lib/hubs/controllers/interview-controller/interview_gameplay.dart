import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voquadro/data/models/interview_response_model.dart';
import 'interview_controller.dart';

mixin InterviewGameplay on ChangeNotifier {
  // --- REQUIRED DEPENDENCIES (from InterviewController) ---
  void changeState(InterviewState newState);
  AudioController get audioController;
  
  // --- GAMEPLAY STATE ---
  
  // Session ID to force UI rebuilds on new sessions
  String _gameplaySessionId = DateTime.now().toIso8601String();
  String get gameplaySessionId => _gameplaySessionId;

  // Session Recording
  final List<InterviewResponseModel> _sessionResponses = [];
  List<InterviewResponseModel> get sessionResponses => List.unmodifiable(_sessionResponses);
  
  // Helper to get just paths for playback
  List<String> get sessionAudioPaths => _sessionResponses.map((e) => e.audioPath).toList();
  
  String? _mergedAudioPath;
  String? get mergedAudioPath => _mergedAudioPath;
  
  DateTime? _recordingStartTime;
  DateTime? _aiFinishedSpeakingTime;
  Duration _currentResponseLatency = Duration.zero;

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

  // AI Feedback
  String _aiFeedback = "Based on your responses, you demonstrated strong technical knowledge. However, try to reduce the use of filler words like 'um' and 'uh'. Your pacing was generally good, but you rushed slightly during the explanation of your past projects.";
  String get aiFeedback => _aiFeedback;

  // --- PROGRESSION DATA ---
  int _gainedInterviewExp = 0;
  int _gainedPaceExp = 0;
  int _gainedFillerExp = 0;

  int get gainedInterviewExp => _gainedInterviewExp;
  int get gainedPaceExp => _gainedPaceExp;
  int get gainedFillerExp => _gainedFillerExp;

  // Mock User Stats (In a real app, these would come from a UserProfileService)
  // These represent the user's stats BEFORE the current session
  final int _userInterviewLevel = 5;
  final int _userInterviewExp = 2400;
  
  final int _userPaceLevel = 3;
  final int _userPaceExp = 800;

  final int _userFillerLevel = 4;
  final int _userFillerExp = 1200;

  int get userInterviewLevel => _userInterviewLevel;
  int get userInterviewExp => _userInterviewExp;
  int get userPaceLevel => _userPaceLevel;
  int get userPaceExp => _userPaceExp;
  int get userFillerLevel => _userFillerLevel;
  int get userFillerExp => _userFillerExp;

  // --- FLOW METHODS ---

  void updateSubtitle(String text) {
    _interviewerSubtitle = text;
    notifyListeners();
  }

  void clearSubtitle() {
    _interviewerSubtitle = "";
    notifyListeners();
  }

  void calculateSessionExp() {
    // Simple calculation logic based on number of responses
    // In reality, this would be based on AI analysis scores
    int responseCount = _sessionResponses.length;
    if (responseCount == 0) responseCount = 1; // Minimum 1 for testing if empty
    
    _gainedInterviewExp = responseCount * 50 + 100; // Base 100 + 50 per response
    _gainedPaceExp = responseCount * 20 + 50;
    _gainedFillerExp = responseCount * 15 + 30;
    
    notifyListeners();
  }

  // --- PUSH TO TALK LOGIC ---

  void startUserSpeech() {
    if (_isSpeaking) return; // Cannot speak while AI is speaking
    
    // Calculate response latency (time since AI finished speaking)
    if (_aiFinishedSpeakingTime != null) {
      _currentResponseLatency = DateTime.now().difference(_aiFinishedSpeakingTime!);
    } else {
      _currentResponseLatency = Duration.zero;
    }
    
    _isMicMuted = false;
    notifyListeners();
    _startUserRecording();
  }

  void stopUserSpeech() {
    if (_isSpeaking) return;
    _isMicMuted = true;
    notifyListeners();
    _stopUserRecording();
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

  // --- RECORDING HELPERS ---

  Future<void> _startUserRecording() async {
    try {
      _recordingStartTime = DateTime.now();
      // Start recording to a unique temp file (handled by AudioController)
      await audioController.startRecording();
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  Future<void> _stopUserRecording() async {
    try {
      final path = await audioController.stopRecording();
      if (path != null) {
        final duration = _recordingStartTime != null 
            ? DateTime.now().difference(_recordingStartTime!) 
            : Duration.zero;
            
        final response = InterviewResponseModel(
          audioPath: path,
          duration: duration,
          responseTime: _currentResponseLatency,
        );
        
        _sessionResponses.add(response);
        debugPrint("Recorded response saved: $response");
      }
      _recordingStartTime = null;
      // Reset latency for subsequent chunks in the same turn (if any)
      // or keep it? Usually subsequent chunks are continuations, so latency is 0 or relative.
      // For now, we'll keep the initial latency for the first chunk, and maybe 0 for others?
      // But since PTT is "one hold", usually it's one chunk per response.
    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }

  /// Simulates the AI speaking a response with synchronized subtitles.
  /// This function takes the full response text and updates subtitles sequentially
  /// to mimic the flow of speech.
  Future<void> playAiResponse(String fullResponse) async {
    // Ensure any previous user recording is stopped and saved
    await _stopUserRecording();

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
      _isMicMuted = true; // Keep user muted until they press PTT
      _aiFinishedSpeakingTime = DateTime.now(); // Mark when AI finished
      notifyListeners();
      
      // Note: We do NOT automatically start recording here anymore.
      // User must press and hold to record.
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

  /// Merges all recorded session chunks into a single file using FFmpeg
  Future<void> _mergeAudioFiles() async {
    // FFmpeg merge disabled due to build issues.
    // The feedback page will handle sequential playback of chunks.
    debugPrint("Skipping FFmpeg merge. Using sequential playback.");
    return;
  }

  /// Finishes the interview, stops recording, merges audio, and moves to feedback
  Future<void> finishInterviewSession() async {
    _readyingTimer?.cancel();
    stopSpeaking();
    
    // Stop active recording
    await _stopUserRecording();
    
    if (_sessionResponses.isNotEmpty) {
      await _mergeAudioFiles();
    }
    
    calculateSessionExp();
    changeState(InterviewState.inFeedback);
  }

  /// Resets all gameplay state to default
  void resetGameplay() {
    _readyingTimer?.cancel();
    stopSpeaking();
    
    // Generate new session ID to reset UI states
    _gameplaySessionId = DateTime.now().toIso8601String();
    
    // Clear session data
    _sessionResponses.clear();
    _mergedAudioPath = null;
    _recordingStartTime = null;
    _aiFinishedSpeakingTime = null;

    _role = "";
    _scenario = "";
    _interviewerName = "";
    _readyingTimeRemaining = _maxReadyingTime;
    _isMicMuted = false;
    _interviewerSubtitle = "";
    notifyListeners();
  }
}
