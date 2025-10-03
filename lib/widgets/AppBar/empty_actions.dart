import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class EmptyActions extends StatelessWidget {
  const EmptyActions({super.key});

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
            ),
          );
  }
}