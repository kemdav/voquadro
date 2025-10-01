import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_selection_page.dart';

class RegistrationPage3 extends StatelessWidget {
  const RegistrationPage3({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F0FB);
    const Color primaryText = Color(0xFF322082);
    const Color accentTeal = Color(0xFF00A9A5);
    const Color buttonPurple = Color(0xFF7962A5);
    const Color chipBorder = Color(0xFFEDD5F6);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // back button
              const SizedBox(height: 30),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: buttonPurple),
                    iconSize: 30,
                  ),
                ],
              ),
              const SizedBox(height: 100),

              // placeholder logo
              Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.grey.shade600,
                  child: const Text(
                    'Logo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // progress bar
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
                    backgroundColor: chipBorder.withValues(alpha: 0.5),
                    minHeight: 12,
                  ),
                ),
              ),

              const SizedBox(height: 45),

              // Bravo! Let's start.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bravo! Let's start.🐬",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(height: 40),

              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[400],
                  child: const Text(
                    'dolph',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const SizedBox(height: 24),

              _ModeButtonsSection(buttonPurple: buttonPurple),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButtonsSection extends StatelessWidget {
  const _ModeButtonsSection({required this.buttonPurple});

  final Color buttonPurple;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Public Speaking button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const PublicSpeakingSelectionPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 6,
              shadowColor: buttonPurple.withValues(alpha: 0.4),
            ),
            child: const Text(
              'Public Speaking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Just Chatting button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Not functional for now
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 6,
              shadowColor: buttonPurple.withValues(alpha: 0.4),
            ),
            child: const Text(
              'Just Chatting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
