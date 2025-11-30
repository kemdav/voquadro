import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/registration_controller.dart';

class RegistrationConfirmationStage extends StatelessWidget {
  const RegistrationConfirmationStage({super.key});

  void _goBack(BuildContext context) {
    context.read<RegistrationController>().goBack();
  }

  Future<void> _completeRegistration(BuildContext context) async {
    final registrationController = context.read<RegistrationController>();
    final appFlowController = context.read<AppFlowController>();

    await registrationController.completeRegistration();

    if (context.mounted) {
      // Check if registration was successful (no error message)
      if (registrationController.errorMessage == null) {
        appFlowController.login(
          registrationController.username!,
          registrationController.password!,
        );
      }
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
              backgroundColor: Colors.grey.shade600,
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
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[400],
              child: Consumer<RegistrationController>(
                builder: (context, controller, child) {
                  return Text(
                    controller.username ?? 'User',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
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
