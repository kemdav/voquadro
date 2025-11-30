import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class UnderConstructionPage extends StatelessWidget {
  const UnderConstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = "2C2C3E".toColor();

    // CHANGED: Removed Scaffold and AppBar.
    // This allows the parent (PublicSpeakingHub) to show its own bars.
    return Container(
      color: backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Added padding so content isn't hidden behind the top bar
            const SizedBox(height: 60),

            Image.asset(
              'assets/images/dolph_hardhat.png',
              width: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Column(
                  children: [
                    Icon(Icons.warning, color: Colors.amber, size: 50),
                    Text(
                      "Image not found:\nassets/images/dolph_hardhat.png",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "UNDER CONSTRUCTION",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Dolph is working hard on this feature!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 179), // 0.7 * 255 ≈ 179
              ),
            ),
            // Added padding for bottom bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
