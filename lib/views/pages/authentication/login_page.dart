import 'package:flutter/material.dart';
import 'package:voquadro/src/authentication/login.dart';
import 'package:voquadro/views/pages/home/main_page.dart';
import 'package:voquadro/views/pages/authentication/registration_section/registration_page_1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invalidAuthentication = false;
  bool rememberMe = true;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F0FB); // page background
    const Color primaryText = Color(0xFF322082); // headings and links
    const Color inputFill = Color(0xFFEADDF0); // user/password boxes
    const Color accentTeal = Color(0xFF00A9A5); // forgot password
    const Color buttonPurple = Color(0xFF7962A5); // login button
    const Color chipBorder = Color(0xFFEDD5F6); // social border
    const Color chipFill = Color(0xFFF8F0FB); // social fill

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: buttonPurple,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      iconSize: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // circular logo placeholder
              Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.grey.shade600,
                  child: const Text(
                    'Logo',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title: "Yo, what's up! 🐬"
              Center(
                child: Text(
                  "Yo, what's up! 🐬",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize:
                        40, // visually balanced on phones; requested 120 would overflow
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // username label and input
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Username',
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Your username',
                  filled: true,
                  fillColor: inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: inputFill),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: inputFill),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: inputFill, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password label and input
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Your password',
                  filled: true,
                  fillColor: inputFill,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: inputFill),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: inputFill),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: inputFill, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: primaryText,
                    ),
                    onPressed: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Remember me and Forgot password
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => rememberMe = !rememberMe),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: rememberMe
                                ? buttonPurple
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: buttonPurple, width: 2),
                          ),
                          child: rememberMe
                              ? const Icon(Icons.check, color: Colors.white)
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: accentTeal,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (invalidAuthentication)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'WRONG INFORMATION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Login button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      invalidAuthentication = false;
                    });
                    if (authenticateUser(
                          emailController.text,
                          passwordController.text,
                        ) ==
                        true) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return MainPage();
                          },
                        ),
                      );
                    } else {
                      setState(() {
                        invalidAuthentication = true;
                      });
                    }
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
                    'Login',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Or with divider
              Row(
                children: const [
                  Expanded(child: Divider(color: primaryText, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Or with',
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: primaryText, thickness: 1)),
                ],
              ),

              const SizedBox(height: 16),

              // Social buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.facebook,
                        color: Colors.blue,
                        size: 28,
                      ),
                      label: const Text(
                        'Facebook',
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: chipBorder, width: 2),
                        backgroundColor: chipFill,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.g_mobiledata_outlined,
                        color: primaryText,
                        size: 24,
                      ),
                      label: const Text(
                        'Google',
                        style: TextStyle(
                          color: primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: chipBorder, width: 2),
                        backgroundColor: chipFill,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bottom sign-up prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegistrationPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign in!',
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
