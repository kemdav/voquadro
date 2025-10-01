import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/feedback_page.dart';
class PublicSpeakingGameplayPage extends StatelessWidget {
  const PublicSpeakingGameplayPage({super.key});

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
                      return FeedbackPage();
                    },
                  ),
                );
              },
              child: Text('Finished Speaking'),
            ),
          ],
        ),
      ),
    );
  }
}