import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/controllers/home_controller.dart';
import 'package:voquadro/screens/authentication/home/public_speaking_selection_page.dart';
import 'package:voquadro/screens/authentication/registration/username_stage.dart';
import 'package:voquadro/screens/authentication/registration/password_stage.dart';
import 'package:voquadro/screens/authentication/registration/confirmation_stage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Scaffold(
        body: Consumer<HomeController>(
          builder: (context, homeController, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStage(context, homeController.stage),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStage(BuildContext context, HomeStage stage) {
    switch (stage) {
      case HomeStage.home:
        return PublicSpeakingSelectionPage(key: ValueKey('home'));
      case HomeStage.profile:
        return RegistrationPasswordStage(key: ValueKey('profile'));
      case HomeStage.statistics:
        return RegistrationConfirmationStage(key: ValueKey('statistics'));
    }
  }
}
