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
            // Mic Push-to-Talk Button
            GestureDetector(
              onTapDown: (_) => controller.startUserSpeech(),
              onTapUp: (_) => controller.stopUserSpeech(),
              onTapCancel: () => controller.stopUserSpeech(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: controller.isMicMuted ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  controller.isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 32,
                ),
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
