import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:voquadro/src/ai-integration/assemblyai_service.dart';

var logger = Logger();

// An enum to represent the different states of our recorder
enum AudioState { uninitialized, recording, stopped, playing }

class AudioController with ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  AudioState _audioState = AudioState.uninitialized;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _audioPath;

  AudioState get audioState => _audioState;
  String? get audioPath => _audioPath;

  StreamSubscription? _amplitudeSubscription;
  double _currentAmplitude = 0.0;
  bool _hasReachedGoodVolume = false;

  double get currentAmplitude => _currentAmplitude; // Value from 0.0 to 1.0
  bool get hasReachedGoodVolume => _hasReachedGoodVolume;

  /// Starts a live stream to monitor microphone input level.
  Future<void> startAmplitudeStream() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission not granted');
    }

    // Reset state for a new test
    _hasReachedGoodVolume = false;
    _currentAmplitude = 0.0;
    notifyListeners();

    final stream = await _audioRecorder.startStream(
      const RecordConfig(encoder: AudioEncoder.pcm16bits),
    );

    _amplitudeSubscription = stream.listen((data) {
      // This is the core logic to calculate volume from raw audio data
      _calculateAmplitude(data);
    });
  }

  /// Stops the amplitude stream.
  Future<void> stopAmplitudeStream() async {
    await _amplitudeSubscription?.cancel();
    _currentAmplitude = 0.0;

    // Check if the recorder is still active before stopping
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }

    notifyListeners();
  }

  /// Calculates a normalized amplitude (0.0 - 1.0) from raw PCM data.
  void _calculateAmplitude(Uint8List audioData) {
    // The raw data is a series of 16-bit signed integers (PCM16)
    int maxAmplitude = 0;

    // Create a view into the byte buffer to read 16-bit integers
    var buffer = audioData.buffer.asByteData();

    // Iterate through the buffer, reading two bytes at a time
    for (var i = 0; i < audioData.lengthInBytes; i += 2) {
      // Read a 16-bit signed integer (little-endian is standard for PCM)
      var sample = buffer.getInt16(i, Endian.little);
      var absSample = sample.abs();

      if (absSample > maxAmplitude) {
        maxAmplitude = absSample;
      }
    }

    // Normalize the amplitude to a value between 0.0 and 1.0
    // The max value for a 16-bit signed integer is 32767
    _currentAmplitude = maxAmplitude / 32767.0;

    // Check if the volume is in the "Good" range (e.g., 20% to 80%) [It could be adjusted on what volume would be suitable for the transcript]
    if (!_hasReachedGoodVolume &&
        _currentAmplitude > 0.2 &&
        _currentAmplitude < 0.8) {
      _hasReachedGoodVolume = true;
    }

    notifyListeners(); // Notify the UI to update the volume meter
  }

  /// Starts the audio recording process.
  Future<void> startRecording() async {
    // 1. Check for microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission not granted');
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
      throw Exception('No audio file to upload.');
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

  /// Transcribe the last recorded audio file using AssemblyAI.
  ///
  /// Returns the transcription text on success.
  /// Throws an exception on error or if no audio is available.
  Future<String> transcribeWithAssemblyAI({String? apiKey}) async {
    if (_audioPath == null || !File(_audioPath!).existsSync()) {
      throw Exception('No audio file available to transcribe.');
    }
    // Delegate to the shared AssemblyAIService for upload + transcription
    return AssemblyAIService.instance.transcribeFile(
      _audioPath!,
      apiKey: apiKey,
    );
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
      logger.d('Playing Audio: $_audioPath');
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
