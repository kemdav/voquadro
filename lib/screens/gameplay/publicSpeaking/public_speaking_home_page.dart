import 'package:flutter/material.dart';

class PublicSpeakingHomePage extends StatefulWidget {
  const PublicSpeakingHomePage({super.key});

  @override
  State<PublicSpeakingHomePage> createState() => _ModePageState();
}

class _ModePageState extends State<PublicSpeakingHomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Image.asset('assets/images/dolph.png'),
          ),
        ],
      ),
    );
  }
}
