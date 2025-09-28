import 'package:flutter/material.dart';
import 'registration_page_2.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

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
              //back button
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
                  backgroundColor: colors.surfaceContainerHighest,
                  backgroundImage: const AssetImage(
                    'assets/images/tempCharacter.png',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 12,
                  child: LinearProgressIndicator(
                    value: 0.22,
                    color: const Color(0xFF00A9A5),
                    backgroundColor: colors.outlineVariant.withOpacity(0.5),
                    minHeight: 12,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Let's start with a name…
              Text(
                "Let's start with a name…",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF322082),
                ),
              ),

              const SizedBox(height: 40),

              // Username field
              _UsernameField(),

              const Spacer(),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegistrationPage2(),
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
                    shadowColor: colors.primary.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Continue',
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

class _UsernameField extends StatefulWidget {
  @override
  State<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<_UsernameField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Username',
        hintStyle: const TextStyle(color: Color(0xFF322082)),
        prefixIcon: const Icon(Icons.person, color: Color(0xFF7962A5)),
        filled: true,
        fillColor: const Color(0xFFE5D3EC),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFE5D3EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFE5D3EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFE5D3EC), width: 2),
        ),
      ),
      textInputAction: TextInputAction.done,
    );
  }
}
