import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart';

var logger = Logger();

class StartSpeakingActions extends StatelessWidget {
  const StartSpeakingActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start Speaking button
        SizedBox(
          height: 70,
          width: 250,
          child: FloatingActionButton(
            heroTag: 'start_speaking_fab',
            shape: const StadiumBorder(),
            onPressed: () {
              logger.d('Start Speaking button pressed!');
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
        const SizedBox(width: 15),
        // Mode Switcher button (circular) - NOT wrapped in SizedBox
        FloatingActionButton(
          heroTag: 'mode_switcher_fab',
          shape: const CircleBorder(),
          onPressed: () {
            logger.d('Mode switcher button pressed!');
            // No functionality for now
          },
          backgroundColor: "00A9A5".toColor(),
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
