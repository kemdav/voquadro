import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AssemblyAIService {
  final http.Client _client;

  // Use this factory to create test instances with a mock client.
  factory AssemblyAIService([http.Client? client]) =>
      AssemblyAIService._internal(client);
  AssemblyAIService._internal([http.Client? client])
    : _client = client ?? http.Client();

  // Singleton default instance for runtime usage
  static final AssemblyAIService instance = AssemblyAIService._internal();

  /// Transcribe a file at [filePath]. Reads bytes and delegates to [transcribeBytes].
  Future<String> transcribeFile(String filePath, {String? apiKey}) async {
    final data = await File(filePath).readAsBytes();
    return transcribeBytes(Uint8List.fromList(data), apiKey: apiKey);
  }

  /// Transcribe raw audio bytes using AssemblyAI.
  Future<String> transcribeBytes(Uint8List bytes, {String? apiKey}) async {
    final String key = apiKey ?? dotenv.env['ASSEMBLYAI_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception(
        'AssemblyAI API key not provided. Set ASSEMBLYAI_API_KEY in .env.local or pass apiKey.',
      );
    }

    final uploadUrl = await _uploadBytesToAssemblyAI(bytes, key);
    final transcriptId = await _createTranscriptJob(uploadUrl, key);
    final transcriptText = await _pollTranscriptStatus(transcriptId, key);
    return transcriptText;
  }

  Future<String> _uploadBytesToAssemblyAI(
    Uint8List bytes,
    String apiKey,
  ) async {
    final uri = Uri.parse('https://api.assemblyai.com/v2/upload');

    final resp = await _client
        .post(
          uri,
          headers: {'authorization': apiKey, 'transfer-encoding': 'chunked'},
          body: bytes,
        )
        .timeout(const Duration(minutes: 2));

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['upload_url'] as String;
    } else {
      throw Exception(
        'Failed to upload file to AssemblyAI: ${resp.statusCode} ${resp.body}',
      );
    }
  }

  Future<String> _createTranscriptJob(String audioUrl, String apiKey) async {
    final uri = Uri.parse('https://api.assemblyai.com/v2/transcript');
    final resp = await _client
        .post(
          uri,
          headers: {
            'authorization': apiKey,
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'audio_url': audioUrl,
            // Include disfluencies so fillers like "uhm", "mhm", "huh" are kept in the transcript
            'disfluencies': true,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['id'] as String;
    } else {
      throw Exception(
        'Failed to create transcript job: ${resp.statusCode} ${resp.body}',
      );
    }
  }

  Future<String> _pollTranscriptStatus(
    String transcriptId,
    String apiKey, {
    Duration pollInterval = const Duration(seconds: 3),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final uri = Uri.parse(
      'https://api.assemblyai.com/v2/transcript/$transcriptId',
    );
    final stopwatch = Stopwatch()..start();

    while (true) {
      if (stopwatch.elapsed > timeout) {
        throw Exception(
          'Transcription timed out after ${timeout.inMinutes} minutes',
        );
      }

      final resp = await _client
          .get(uri, headers: {'authorization': apiKey})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        throw Exception(
          'Failed to poll transcript status: ${resp.statusCode} ${resp.body}',
        );
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'error';

      if (status == 'completed') {
        return (data['text'] as String?) ?? '';
      } else if (status == 'error') {
        throw Exception(
          'Transcription failed: ${data['error'] ?? 'unknown error'}',
        );
      }

      await Future.delayed(pollInterval);
    }
  }
}
