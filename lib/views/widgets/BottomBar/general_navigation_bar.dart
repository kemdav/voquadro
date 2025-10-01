import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class GeneralNavigationBar extends StatefulWidget {
  const GeneralNavigationBar({super.key, required this.actions, required this.navBarVisualHeight, required this.totalHitTestHeight});

  final Widget actions;
  final double navBarVisualHeight;
  final double totalHitTestHeight;

  @override
  State<GeneralNavigationBar> createState() => _GeneralNavigationBarState();
}

class _GeneralNavigationBarState extends State<GeneralNavigationBar> {
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: widget.totalHitTestHeight,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: widget.navBarVisualHeight,
              decoration: BoxDecoration(color: "49416D".toColor()),
            ),
          ),
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            child: widget.actions,
          ),
        ],
      ),
    );
  }
}