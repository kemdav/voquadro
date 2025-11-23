import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart';

class StatFeedbackPage extends StatelessWidget {
  const StatFeedbackPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
  });

  final Color cardBackground;
  final Color primaryPurple;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PublicSpeakingController>();
    final result = controller.sessionResult;
    final radarScores = controller.radarChartScores;

    if (result == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Text(
          'Adolph Thought',
          style: TextStyle(
            color: primaryPurple,
            fontSize: 35,
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
                    if (radarScores != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Message Depth',
                        style: TextStyle(
                          color: primaryPurple,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircularStatWidget(
                        lowerText: 'Score',
                        upperText: radarScores['message_depth'].toString(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Vocal Delivery',
                        style: TextStyle(
                          color: primaryPurple,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircularStatWidget(
                        lowerText: 'Score',
                        upperText: radarScores['vocal_delivery'].toString(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Clarity & Flow',
                        style: TextStyle(
                          color: primaryPurple,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircularStatWidget(
                        lowerText: 'Score',
                        upperText: radarScores['clarity_flow'].toString(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pace Score',
                        style: TextStyle(
                          color: primaryPurple,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircularStatWidget(
                        lowerText: 'Score',
                        upperText: radarScores['pace_control'].toString(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Filler Score',
                        style: TextStyle(
                          color: primaryPurple,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircularStatWidget(
                        lowerText: 'Score',
                        upperText: radarScores['filler_control'].toString(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularStatWidget extends StatelessWidget {
  const CircularStatWidget({
    super.key,
    required this.upperText,
    required this.lowerText,
  });

  final String upperText;
  final String lowerText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: '49416D'.toColor(),
          shape: BoxShape.circle,
          border: Border.all(color: '7962A5'.toColor(), width: 8.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                upperText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                lowerText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
