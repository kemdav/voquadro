// lib/screens/app_flow_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/managers/game_mode_manager.dart';
import 'package:voquadro/hubs/managers/registration_screen.dart';
import 'package:voquadro/screens/authentication/login/login_page.dart';
import 'package:voquadro/screens/authentication/firstLaunch/first_launch_page.dart';
import '../controllers/app_flow_controller.dart';

class AppFlowManager extends StatelessWidget {
  const AppFlowManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppFlowController>(
      builder: (context, appFlow, child) {
        debugPrint('AppFlowManager: Building with state ${appFlow.appState}');
        Widget currentPage;
        switch (appFlow.appState) {
          case AppState.firstLaunch:
            currentPage = const FirstLaunchPage(
              key: ValueKey('FirstLaunchPage'),
            );
            break;
          case AppState.login:
            currentPage = const LoginPage(key: ValueKey('LoginPage'));
            break;
          case AppState.registration:
            currentPage = const RegistrationScreen(
              key: ValueKey('RegistrationScreen'),
            );
            break;
          case AppState.unauthenticated:
            currentPage = const LoginPage(key: ValueKey('LoginPage_Unauth'));
            break;
          case AppState.authenticating:
            currentPage = const Scaffold(
              key: ValueKey('Authenticating'),
              body: Center(child: CircularProgressIndicator()),
            );
            break;
          case AppState.authenticated:
            currentPage = const GameModeManager(
              key: ValueKey('GameModeManager'),
            );
            break;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: currentPage,
        );
      },
    );
  }
}
