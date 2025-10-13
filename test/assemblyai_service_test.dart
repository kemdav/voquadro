import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:voquadro/src/ai-integration/assemblyai_service.dart';

void main() {
  test('AssemblyAIService transcribeBytes happy path', () async {
    // Mock sequence: upload -> transcript creation -> polling

    final mock = MockClient((request) async {
      final url = request.url.toString();
      if (url.endsWith('/upload')) {
        return http.Response(
          jsonEncode({'upload_url': 'https://cdn.assemblyai/upload123'}),
          200,
        );
      }

      if (url.endsWith('/transcript')) {
        return http.Response(jsonEncode({'id': 'transcript-123'}), 200);
      }

      if (url.contains('/transcript/transcript-123')) {
        // First poll: processing
        return http.Response(
          jsonEncode({'status': 'completed', 'text': 'Hello world'}),
          200,
        );
      }

      return http.Response('not found', 404);
    });

    final service = AssemblyAIService(mock);

    final text = await service.transcribeBytes(
      Uint8List.fromList([1, 2, 3, 4]),
      apiKey: 'fake',
    );
    expect(text, 'Hello world');
  });
}
