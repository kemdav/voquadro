// lib/views/widgets/BottomBar/gameplay_actions.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart';

class GameplayActions extends StatelessWidget {
  const GameplayActions({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryPurple = "49416D".toColor();
    final accentCyan = "23B5D3".toColor();

    return Consumer<PublicSpeakingController>(
      builder: (context, controller, child) {
        
        // Use AnimatedSwitcher for smooth transitions between buttons
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: _buildActionForState(context, controller, primaryPurple, accentCyan),
        );
      },
    );
  }

  Widget _buildActionForState(
      BuildContext context, 
      PublicSpeakingController controller,
      Color primaryColor,
      Color accentColor
  ) {
    switch (controller.currentState) {
      
      // --- STATE: MIC TEST ---
      case PublicSpeakingState.micTest:
        // NOTE: Since your MicTestPage now auto-navigates, you might not need a button here.
        // But if you want a manual override, here it is:
        return SizedBox.shrink(); // Hiding it because MicTestPage handles logic now.
        // Or uncomment below to keep a manual button:
        /*
        return FloatingActionButton.large(
          key: const ValueKey('micTestBtn'),
          onPressed: () => controller.generateRandomQuestionAndStart(),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.mic, size: 40),
        );
        */

      // --- STATE: READYING (Countdown) ---
      case PublicSpeakingState.readying:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel Button (Small)
            _buildCircleButton(
              icon: Icons.close,
              color: Colors.redAccent,
              onPressed: () => controller.endGameplay(),
              tooltip: "Quit",
            ),
            const SizedBox(width: 20),
            // "I'm Ready" Button (Large)
            _buildPillButton(
              label: "I'm Ready Now",
              icon: Icons.play_arrow_rounded,
              color: accentColor,
              onPressed: () => controller.skipReadying(),
            ),
          ],
        );

      // --- STATE: SPEAKING (Recording) ---
      case PublicSpeakingState.speaking:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel Button (Small)
            _buildCircleButton(
              icon: Icons.close,
              color: Colors.redAccent,
              onPressed: () => controller.endGameplay(), // Go back home
              tooltip: "Quit",
            ),
            const SizedBox(width: 20),
            // "Done" Button (Large)
            _buildPillButton(
              label: "Done Speaking",
              icon: Icons.check_circle_outline,
              color: const Color(0xFF6CCC51), // Green
              onPressed: () => controller.finishSpeechEarly(), // Go to feedback
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // --- HELPER: Large Text Button (The "Good" Action) ---
  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 55, // Nice and tall for easy tapping
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 26),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // --- HELPER: Small Circle Button (The "Cancel" Action) ---
  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: color, size: 28),
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}