import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_selection_page.dart';
import 'package:voquadro/views/pages/home/main_page.dart';
import 'package:voquadro/views/pages/home/select_mode_page.dart';
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Feed back page'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MainPage();
                    },
                  ),
                );
              },
              child: Text('Go Back to Main'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SelectModePage();
                    },
                  ),
                );
              },
              child: Text('Select Mode'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PublicSpeakingSelectionPage();
                    },
                  ),
                );
              },
              child: Text('Again'),
            ),
          ],
        ),
      ),
    );
  }
}