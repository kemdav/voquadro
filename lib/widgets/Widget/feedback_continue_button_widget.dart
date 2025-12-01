import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/services/sound_service.dart';

class FeedbackContinueButton extends StatelessWidget {
  const FeedbackContinueButton({super.key, required this.buttonPurple});

  final Color buttonPurple;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        context.read<SoundService>().playSfx('assets/audio/button_click.mp3');
        context.read<PublicSpeakingController>().goToNextFeedbackStep();
      },
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
