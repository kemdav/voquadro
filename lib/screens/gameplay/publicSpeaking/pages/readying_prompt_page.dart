import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class ReadyingPromptPage extends StatelessWidget {
  const ReadyingPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PublicSpeakingController>();
    final currentQuestion = controller.currentQuestion;

    // Get time data
    final int timeLeft = controller.readyingTimeRemaining;
    final int totalTime = controller.maxReadyingDuration;

    // Calculate progress (1.0 -> 0.0)
    final double progress = totalTime == 0 ? 0 : timeLeft / totalTime;

    if (controller.currentState != PublicSpeakingState.readying) {
      return const SizedBox();
    }

    // Primary color for this screen
    final Color primaryPurple = VoquadroColors.primaryPurple;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. STATE INDICATOR (Spinner or Countdown)
            if (currentQuestion == null)
              // AI is generating...
              const SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(strokeWidth: 8),
              )
            else
              // Question is ready, show Countdown
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: primaryPurple,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '$timeLeft',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // 2. STATE LABEL
            Text(
              currentQuestion == null ? 'GENERATING TOPIC...' : 'GET READY!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // 3. THE PROMPT CARD
            if (currentQuestion != null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Your Topic",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade300,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQuestion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Optional: Skip button if they are ready early
                    TextButton(
                      onPressed: () {
                        context.read<PublicSpeakingController>().skipReadying();
                      },
                      child: Text(
                        "I'm Ready Now",
                        style: TextStyle(color: primaryPurple),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
