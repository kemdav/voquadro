// lib/screens/game_mode_manager.dart (New File)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/managers/public_speaking_hub.dart';

class GameModeManager extends StatelessWidget {
  const GameModeManager({super.key});

  @override
  Widget build(BuildContext context) {
    final appFlow = context.watch<AppFlowController>();

    switch (appFlow.currentMode) {
      case AppMode.publicSpeaking:
        return const PublicSpeakingHub();
      case AppMode.modeSelection:
        return const Text('Mode Selection');
    }
  }
}
