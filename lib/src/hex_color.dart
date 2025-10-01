import 'package:flutter/material.dart';

extension HexColor on String {
  Color toColor() {
    final hexString = startsWith('#') ? substring(1) : this;
    final buffer = StringBuffer();
    if (hexString.length == 6) buffer.write('ff');
    buffer.write(hexString);

    return Color(int.parse(buffer.toString(), radix: 16));
  }
}