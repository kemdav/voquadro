import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/mode_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/status_page.dart';
import 'package:voquadro/views/pages/home/profile/profile_main_page.dart';
import 'package:voquadro/views/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/views/widgets/AppBar/default_actions.dart';
import 'package:voquadro/views/widgets/BottomBar/general_navigation_bar.dart';
import 'package:voquadro/views/widgets/BottomBar/mode_selection_actions.dart';

List<Widget> pages = [PublicSpeakingHomePage(), PublicSpeakingStatusPage()];

class ProfileController extends StatefulWidget {
  const ProfileController({super.key});

  @override
  State<ProfileController> createState() => _ProfileControllerState();
}

class _ProfileControllerState extends State<ProfileController> {
  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: ProfileMainPage(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarGeneral(actionButtons: DefaultActions()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GeneralNavigationBar(
              actions: ModeSelectionActions(),
              navBarVisualHeight: 140,
              totalHitTestHeight: 180,
            ),
          ),
        ],
      ),
    );
  }
}
