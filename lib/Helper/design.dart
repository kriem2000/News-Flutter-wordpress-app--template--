import 'package:flutter/material.dart';

class DesignConfig {
  static ClipRRect setRoundedBorderCard(double radius) {
    return ClipRRect(borderRadius: BorderRadius.circular(10.0));
  }

  static BoxDecoration boxDecorationContainer(Color color, double bottomLeft,
      double bottomRight, double topLeft, double topRight) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(bottomRight),
          bottomLeft: Radius.circular(bottomLeft),
          topLeft: Radius.circular(topLeft),
          topRight: Radius.circular(topRight)),
    );
  }

  static setSvgPath(String name) {
    return "assets/images/svg/$name.svg";
  }

  static setPngPath(String name) {
    return "assets/images/image/4.0x/$name.png";
  }
}
