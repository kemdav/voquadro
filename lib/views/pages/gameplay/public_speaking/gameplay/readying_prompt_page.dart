import 'package:flutter/material.dart';
import 'package:voquadro/views/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/views/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/views/widgets/BottomBar/gameplay_actions.dart';
import 'package:voquadro/views/widgets/BottomBar/general_navigation_bar.dart';

class ReadyingPromptPage extends StatelessWidget {
  const ReadyingPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: Text('GH'),
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
              actions: GameplayActions(),
              navBarVisualHeight: 70,
              totalHitTestHeight: 130,
            ),
          ),
        ],
      ),
    );
  }
}