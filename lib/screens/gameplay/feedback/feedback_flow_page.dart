import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Widget/feedback_continue_button_widget.dart';
import 'package:voquadro/widgets/Widget/feedback_progress_widget.dart';
import 'package:voquadro/screens/gameplay/feedback/progression_page.dart';
import 'package:voquadro/screens/gameplay/feedback/stat_feedback_page.dart';
import 'package:voquadro/screens/gameplay/feedback/transcript_page.dart';
import 'package:voquadro/screens/gameplay/feedback/speak_feedback_page.dart';

class FeedbackFlowPage extends StatelessWidget {
  const FeedbackFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PublicSpeakingController>();
    final currentIndex = controller.currentFeedbackStep.index;

    final isPractice = controller.isPracticeMode;

    final Color primaryPurple = "49416D".toColor();
    final Color buttonPurple = "887CAF".toColor();
    final Color cardBackground = Colors.white;
    final Color activeIndicator = "44D6D2".toColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Expanded(
            // This IndexedStack switches between the different feedback cards
            child: IndexedStack(
              index: controller.currentFeedbackStep.index,
              children: <Widget>[
                // Pass colors and any other required data to your pages
                TranscriptPage(
                  cardBackground: cardBackground,
                  primaryPurple: primaryPurple,
                  isVisible: currentIndex == 0,
                ),
                SpeakFeedbackPage(
                  cardBackground: cardBackground,
                  primaryPurple: primaryPurple,
                  isVisible: currentIndex == 1,
                ),
                StatFeedbackPage(
                  cardBackground: cardBackground,
                  primaryPurple: primaryPurple,
                  isVisible: currentIndex == 2,
                ),
                ProgressionPage(isVisible: currentIndex == 3),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FeedbackContinueButton(buttonPurple: buttonPurple),

          // Only show the "blue bar indicators" if aint in practice mode.
          if (!isPractice) ...[
            const SizedBox(height: 20),
            FeedbackProgressWidget(activeColor: activeIndicator),
          ],
        ],
      ),
    );
  }
}
