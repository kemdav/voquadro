import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/src/hex_color.dart';

var logger = Logger();

class SpeakingActions extends StatelessWidget {
  const SpeakingActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
              value: 0.3, 
              minHeight: 10,    
              backgroundColor: Colors.grey[300],
              color: "6CCC51".toColor(),
            ),
        ),
      ],
    );
  }
}
