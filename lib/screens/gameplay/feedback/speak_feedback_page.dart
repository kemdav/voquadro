import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

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
          'Rating: 69',
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
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
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
