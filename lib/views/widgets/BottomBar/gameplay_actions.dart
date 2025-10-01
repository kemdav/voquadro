import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/data/voquadro_controller.dart';
import 'package:voquadro/src/hex_color.dart';

var logger = Logger();

class GameplayActions extends StatefulWidget {
  const GameplayActions({super.key});

  @override
  State<GameplayActions> createState() => _GameplayActionsState();
}

class _GameplayActionsState extends State<GameplayActions> {
  final voquadroController = VoquadroController.instance;
  @override
  void initState() {
    super.initState();
    voquadroController.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    voquadroController.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (voquadroController.voquadroState) {
      case VoquadroState.idle:
        return defaultActions();
      case VoquadroState.ready:
        return speakingActions();
      case VoquadroState.speaking:
        return Text('Temp');
    }
  }

  Row defaultActions() {
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
            voquadroController.changeVoquadroState(VoquadroState.ready);

            // Switch to the Speaking Page after a delay
            logger.d('Scheduling Speech Start Delay');
            const delay = Duration(seconds: 5);

            Future.delayed(delay, () {
              logger.d('Going to speaking page');

              voquadroController.changeVoquadroState(VoquadroState.speaking);

              // !Start Gameplay Insert Here
            });
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

  Row speakingActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            logger.d('Close Button Pressed!');
          },
          icon: const Icon(Icons.close),
          iconSize: 100,
          style: IconButton.styleFrom(
            backgroundColor: "23B5D3".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
