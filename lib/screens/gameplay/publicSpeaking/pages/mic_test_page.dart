import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class MicTestPage extends StatelessWidget {
  const MicTestPage({super.key});

  String _audioStateText(AudioState audioState) {
    if (audioState == AudioState.recording) {
      return 'Recording';
    } else {
    return 'Start Speaking';
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();

    const double customAppBarHeight = 80.0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: IconButton.filled(
              onPressed: () {
                if (audioController.audioState == AudioState.recording) {
                  context.read<AudioController>().stopRecording();
                } else {
                  context.read<AudioController>().startRecording();
                }
              },
              icon: const Icon(Icons.mic),
              iconSize: 150,
              style: IconButton.styleFrom(
                backgroundColor: "00A9A5".toColor(),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Text(
            _audioStateText(audioController.audioState),
            style: TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (audioController.audioState == AudioState.stopped || audioController.audioState == AudioState.playing)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Stop Playback Button
                ElevatedButton.icon(
                  onPressed: () {
                    if (audioController.audioState == AudioState.playing) {
                      context.read<AudioController>().stopPlayback();
                    } else {
                      context.read<AudioController>().playRecording();
                    }
                  },
                  icon: Icon(audioController.audioState == AudioState.playing ? Icons.stop_circle_outlined : Icons.play_arrow),
                  label: Text(audioController.audioState == AudioState.playing ? 'Stop' : 'Play Recording'),
                ),
                
                const SizedBox(width: 20),

                // Upload Button
                ElevatedButton.icon(
                  // Disable the upload button while playing audio to prevent issues
                  onPressed: audioController.audioState == AudioState.playing 
                             ? null 
                             : () => context.read<AudioController>().uploadAudio(),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload'),
                ),
              ],
            )
        ],
      ),
    );
  }
}
