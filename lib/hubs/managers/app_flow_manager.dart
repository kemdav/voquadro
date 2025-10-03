// lib/screens/app_flow_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD:lib/screens/app_flow_manager.dart
import 'package:voquadro/screens/home_screen.dart';
import 'package:voquadro/screens/registration_screen.dart';
import 'package:voquadro/screens/authentication/login/login_page.dart';
import 'package:voquadro/screens/authentication/firstLaunch/first_launch_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/mode_page.dart';
import 'package:voquadro/screens/authentication/home/public_speaking_selection_page.dart';
=======
import 'package:voquadro/hubs/managers/game_mode_manager.dart';
import 'package:voquadro/hubs/managers/registration_screen.dart';
import 'package:voquadro/screens/authentication/login/login_page.dart';
import 'package:voquadro/screens/authentication/firstLaunch/first_launch_page.dart';
>>>>>>> my-temp-fixes:lib/hubs/managers/app_flow_manager.dart
import '../controllers/app_flow_controller.dart';

class AppFlowManager extends StatelessWidget {
  const AppFlowManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppFlowController>(
      builder: (context, appFlow, child) {
        switch (appFlow.appState) {
          case AppState.firstLaunch:
            return FirstLaunchPage();
          case AppState.login:
            return LoginPage();
          case AppState.registration:
            return RegistrationScreen();
          case AppState.unauthenticated:
            return LoginPage();
          case AppState.authenticating:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AppState.authenticated:
<<<<<<< HEAD:lib/screens/app_flow_manager.dart
            return PublicSpeakingHomePage();
          case AppState.home:
            return HomeScreen();
=======
            return const GameModeManager();
>>>>>>> my-temp-fixes:lib/hubs/managers/app_flow_manager.dart
        }
      },
    );
  }
}
