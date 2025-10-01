import 'package:flutter/material.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:voquadro/views/pages/authentication/login_page.dart';
import 'package:voquadro/views/pages/home_page.dart';
import 'package:voquadro/views/pages/profile_page.dart';

List<Widget> pages = [HomePage(), ProfilePage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voquadro'),
        centerTitle: true,
        actions: [
          ValueListenableBuilder(
            valueListenable: isDarkModeNotifier,
            builder: (context, value, child) {
              return IconButton(
                onPressed: () {
                  isDarkModeNotifier.value = !isDarkModeNotifier.value;
                },
                icon: value == true
                    ? Icon(Icons.dark_mode)
                    : Icon(Icons.light_mode),
              );
            },
          ),
        ],
      ),
      body: LoginPage(),
    );
  }
}
