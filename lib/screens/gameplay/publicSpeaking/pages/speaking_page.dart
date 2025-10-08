import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/hubs/controllers/public_speaking_controller.dart';

class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});


  @override
  Widget build(BuildContext context) {
     final controller = context.watch<PublicSpeakingController>();
     final session = controller.currentSession;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LinearProgressIndicator(
            value: 1.0 - controller.speakingProgress,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            color: "6CCC51".toColor(),
          ),

          // Only rebuilds when
          SizedBox(
            width: 300,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    session?.generatedQuestion ??
                        controller.currentQuestion ??
                        "Waiting for question...",
                    style: const TextStyle(fontSize: 24, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Image.asset('assets/images/tempCharacter.png'),
        ],
      ),
    );
  }
}
