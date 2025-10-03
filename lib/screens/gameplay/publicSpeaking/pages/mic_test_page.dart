import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class MicTestPage extends StatelessWidget {
  const MicTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: IconButton.filled(
              onPressed: () {
                logger.d('Mic Button Pressed!');
              },
              icon: const Icon(Icons.mic),
              iconSize: 150,
              style: IconButton.styleFrom(
                backgroundColor: "00A9A5".toColor(),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Text(
            'Start Speaking',
            style: TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
