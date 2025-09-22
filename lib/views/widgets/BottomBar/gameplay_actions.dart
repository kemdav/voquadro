import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/data/voquadro_controller.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/views/pages/gameplay/feedback/feedback_page.dart';

var logger = Logger();

class GameplayActions extends StatefulWidget {
  const GameplayActions({super.key});

  @override
  State<GameplayActions> createState() => _GameplayActionsState();
}

class _GameplayActionsState extends State<GameplayActions> {
  final voquadroController = VoquadroController.instance;
  Timer? _startDelayTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    logger.d('--- GameplayActions INIT --- Instance HashCode: $hashCode');
    voquadroController.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _startDelayTimer?.cancel();
    _navigationTimer?.cancel();
    logger.d('--- GameplayActions DISPOSE --- Instance HashCode: $hashCode');
    voquadroController.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    logger.d('State changed to: ${voquadroController.voquadroState}');
    if (voquadroController.voquadroState == VoquadroState.idle) {
      logger.d('Cancelling sequence because state changed to idle.');
      _cancelGameplaySequence();
    }
    setState(() {});
  }

  void _startGameplaySequence() {
    _cancelGameplaySequence();

    logger.d('Start Button Pressed!');
    voquadroController.changeVoquadroState(VoquadroState.ready);

    logger.d('Scheduling speech start delay...');
    _startDelayTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      logger.d('Going to speaking state');
      voquadroController.changeVoquadroState(VoquadroState.speaking);

      logger.d('Scheduling navigation to feedback page...');
      _navigationTimer = Timer(const Duration(seconds: 10), () {
        logger.d('Checking if mounted...');
        if (!mounted) return;
        logger.d('Mounted!');
        _navigateToFeedbackPage();
      });
    });
  }

  void _cancelGameplaySequence() {
    if (_startDelayTimer?.isActive ?? false) {
      logger.d('Start delay timer cancelled!');
      _startDelayTimer?.cancel();
    }
    if (_navigationTimer?.isActive ?? false) {
      logger.d('Navigation timer cancelled!');
      _navigationTimer?.cancel();
    }
  }

  void _navigateToFeedbackPage() {
    logger.d('Going to feedback page');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FeedbackPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (voquadroController.voquadroState) {
      case VoquadroState.idle:
        return defaultActions();
      case VoquadroState.ready:
      case VoquadroState.speaking:
        return speakingActions();
      default:
        return const Text('Invalid State');
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
            _startGameplaySequence();
          },
          icon: const Icon(Icons.loop),
          iconSize: 50,
          style: IconButton.styleFrom(
            backgroundColor: "00A9A5".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
        IconButton.filled(
          onPressed: _startGameplaySequence,
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
            _startGameplaySequence();
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
            _cancelGameplaySequence();
            voquadroController.changeVoquadroState(VoquadroState.idle);
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
