import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar with back button
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: colors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.primary.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Centered circular placeholder logo using tempCharacter
              Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: colors.surfaceVariant,
                  backgroundImage: const AssetImage(
                    'assets/images/tempCharacter.png',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Rounded progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 12,
                  child: LinearProgressIndicator(
                    value: 0.22,
                    color: colors.tertiary,
                    backgroundColor: colors.outlineVariant.withOpacity(0.5),
                    minHeight: 12,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Title
              Text(
                "Let's start with a name…",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),

              const Spacer(),

              // Username field with leading icon and large radius
              _UsernameField(),

              const SizedBox(height: 24),

              // Continue button with big rounded corners and subtle shadow
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
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
        prefixIcon: Icon(Icons.person, color: colors.primary),
        filled: true,
        fillColor: colors.primary.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
      textInputAction: TextInputAction.done,
    );
  }
}
