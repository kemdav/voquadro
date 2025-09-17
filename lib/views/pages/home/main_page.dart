import 'package:flutter/material.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:voquadro/views/pages/home/select_mode_page.dart';
import 'package:voquadro/views/widgets/navbar_widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          IconButton(onPressed: () {
            
          }, icon: Icon(Icons.person)),
          IconButton(onPressed: () {
            
          }, icon: Icon(Icons.settings)),
        ],
      ),
      bottomNavigationBar: NavbarWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rank: Normal Person'),
            Text('Pacing Control: 100'),
            Text('Filler Word Control: 100'),
            Image.asset('assets/images/tempCharacter.png'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SelectModePage();
                    },
                  ),
                );
              },
              child: Text('Start Speaking'),
            ),
          ],
        ),
      ),
    );
  }
}
