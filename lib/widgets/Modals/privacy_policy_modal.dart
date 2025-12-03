import 'package:flutter/material.dart';

class PrivacyPolicyModal extends StatelessWidget {
  const PrivacyPolicyModal({super.key});

  static const String _privacyContent = '''
Source(s):

Dude trust me
''';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Privacy Policy",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const SingleChildScrollView(child: Text(_privacyContent)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
