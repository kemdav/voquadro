import 'package:flutter/material.dart';
import '../../gameplay/public_speaking/public_speaking_gameplay_page.dart';

class RegistrationPage3 extends StatelessWidget {
  const RegistrationPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FB),
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
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF7962A5),
                    ),
                    iconSize: 30,
                  ),
                ],
              ),
              const SizedBox(height: 100),

              // placeholder logo
              Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.grey[600],
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
                  border: Border.all(
                    color: const Color(0xFF7962A5), // Border color
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12), // Rounded border
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Inner rounding
                  child: LinearProgressIndicator(
                    value: 1,
                    color: const Color(0xFF00A9A5),
                    backgroundColor: colors.outlineVariant.withOpacity(0.5),
                    minHeight: 12,
                  ),
                ),
              ),

              const SizedBox(height: 45),

              // Bravo! Let's start. with dolphin icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bravo! Let's start.🐬",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF322082),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.pets, color: Colors.blue[400], size: 28),
                ],
              ),

              const SizedBox(height: 40),

              // Username display circle
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

              // Public Speaking button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            const PublicSpeakingGameplayPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7962A5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFF7962A5).withOpacity(0.4),
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
                    backgroundColor: const Color(0xFF7962A5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFF7962A5).withOpacity(0.4),
                  ),
                  child: const Text(
                    'Just Chatting',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
