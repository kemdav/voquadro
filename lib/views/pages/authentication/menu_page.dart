import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/authentication/login_page.dart';
import 'package:voquadro/views/pages/authentication/registration_section/registration_page_1.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F0FB); // page background (matches login)
    const Color primaryText = Color(0xFF322082); // headings and links
    const Color buttonPurple = Color(0xFF7962A5); // primary button color
    const Color chipBorder = Color(0xFFEDD5F6); // light border for secondary

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
                backgroundColor: Colors.grey.shade600,
                child: const Text(
                  'LOGO',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
                  // start button to registration flow
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegistrationPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonPurple,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: buttonPurple.withOpacity(0.4),
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

                  // alr have acc to login flow
                  SizedBox(
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: chipBorder, width: 2),
                        backgroundColor: Colors.white.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.08),
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
