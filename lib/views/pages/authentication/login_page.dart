import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/home/main_page.dart';
import 'package:voquadro/views/pages/authentication/registration_page.dart';
import 'package:voquadro/src/authentication/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invalidAuthentication = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(width: double.infinity, child: Text('Email')),
            TextField(controller: emailController,),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: Text('Password')),
            TextField(controller : passwordController,),
            SizedBox(height: 20),
            invalidAuthentication == true ? Text('WRONG INFORMATION') : SizedBox(height: 0,),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setState(() {
                  invalidAuthentication = false;
                  isLoading = true;
                });

                final result = await AuthService.authenticateUser(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );

                setState(() {
                  isLoading = false;
                });

                if (result['success']) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
              },
              child: isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationPage(),
                  ),
                );
              },
              child: Text('Don\'t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
