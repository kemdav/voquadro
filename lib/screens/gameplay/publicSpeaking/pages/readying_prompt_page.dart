import 'package:flutter/material.dart';

class ReadyingPromptPage extends StatelessWidget {
  const ReadyingPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(), // A spinner is a good visual for a "readying" state.
          SizedBox(height: 20),
          Text(
            'READYING!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}