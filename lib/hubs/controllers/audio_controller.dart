import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

var logger = Logger();

// An enum to represent the different states of our recorder
enum AudioState {
  uninitialized,
  recording,
  stopped,
  playing
}

class AudioController with ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  AudioState _audioState = AudioState.uninitialized;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _audioPath;

  AudioState get audioState => _audioState;
  String? get audioPath => _audioPath;

  /// Starts the audio recording process.
  Future<void> startRecording() async {
    // 1. Check for microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw 'Microphone permission not granted';
    }

    // 2. Find a temporary directory to save the file
    final Directory tempDir = await getTemporaryDirectory();
    _audioPath = '${tempDir.path}/myaudio.m4a'; 

    // 3. Start recording
    const config = RecordConfig(encoder: AudioEncoder.aacLc); 
    await _audioRecorder.start(config, path: _audioPath!);
    
    _audioState = AudioState.recording;
    logger.d('Saving audio to: $_audioPath');
    notifyListeners();
  }

  /// Stops the audio recording process.
  Future<void> stopRecording() async {
    await _audioRecorder.stop();
    _audioState = AudioState.stopped;
    notifyListeners();
  }

  /// Uploads the recorded audio file to a server.
  Future<void> uploadAudio() async {
    if (_audioPath == null) {
      throw 'No audio file to upload.';
    }

    // Replace with your actual API endpoint
    final uri = Uri.parse('https://yourapi.com/transcript');
    final request = http.MultipartRequest('POST', uri);

    // Attach the file to the request
    final file = await http.MultipartFile.fromPath(
      'audio', // The field name your API expects for the file
      _audioPath!,
    );
    request.files.add(file);

    // Optional: Add other fields if your API needs them
    // request.fields['userId'] = '12345';

    logger.d('Uploading audio...');
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        logger.d('Upload successful! Response: $responseBody');
        // Here you would parse the transcription and then send it to your rating AI
      } else {
        logger.d('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      logger.d('An error occurred during upload: $e');
    }
  }

    /// Plays the last recorded audio file.
  Future<void> playRecording() async {
    if (_audioPath == null || !File(_audioPath!).existsSync()) {
      logger.d('Error: Audio file not found at $_audioPath');
      return;
    }

    try {
      // Set the audio source from the file path
      await _audioPlayer.setFilePath(_audioPath!);
      _audioState = AudioState.playing;
      notifyListeners();

      // Start playback
      await _audioPlayer.play();

      // When playback is complete, automatically stop
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          stopPlayback();
        }
      });
    } catch (e) {
      logger.d("Error playing audio: $e");
    }
  }
  
  /// Stops the audio playback.
  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _audioState = AudioState.stopped; // Go back to the 'stopped' state
    notifyListeners();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}