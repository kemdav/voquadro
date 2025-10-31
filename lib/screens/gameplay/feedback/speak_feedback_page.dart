import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:provider/provider.dart';

class SpeakFeedbackPage extends StatelessWidget {
  const SpeakFeedbackPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
  });

  final Color cardBackground;
  final Color primaryPurple;

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicSpeakingController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            IconButton.filled(
              onPressed: () {},
              icon: const Icon(Icons.close),
              iconSize: 70,
              style: IconButton.styleFrom(
                backgroundColor: "23B5D3".toColor(),
                foregroundColor: Colors.white,
              ),
            ),
            Text(
              'Rating: ${controller.overallScore ?? 'Calculating...'}',
              style: TextStyle(
                color: primaryPurple,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Container(
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
                          'Feedback speak page.',
                          style: TextStyle(
                            color: primaryPurple,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeedbackContent(controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackContent(PublicSpeakingController controller) {
    final feedback = controller.formattedFeedback;

    if (feedback.contains("Generating feedback")) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Generating feedback...',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      );
    }

    if (feedback.contains("Error") || feedback.contains("No feedback")) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            feedback,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.generateAIFeedback();
            },
            child: const Text('Retry Feedback Generation'),
          ),
        ],
      );
    }

    //Display the feedback
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Display the question answered
        if (controller.currentQuestion != null) ...[
          Text(
            'Question: ${controller.currentQuestion}',
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

        // If parsed feedback is available, render it as widgets for better UX
        if (controller.aiParsedFeedback != null &&
            controller.aiParsedFeedback!.isNotEmpty) ...[
          ...controller.buildParsedFeedbackWidgets(controller.aiParsedFeedback),
        ] else ...[
          // Fallback to the plain formatted string
          Text(
            feedback,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
