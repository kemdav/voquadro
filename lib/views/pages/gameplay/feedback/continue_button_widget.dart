import 'package:flutter/material.dart';
import 'package:voquadro/data/voquadro_controller.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_selection_page.dart';

var logger = Logger();

class FeedbackContinueButton extends StatefulWidget {
  const FeedbackContinueButton({super.key, required this.buttonPurple});

  final Color buttonPurple;

  @override
  State<FeedbackContinueButton> createState() => _FeedbackContinueButtonState();
}

class _FeedbackContinueButtonState extends State<FeedbackContinueButton> {
  final voquadroController = VoquadroController.instance;
  @override
  void initState() {
    super.initState();
    voquadroController.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    voquadroController.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.buttonPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        if (voquadroController.feedbackState == FeedbackState.nextRankDisplay) {
          voquadroController.goToNextFeedbackState();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PublicSpeakingSelectionPage();
              },
            ),
          );
        } else {
          voquadroController.goToNextFeedbackState();
        }
        logger.d(
          'Continue Button Pressed going to ${voquadroController.feedbackState}',
        );
      },
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
