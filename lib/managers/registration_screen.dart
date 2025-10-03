import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/registration_controller.dart';
import 'package:voquadro/screens/authentication/registration/username_stage.dart';
import 'package:voquadro/screens/authentication/registration/password_stage.dart';
import 'package:voquadro/screens/authentication/registration/confirmation_stage.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the RegistrationController ONLY to this screen and its children
    return ChangeNotifierProvider(
      create: (_) => RegistrationController(),
      child: Scaffold(
        body: Consumer<RegistrationController>(
          builder: (context, regController, child) {
            // A great place for AnimatedSwitcher for smooth transitions!
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStage(context, regController.stage),
            );
          },
        ),
      ),
    );
  }

  // Helper method to return the correct widget for the stage
  Widget _buildStage(BuildContext context, RegistrationStage stage) {
    switch (stage) {
      case RegistrationStage.username:
        // Use a Key to help AnimatedSwitcher differentiate widgets
        return RegistrationUsernameStage(key: ValueKey('username'));
      case RegistrationStage.password:
        return RegistrationPasswordStage(key: ValueKey('password'));
      case RegistrationStage.confirmation:
        return RegistrationConfirmationStage(key: ValueKey('confirm'));
      case RegistrationStage.submitting:
        return Center(key: ValueKey('submitting'), child: CircularProgressIndicator());
    }
  }
}