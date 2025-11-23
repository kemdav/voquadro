import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/widgets/AppBar/home_app_bar.dart';

var logger = Logger();

class MainHubActions extends StatelessWidget {
  const MainHubActions({super.key});

  @override
  Widget build(BuildContext context) {
    // Map the original two-FAB + icon behaviors into HomeNavigationBar callbacks.
    return HomeNavigationBar(
      // Start Speaking (center FAB) -> start mic test (original big FAB)
      onStartSpeaking: () {
        logger.d('Start Speaking (center) pressed');
        context.read<PublicSpeakingController>().startMicTest();
      },

      // Left-most icon (house) - currently no-op (you can change to navigate home)
      onHousePressed: () {
        logger.d('House icon pressed (no-op)');
      },

      // FAQ icon - reserved (no-op)
      onFaqPressed: () {},

      // Adventure icon (right-side first) -> show status (was analytics icon)
      onAdventurePressed: () {},

      // Notebook icon -> open user journey (was the book icon)
      onNotebookPressed: () {},

      // Options icon -> switch mode (mapped from the secondary FAB "Switch Mode")
      onOptionsPressed: () {},
    );
  }
}
