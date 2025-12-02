import 'package:flutter/material.dart';

class TermsOfServiceModal extends StatelessWidget {
  const TermsOfServiceModal({super.key});

  static const String _tosContent = '''
Last Updated: November 2025

Welcome to Voquadro, an AI-powered public speaking coach designed to help users practice and improve their speaking skills through feedback and progression tracking.

1. Acceptance of Terms
By accessing or using Voquadro, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use the app.

2. Description of Service
Voquadro provides users with a platform to record speeches, receive AI-generated feedback, and track progress through skill-based levels. The app is intended for educational and self-improvement purposes only.

3. User Accounts
• You are responsible for maintaining the confidentiality of your login credentials.
• You agree to provide accurate information when registering and to keep it updated.
• You may share, sell, or transfer your account to others.

4. Acceptable Use
You agree not to:
• Upload or speak harmful, discriminatory, or illegal content.
• Attempt to interfere with the app's systems or other users.
• Use the app for commercial or unauthorized purposes.
Voquadro reserves the right to suspend accounts that violate these rules.

5. AI Feedback Disclaimer
Voquadro uses AI technology to generate speech feedback. While we strive for accuracy, AI feedback may not always be perfect or contextually correct. Use it as guidance, not as a substitute for professional coaching.

6. Data Usage
Voice recordings and transcripts are processed temporarily for analysis. All recordings are automatically deleted after processing, as stated in our Privacy Policy. We do not sell or share user data.

7. Limitation of Liability
Voquadro is provided "as is." We are not responsible for:
• everything.

8. Modifications to Service
We may update or change features from time to time. Users will be notified of significant changes through in-app announcements or updates.

9. Termination
We may suspend or terminate access if you violate these Terms. You may stop using the app anytime by deleting your account.

10. Contact
For questions, suggestions, or support ask Excel Joseph Duran.
The rest are still playing clash royale.
''';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Terms of Service",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const SingleChildScrollView(child: Text(_tosContent)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
