// lib/views/widgets/BottomBar/gameplay_actions.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart';

/// A "dumb" widget that displays buttons for the gameplay phase.
/// All logic is handled by the PublicSpeakingController.
class GameplayActions extends StatelessWidget {
  const GameplayActions({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the controller to know which specific set of buttons to show
    return Consumer<PublicSpeakingController>(
      builder: (context, controller, child) {
        // Show a big Play button during the mic test
        if (controller.currentState == PublicSpeakingState.micTest) {
          return _micTestActions(context);
        }
        
        // Show restart/close buttons during readying and speaking
        return _speakingActions(context);
      },
    );
  }

  /// The big "Play" button shown on the Mic Test screen.
  Widget _micTestActions(BuildContext context) {
    return Center(
      child: IconButton.filled(
        onPressed: () {
          // Tell the controller to start the timed sequence
          context.read<PublicSpeakingController>().startGameplaySequence();
        },
        icon: const Icon(Icons.play_arrow),
        iconSize: 100,
        style: IconButton.styleFrom(
          backgroundColor: "23B5D3".toColor(),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// The buttons shown during the 'readying' and 'speaking' phases.
  Widget _speakingActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            // Tell the controller to restart the sequence
            context.read<PublicSpeakingController>().startGameplaySequence();
          },
          icon: const Icon(Icons.loop),
          iconSize: 50,
          style: IconButton.styleFrom(
            backgroundColor: "00A9A5".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
        IconButton.filled(
          onPressed: () {
            // Tell the controller to stop the sequence and go home
            context.read<PublicSpeakingController>().endGameplay();
          },
          icon: const Icon(Icons.close),
          iconSize: 100,
          style: IconButton.styleFrom(
            backgroundColor: "23B5D3".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
        // A placeholder to balance the layout, matching the size of the restart button.
        const SizedBox(width: 66), // Approx size of IconButton.filled with iconSize 50
      ],
    );
  }
}