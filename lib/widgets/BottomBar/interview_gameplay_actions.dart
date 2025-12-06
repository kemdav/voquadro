import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/interview-controller/interview_controller.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class InterviewGameplayActions extends StatelessWidget {
  const InterviewGameplayActions({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryPurple = VoquadroColors.primaryPurple;

    return Consumer<InterviewController>(
      builder: (context, controller, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _buildActionForState(
            context,
            controller,
            primaryPurple,
          ),
        );
      },
    );
  }

  Widget _buildActionForState(
    BuildContext context,
    InterviewController controller,
    Color primaryColor,
  ) {
    switch (controller.currentState) {
      case InterviewState.interviewing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mic Toggle Button
            FloatingActionButton(
              key: const ValueKey('micToggleBtn'),
              heroTag: 'micToggleBtn',
              onPressed: () => controller.toggleMic(),
              backgroundColor: controller.isMicMuted ? Colors.red : Colors.white,
              elevation: 4,
              child: Icon(
                controller.isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: controller.isMicMuted ? Colors.white : Colors.black87,
                size: 28,
              ),
            ),
            const SizedBox(width: 24),
            // End Call Button
            FloatingActionButton(
              key: const ValueKey('endInterviewBtn'),
              heroTag: 'endInterviewBtn',
              onPressed: () => controller.endInterview(),
              backgroundColor: Colors.red,
              elevation: 4,
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        );
        
      case InterviewState.inFeedback:
        return FloatingActionButton.extended(
          key: const ValueKey('exitBtn'),
          onPressed: () => controller.exitGameplay(),
          backgroundColor: primaryColor,
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          label: const Text(
            "Back to Home",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
