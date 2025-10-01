import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/home/main_page.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Login Page'),
          TextField(),
          ElevatedButton(onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return MainPage();
            },));
          }, child: Text('Login'))
        ],
      ),
    );
  }
}