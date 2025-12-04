import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/services/sound_service.dart';

class FeedbackContinueButton extends StatelessWidget {
  const FeedbackContinueButton({super.key, required this.buttonPurple});

  final Color buttonPurple;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PublicSpeakingController>();
    final isReady = controller.isFeedbackGenerationComplete;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPurple,
        disabledBackgroundColor: buttonPurple.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: isReady
          ? () {
              context.read<SoundService>().playSfx(
                'assets/audio/button_click.mp3',
              );
              context.read<PublicSpeakingController>().goToNextFeedbackStep();
            }
          : null,
      child: isReady
          ? const Text(
              'Continue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          : const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
    );
  }
}
