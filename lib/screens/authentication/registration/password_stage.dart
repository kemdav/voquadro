import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/registration_controller.dart';

class RegistrationPasswordStage extends StatefulWidget {
  const RegistrationPasswordStage({super.key});

  @override
  State<RegistrationPasswordStage> createState() => _RegistrationPasswordStageState();
}

class _RegistrationPasswordStageState extends State<RegistrationPasswordStage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final registrationController = context.read<RegistrationController>();
    registrationController.submitPassword(_passwordController.text);
  }

  void _goBack() {
    context.read<RegistrationController>().goBack();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryText = Color(0xFF322082);
    const Color accentTeal = Color(0xFF00A9A5);
    const Color buttonPurple = Color(0xFF7962A5);
    const Color chipBorder = Color(0xFFEDD5F6);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _goBack,
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
                            value: 0.65,
                            color: accentTeal,
                            backgroundColor: chipBorder.withAlpha(128),
                            minHeight: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 45),
                      Text(
                        "You're getting there! 🐬",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryText,
                            ),
                      ),

                      const SizedBox(height: 40),

                      _PasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        isVisible: _isPasswordVisible,
                        onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      _PasswordField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        isVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const Spacer(),

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            elevation: 6,
                            shadowColor: buttonPurple.withAlpha(102),
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
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.isVisible,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( 
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
            color: const Color(0xFF7F7F7F).withAlpha(128),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFE5D3EC),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
      validator: validator, 
    );
  }
}