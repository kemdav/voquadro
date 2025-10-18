import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class MicTestPage extends StatefulWidget {
  const MicTestPage({super.key});

  @override
  State<MicTestPage> createState() => _MicTestPageState();
}

class _MicTestPageState extends State<MicTestPage> {
  @override
  void initState() {
    super.initState();
    // Start the volume test as soon as the page is visible
    // Use addPostFrameCallback to ensure the context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioController>().startAmplitudeStream();
    });
  }

  @override
  void dispose() {
    context.read<AudioController>().stopAmplitudeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final publicSpeakingController = context.read<PublicSpeakingController>();

    String feedbackText;
    Color progressColor;

    if (audioController.currentAmplitude < 0.2) {
      feedbackText = 'A little louder...';
      progressColor = Colors.blue;
    } else if (audioController.currentAmplitude < 0.8) {
      feedbackText = 'Perfect!';
      progressColor = Colors.green;
    } else {
      feedbackText = 'A little quieter...';
      progressColor = Colors.red;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Let\'s test your mic',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            feedbackText,
            style: TextStyle(fontSize: 20, color: progressColor),
          ),
          const SizedBox(height: 30),

          // The visual volume meter
          SizedBox(
            width: 250,
            height: 40,
            child: LinearProgressIndicator(
              value: audioController.currentAmplitude,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          const SizedBox(height: 60),

          // The Continue button, enabled only after good volume is detected
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            // Use the property from the controller to enable/disable the button
            onPressed: audioController.hasReachedGoodVolume
                ? () async {
                    // When continue is pressed, stop the test and request a question
                    // from the AI service and start the actual game. This ensures
                    // the speaking page has a question to display instead of
                    // showing "Waiting for question...".
                    audioController.stopAmplitudeStream();
                    await publicSpeakingController
                        .generateRandomQuestionAndStart();
                  }
                : null, // null disables the button
            child: const Text('Continue', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
