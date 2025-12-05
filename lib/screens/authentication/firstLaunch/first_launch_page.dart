import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';

class FirstLaunchPage extends StatelessWidget {
  const FirstLaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('FirstLaunchPage: Building');
    const Color bgColor = Color(0xFFF8F0FB);
    const Color primaryText = Color(0xFF322082);
    const Color buttonPurple = Color(0xFF7962A5);
    const Color chipBorder = Color(0xFFEDD5F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // placeholder logo
            Center(
              child: CircleAvatar(
                radius: 96,
                backgroundColor: Color(0xFFF8F0FB),
                backgroundImage: const AssetImage('assets/images/dolph.png'),
              ),
            ),

            const SizedBox(height: 32),

            const Center(
              child: Text(
                'Voquadro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Speak up. Or else.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<AppFlowController>()
                            .initiateRegistration();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonPurple,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: buttonPurple.withAlpha(102),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AppFlowController>().initiateLogin();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: chipBorder, width: 2),
                        backgroundColor: Colors.white.withAlpha(178),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withAlpha(20),
                      ),
                      child: const Text(
                        'I already have an account',
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
