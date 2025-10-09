import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public_speaking_controller.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';

class TranscriptPage extends StatelessWidget {
  const TranscriptPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
  });

  final Color cardBackground;
  final Color primaryPurple;

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();

    return Consumer<PublicSpeakingController>(
      builder: (context, controller, child) {
        final transcript = controller.userTranscript;
        final question = controller.currentQuestion;

        return Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Response',
                    style: TextStyle(
                      color: primaryPurple,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display the question here
                  if (question != null) ...[
                    Text(
                      'Question: $question',
                      style: TextStyle(
                        color: primaryPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // Display transcription state / transcript / error
                  if (controller.isTranscribing) ...[
                    Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 12),
                    const Text('Transcribing your recording...'),
                  ] else if (controller.transcriptionError != null) ...[
                    Text(
                      'Transcription Error:',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.transcriptionError!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Retry transcription & feedback generation
                        context
                            .read<PublicSpeakingController>()
                            .onEnterFeedbackFlow();
                      },
                      child: const Text('Retry Transcription'),
                    ),
                  ] else if (transcript != null && transcript.isNotEmpty)
                    Text(
                      transcript,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    )
                  else
                    const Text(
                      'No transcript available. Your speech will appear here after recording.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Audio playback button from develop branch
                  ElevatedButton.icon(
                    onPressed: () {
                      // The button's action is now to play the recording
                      if (audioController.audioState == AudioState.playing) {
                        context.read<AudioController>().stopPlayback();
                      } else {
                        context.read<AudioController>().playRecording();
                      }
                    },
                    icon: Icon(
                      audioController.audioState == AudioState.playing
                          ? Icons.stop
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      audioController.audioState == AudioState.playing
                          ? 'Stop Playback'
                          : 'Listen to Recording',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
