import 'package:flutter/material.dart';
import 'package:voquadro/data/notifiers.dart';

class NavbarModeSelectionWidget extends StatelessWidget {
  const NavbarModeSelectionWidget({super.key, required this.statusPage});

  final Widget statusPage;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: publicModeSelectedNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.person_2_sharp), label: 'Speak'),
            NavigationDestination(icon: Icon(Icons.analytics_sharp), label: 'Status'),
          ],
          selectedIndex: selectedPage,
          onDestinationSelected: (int value) {
            publicModeSelectedNotifier.value = value;
          },
        );
      },
    );
  }
}
