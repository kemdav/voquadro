import 'package:flutter/material.dart';
import 'package:voquadro/src/authentication/login.dart';
import 'package:voquadro/views/pages/home/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invalidAuthentication = false;

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
                  // Warning logic for mismatch of log information
                  setState(() {
                    invalidAuthentication = true;
                  });
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
