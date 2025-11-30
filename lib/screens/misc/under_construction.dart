import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class UnderConstructionPage extends StatelessWidget {
  const UnderConstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = "2C2C3E".toColor();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The Dolphin Hard Hat Image
            Image.asset(
              'assets/images/dolph_hardhat.png',
              width: 250, // Adjusted size for visibility
              fit: BoxFit.contain,
              // Add error builder just in case the file isn't moved yet
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
            // The Text
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
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
