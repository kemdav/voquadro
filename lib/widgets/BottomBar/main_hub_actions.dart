import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/src/hex_color.dart';

var logger = Logger();

class MainHubActions extends StatelessWidget {
  const MainHubActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              height: 70,
              width: 250,
              child: FloatingActionButton(
                heroTag: 'start_speaking_fab',
                shape: const StadiumBorder(),
                onPressed: () {
                  logger.d('FAB 1 pressed!');

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
            const SizedBox(height: 25),
            SizedBox(
              height: 50,
              width: 200,
              child: FloatingActionButton(
                heroTag: 'secondary_action_fab',
                shape: const StadiumBorder(),
                onPressed: () {
                  logger.d('FAB 2 pressed!');
                  context.read<AppFlowController>().selectMode(
                    AppMode.modeSelection,
                  );
                },
                backgroundColor: "125B5A".toColor(),
                elevation: 3.0,
                child: const Text(
                  'Switch Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          //user journey (public speaing or daily chatting)
          children: [
            IconButton.filled(
              onPressed: () {
                logger.d('Book icon pressed!');

                final appFlow = context.read<AppFlowController>();

                // If the app is in public speaking mode, navigate to the journey section.
                if (appFlow.currentMode == AppMode.publicSpeaking) {
                  final user = appFlow.currentUser;

                  if (user != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PublicSpeakJourneySection(
                          //refer to user services lang para ani
                          username: user.username,
                          currentXP: 69,
                          maxXP: 200,
                          currentLevel: 'Level 69',
                          averageWPM: 0, // supply real metric when available
                          averageFillers:
                              0, // supply real metric when available
                          sessionFeedbacks:
                              const [], // replace with real feedbacks later
                          onBackPressed: () => Navigator.of(context).pop(),
                          onProfilePressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PublicSpeakingProfileStage(),
                              ),
                            );
                          },
                          onSettingsPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsStage(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                } else {
                  // Not in public speaking mode yet — no-op for now.
                }
              },
              icon: const Icon(Icons.book),
              iconSize: 50,
              style: IconButton.styleFrom(
                backgroundColor: "7962A5".toColor(),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            IconButton.filled(
              onPressed: () {
                logger.d('Analytics icon pressed!');
                context.read<PublicSpeakingController>().showStatus();
              },
              icon: const Icon(Icons.analytics),
              iconSize: 50,
              style: IconButton.styleFrom(
                backgroundColor: "7962A5".toColor(),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
