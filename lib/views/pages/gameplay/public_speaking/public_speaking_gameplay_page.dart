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
            Container(
              color: Colors.amberAccent,
              width: 300,
              height: 100,
              child: Center(child: Text('Prompt')),
            ),
            Image.asset('assets/images/tempCharacter.png'),
            Container(
              color: Colors.amberAccent,
              width: 200,
              height: 50,
              child: Center(child: Text('Timer')),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: IconButton(
                    onPressed: () {
                      // Temporary Route to Feedback Page

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return FeedbackPage();
                      },));
                    },
                    icon: Icon(Icons.mic),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
