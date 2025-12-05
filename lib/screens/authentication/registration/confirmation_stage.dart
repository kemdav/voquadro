import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/registration_controller.dart';
import 'package:voquadro/src/hex_color.dart';

class RegistrationConfirmationStage extends StatelessWidget {
  const RegistrationConfirmationStage({super.key});

  void _goBack(BuildContext context) {
    context.read<RegistrationController>().goBack();
  }

  Future<void> _completeRegistration(BuildContext context) async {
    // Capture controllers before the async gap
    final registrationController = context.read<RegistrationController>();
    final appFlowController = context.read<AppFlowController>();

    // This will trigger a rebuild of RegistrationScreen, causing this widget (ConfirmationStage)
    // to be disposed as it switches to the 'submitting' loading indicator.
    await registrationController.completeRegistration();

    // Because this widget is disposed, context.mounted would be false here.
    // However, we already captured the controllers, so we can proceed with the logic.

    // Check if registration was successful (no error message)
    if (registrationController.errorMessage == null) {
      debugPrint("Registration successful, proceeding to auto-login...");
      try {
        appFlowController.login(
          registrationController.username!,
          registrationController.password!,
        );
      } catch (e) {
        debugPrint("Error calling login from registration: $e");
      }
    } else {
      debugPrint(
        "Registration failed with error: ${registrationController.errorMessage}",
      );
      // If there was an error, the controller sets the stage back to confirmation.
      // Since this widget was disposed, we can't update IT, but the parent RegistrationScreen
      // will rebuild with the ConfirmationStage again (because of notifyListeners in controller),
      // showing the error message.
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryText = Color(0xFF322082);
    const Color accentTeal = Color(0xFF00A9A5);
    const Color buttonPurple = Color(0xFF7962A5);
    const Color chipBorder = Color(0xFFEDD5F6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              IconButton(
                onPressed: () => _goBack(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: buttonPurple),
                iconSize: 30,
              ),
            ],
          ),
          const SizedBox(height: 100),

          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: '#f5fbf9'.toColor(),
              backgroundImage: const AssetImage('assets/images/dolph.png'),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: buttonPurple, width: 1.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 1,
                color: accentTeal,
                backgroundColor: chipBorder.withAlpha(128),
                minHeight: 12,
              ),
            ),
          ),

          const SizedBox(height: 45),

          Text(
            "Bravo! Let's start.🐬",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: primaryText,
            ),
          ),

          const SizedBox(height: 40),

          Center(
            child: Consumer<RegistrationController>(
              builder: (context, controller, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: buttonPurple.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: buttonPurple.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "NOVICE",
                        style: TextStyle(
                          color: buttonPurple.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.username ?? 'User',
                        style: const TextStyle(
                          color: primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          // Error message display
          Consumer<RegistrationController>(
            builder: (context, controller, child) {
              if (controller.errorMessage != null) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    controller.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _completeRegistration(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 6,
                shadowColor: buttonPurple.withAlpha(102),
              ),
              child: const Text(
                'Start Your Adventure',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
