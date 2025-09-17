import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_gameplay_page.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  State<ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  String? difficultyMenuItem = 'd1';
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              value: difficultyMenuItem,
              items: [
                DropdownMenuItem(value: 'd1', child: Text('Easy')),
                DropdownMenuItem(value: 'd2', child: Text('Medium')),
                DropdownMenuItem(value: 'd3', child: Text('Hard')),
              ],
              onChanged: (String? value) {
                setState(() {
                    difficultyMenuItem = value;
                  });
              },
            ),
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
        ),);
  }
}