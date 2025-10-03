import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/mode_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/status_page.dart';
import 'package:voquadro/views/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/views/widgets/AppBar/default_actions.dart';
import 'package:voquadro/views/widgets/BottomBar/general_navigation_bar.dart';
import 'package:voquadro/views/widgets/BottomBar/mode_selection_actions.dart';

List<Widget> pages = [PublicSpeakingHomePage(), PublicSpeakingStatusPage()];

class MainSelectionPage extends StatefulWidget {
  const MainSelectionPage({super.key});

  @override
  State<MainSelectionPage> createState() => _MainSelectionPageState();
}

class _MainSelectionPageState extends State<MainSelectionPage> {
  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: PublicSpeakingHomePage(),
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
