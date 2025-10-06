import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/src/hex_color.dart';

var logger = Logger();

class DefaultActions extends StatelessWidget {
  const DefaultActions({super.key});

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 60.0; 
    const double visibleBarHeight = 80;

    return Positioned(
            top: visibleBarHeight - (buttonSize / 2),
            left: 20,
            right: 20,
            height: buttonSize, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          );
  }
}