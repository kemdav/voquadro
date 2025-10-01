import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/views/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/views/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/views/widgets/BottomBar/gameplay_actions.dart';
import 'package:voquadro/views/widgets/BottomBar/general_navigation_bar.dart';

class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});

  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> {
  final GlobalKey<State<GameplayActions>> _gameplayActionsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: Center(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: 0.3,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: "6CCC51".toColor(),
                  ),
                  Container(
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "DOES LBGT PEOPLE DESERVE RIGHTS?",
                        style: TextStyle(fontSize: 24, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Image.asset('assets/images/tempCharacter.png'),
                ],
              ),
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
              actions: GameplayActions(key: _gameplayActionsKey),
              navBarVisualHeight: 70,
              totalHitTestHeight: 130,
            ),
          ),
        ],
      ),
    );
  }
}
