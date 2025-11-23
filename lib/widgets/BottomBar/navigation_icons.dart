import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';

var logger = Logger();

/// Navigation icons row that appears in the purple bar at the bottom.
/// Contains: Home, FAQ, Adventure Mode, User Journey, Options Tray
class NavigationIcons extends StatelessWidget {
  const NavigationIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Home icon
        IconButton(
          onPressed: () {
            logger.d('Home icon pressed!');
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/house.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // FAQ icon
        IconButton(
          onPressed: () {
            logger.d('FAQ icon pressed!');
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/faq.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // Adventure mode icon
        IconButton(
          onPressed: () {
            logger.d('Adventure mode icon pressed!');
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/adventure_mode.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // User Journey icon
        IconButton(
          onPressed: () {
            logger.d('User Journey icon pressed!');

            final appFlow = context.read<AppFlowController>();

            if (appFlow.currentMode == AppMode.publicSpeaking) {
              final user = appFlow.currentUser;

              if (user != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PublicSpeakJourneySection(
                      username: user.username,
                      currentXP: 69,
                      maxXP: 200,
                      currentLevel: 'Level 69',
                      averageWPM: 0,
                      averageFillers: 0,
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
            }
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/user_journal.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // Options Tray icon
        IconButton(
          onPressed: () {
            logger.d('Options Tray icon pressed!');
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/home_options.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
      ],
    );
  }
}
