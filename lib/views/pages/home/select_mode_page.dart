import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_selection_page.dart';
class SelectModePage extends StatelessWidget {
  const SelectModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PublicSpeakingSelectionPage();
                    },
                  ),
                );
              },
              child: Text('Public Speaking Mode'),
            ),
          ],
        ),
      ),
    );
  }
}