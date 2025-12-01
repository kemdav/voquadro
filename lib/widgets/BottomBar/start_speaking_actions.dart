import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/services/sound_service.dart';
import 'package:voquadro/src/hex_color.dart';

class StartSpeakingActions extends StatelessWidget {
  const StartSpeakingActions({super.key});

  static final Logger _logger = Logger();

  static const double _mainButtonHeight = 70.0;
  static const double _mainButtonWidth = 250.0;
  static const double _spacing = 15.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: _mainButtonHeight,
          width: _mainButtonWidth,
          child: FloatingActionButton(
            heroTag: 'start_speaking_fab',
            shape: const StadiumBorder(),
            onPressed: () {
              _logger.d('Start Speaking button pressed!');
              context.read<SoundService>().playSfx(
                'assets/audio/button_click.mp3',
              );
              context.read<PublicSpeakingController>().startMicTest();
            },
            backgroundColor: "00A9A5".toColor(),
            elevation: 3.0,
            child: const Text(
              'Start Speaking!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),

        const SizedBox(width: _spacing),

        FloatingActionButton(
          heroTag: 'mode_switcher_fab',
          shape: const CircleBorder(),
          onPressed: () {
            _logger.d('Mode switcher button pressed!');
            context.read<SoundService>().playSfx(
              'assets/audio/button_click.mp3',
            );
          },
          backgroundColor: "50D8D6".toColor(),
          elevation: 3.0,
          child: SvgPicture.asset(
            'assets/homepage_assets/mode_switcher.svg',
            width: 25,
            height: 25,
          ),
        ),
      ],
    );
  }
}
