import 'package:flutter/material.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class InterviewLoadingPage extends StatelessWidget {
  const InterviewLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: VoquadroColors.primaryPurple,
            ),
            const SizedBox(height: 24),
            Text(
              "Setting up the interview room...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VoquadroColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Reviewing your profile...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
