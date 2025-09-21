import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/views/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/views/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/views/widgets/BottomBar/general_navigation_bar.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/views/widgets/BottomBar/speaking_actions.dart';

var logger = Logger();

class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: customAppBarHeight),
                  child: IconButton.filled(
                    onPressed: () {
                      logger.d('Mic Button Pressed!');
                    },
                    icon: const Icon(Icons.mic),
                    iconSize: 150,
                    style: IconButton.styleFrom(
                      backgroundColor: "00A9A5".toColor(),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Start Speaking',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarGeneral(actionButtons: EmptyActions()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GeneralNavigationBar(
              actions: SpeakingActions(),
              navBarVisualHeight: 30,
              totalHitTestHeight: 50,
            ),
          ),
        ],
      ),
    );
  }
}
