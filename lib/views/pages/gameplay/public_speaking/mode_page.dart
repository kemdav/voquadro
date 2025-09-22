import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_gameplay_page.dart';

class PublicSpeakingModePage extends StatefulWidget {
  const PublicSpeakingModePage({super.key});

  @override
  State<PublicSpeakingModePage> createState() => _ModePageState();
}

class _ModePageState extends State<PublicSpeakingModePage> {
  String? difficultyMenuItem = 'd1';
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              child: Image.asset('assets/images/tempCharacter.png'),
            ),
          ],
        ),);
  }
}