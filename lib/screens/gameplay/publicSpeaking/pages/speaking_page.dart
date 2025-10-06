import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/hubs/controllers/public_speaking_controller.dart';

// 1. Changed from StatefulWidget to StatelessWidget
// This page no longer needs to manage any local state.
class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});

  // 2. REMOVED the entire State class and the GlobalKey.
  // final GlobalKey<State<GameplayActions>> _gameplayActionsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PublicSpeakingController>(context);
    final session = controller.currentSession;
    // This page doesn't need its own Scaffold because the PublicSpeakingHub provides it.
    // It is now just a content widget.
    return Center(
      child: Column(
        // Use MainAxisAlignment.spaceEvenly or similar to position items
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LinearProgressIndicator(
            value: 0.3,
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
          // Ensure your asset path is correct
          Image.asset('assets/images/tempCharacter.png'),
        ],
      ),
    );
  }
}
