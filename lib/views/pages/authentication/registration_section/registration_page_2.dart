import 'package:flutter/material.dart';
import 'registration_page_3.dart';

class RegistrationPage2 extends StatefulWidget {
  const RegistrationPage2({super.key});

  @override
  State<RegistrationPage2> createState() => _RegistrationPage2State();
}

class _RegistrationPage2State extends State<RegistrationPage2> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // back button
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 12,
                  child: LinearProgressIndicator(
                    value: 0.65,
                    color: const Color(0xFF00A9A5),
                    backgroundColor: const Color(0xFFE5D3EC),
                    minHeight: 12,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // You're getting there! with dolphin icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You're getting there!",
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

              // Password field
              _PasswordField(
                controller: _passwordController,
                hintText: 'Password',
                isVisible: _isPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Confirm Password field
              _PasswordField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                isVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),

              const Spacer(),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegistrationPage3(),
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

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF322082)),
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF7962A5), size: 20),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF7F7F7F).withOpacity(0.5),
          ),
        ),
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
