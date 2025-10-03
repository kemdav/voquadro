import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

// 1. Changed from StatefulWidget to StatelessWidget
// This page no longer needs to manage any local state.
class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});

  // 2. REMOVED the entire State class and the GlobalKey.
  // final GlobalKey<State<GameplayActions>> _gameplayActionsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

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
          Container(
            width: 300,
            height: 150,
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
            child: const Center(
              child: Text(
                "DOES LBGT PEOPLE DESERVE RIGHTS?",
                style: TextStyle(fontSize: 24, color: Colors.black),
                textAlign: TextAlign.center,
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