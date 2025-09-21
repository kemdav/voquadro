import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class AppBarMode extends StatelessWidget {
  const AppBarMode({super.key});

  @override
  Widget build(BuildContext context) {
    const double visibleBarHeight = 80.0;
    const double buttonSize = 60.0; 
    const double buttonOverflow = 20.0;
    
    const double totalWidgetHeight = visibleBarHeight + buttonOverflow;

    return SizedBox(
      height: totalWidgetHeight,
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: visibleBarHeight,
            child: Container(
              decoration: BoxDecoration(
                color: "49416D".toColor(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: visibleBarHeight - (buttonSize / 2),
            left: 20,
            right: 20,
            height: buttonSize, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.filled(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 50, 
                  style: IconButton.styleFrom(
                    backgroundColor: "7962A5".toColor(),
                    foregroundColor: Colors.white,
                  ),
                ),

                Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => logger.d('profile pressed!'),
                      icon: const Icon(Icons.person),
                      iconSize: 50,
                      style: IconButton.styleFrom(
                        backgroundColor: "7962A5".toColor(),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: () => logger.d('settings pressed!'),
                      icon: const Icon(Icons.settings),
                      iconSize: 50,
                      style: IconButton.styleFrom(
                        backgroundColor: "7962A5".toColor(),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}