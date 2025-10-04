import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/registration_controller.dart';

class RegistrationUsernameStage extends StatefulWidget {
  const RegistrationUsernameStage({super.key});

  @override
  State<RegistrationUsernameStage> createState() => _RegistrationUsernameStageState();
}

class _RegistrationUsernameStageState extends State<RegistrationUsernameStage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    final registrationController = context.read<RegistrationController>();
    
    registrationController.submitUsername(_usernameController.text, _emailController.text);
  }

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
                      onPressed: () => Navigator.of(context).maybePop(),
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
                    backgroundImage: const AssetImage(
                      'assets/images/tempCharacter.png',
                    ),
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
                      value: 0.22,
                      color: accentTeal,
                      backgroundColor: chipBorder.withAlpha(128),
                      minHeight: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 45),
                Text(
                  "Let's start with a name…",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                  ),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _usernameController,
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
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().length < 4) {
                      return 'Username must be at least 4 characters';
                    }
                    return null; 
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Color(0xFF322082)),
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF7962A5)),
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
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
    );
  }
}