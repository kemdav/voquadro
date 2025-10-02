// lib/screens/app_flow_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/screens/registration_screen.dart';
import 'package:voquadro/views/pages/authentication/login_page.dart';
import 'package:voquadro/views/pages/authentication/menu_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/mode_page.dart';
import '../controllers/app_flow_controller.dart';

class AppFlowManager extends StatelessWidget {
  const AppFlowManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppFlowController>(
      builder: (context, appFlow, child) {
        switch (appFlow.appState) {
          case AppState.firstLaunch:
            return MenuPage();
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
            return PublicSpeakingModePage();
        }
      },
    );
  }
}