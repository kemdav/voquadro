import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/src/hex_color.dart';

var logger = Logger();

class GameplayActions extends StatelessWidget {
  const GameplayActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            logger.d('Restart Button Pressed!');
          },
          icon: const Icon(Icons.loop),
          iconSize: 50,
          style: IconButton.styleFrom(
            backgroundColor: "00A9A5".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
        IconButton.filled(
          onPressed: () {
            logger.d('Start Button Pressed!');
          },
          icon: const Icon(Icons.play_arrow),
          iconSize: 100,
          style: IconButton.styleFrom(
            backgroundColor: "23B5D3".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
        IconButton.filled(
          onPressed: () {
            logger.d('Mic Button Pressed!');
          },
          icon: const Icon(Icons.mic),
          iconSize: 50,
          style: IconButton.styleFrom(
            backgroundColor: "00A9A5".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
