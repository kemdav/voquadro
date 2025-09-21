import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/authentication/login_page.dart';
import 'package:voquadro/src/authentication/auth_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool passwordsMatch = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Registration Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            SizedBox(width: double.infinity, child: Text('Email')),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: Text('Username')),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: 'Choose a username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: Text('Password')),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: Text('Confirm Password')),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm your password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  passwordsMatch = passwordController.text == value;
                });
              },
            ),
            SizedBox(height: 10),
            passwordsMatch == false ? Text('Passwords do not match', style: TextStyle(color: Colors.red)) : SizedBox(height: 0),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (passwordsMatch && 
                    emailController.text.isNotEmpty && 
                    usernameController.text.isNotEmpty && 
                    passwordController.text.isNotEmpty) {
                  
                  setState(() {
                    isLoading = true;
                  });

                  final result = await AuthService.registerUser(
                    email: emailController.text.trim(),
                    username: usernameController.text.trim(),
                    password: passwordController.text,
                  );

                  setState(() {
                    isLoading = false;
                  });

                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                    // Navigate to login page after successful registration
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields and ensure passwords match')),
                  );
                }
              },
              child: isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Register'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text('Already have an account? Login here'),
            ),
          ],
        ),
      ),
    );
  }
}