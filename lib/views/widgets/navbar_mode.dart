import 'package:flutter/material.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:voquadro/src/hex_color.dart';

class NavbarMode extends StatefulWidget {
  const NavbarMode({super.key, required this.statusPage});

  final Widget statusPage;

  @override
  State<NavbarMode> createState() => _NavbarModeState();
}

class _NavbarModeState extends State<NavbarMode> {
  @override
  Widget build(BuildContext context) {
    const double navBarHeight = 70.0;
    const double buttonHeight = 90.0;
     return SizedBox(
      height: buttonHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: navBarHeight,
              decoration: BoxDecoration(
                color: "49416D".toColor(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                ],
              ),
            ),
          ),
          Positioned(
            top: -20,
            bottom: 30,
            left: 20,
            child: Row(
              children: [
                SizedBox(
                  height: buttonHeight,
                  width: 250,
                  child: FloatingActionButton(
                    shape: const StadiumBorder(),
                    onPressed: () {
                    },
                    backgroundColor: "00A9A5".toColor(),
                    elevation: 3.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          
                          'Start Speaking!',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                CircleAvatar(
                  backgroundColor: "7962A5".toColor(),
                  radius: 40,
                  child: IconButton(onPressed: () {
                    
                  }, icon: Icon(Icons.analytics), iconSize: 50, color: Colors.white,),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
