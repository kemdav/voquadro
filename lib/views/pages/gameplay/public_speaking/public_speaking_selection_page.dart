import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_gameplay_page.dart';
class PublicSpeakingSelectionPage extends StatelessWidget {
  const PublicSpeakingSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Public Speaking'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PublicSpeakingGameplayPage();
                    },
                  ),
                );
              },
              child: Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}