import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class AppBarGeneral extends StatelessWidget {
  const AppBarGeneral({super.key, required this.actionButtons});

  final Widget actionButtons;

  @override
  Widget build(BuildContext context) {
    const double visibleBarHeight = 80.0;
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

          actionButtons,
        ],
      ),
    );
  }
}
