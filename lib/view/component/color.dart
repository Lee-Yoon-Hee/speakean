import 'package:flutter/material.dart';


extension ColorExtension on Color {
  Color onWhite([double opacity = 0.5]) {
    return Color.alphaBlend(withOpacity(opacity), Colors.white);
  }
}

class MyColor {

  static const Color purple = Color(0xFF9B8DFF); // rgb(155,141,255)

  static const Color sky = Color(0xFFBEE5FF); // rgb(190,229,255)

  static const Color purpleOnSky = Color(0xFFADB9FF); // rgb(173,185,255)

  static const Color whiteOnSky = Color(0xFFDFF2FF); // rgb(223,242,255)

  static const Color grey = Color(0xFFA1A1A1);

  // by https://sashamaps.net/docs/resources/20-colors/
  static const List<Color> color16 = [
    Color(0xFFE6194B),
    Color(0xFFF58231),
    Color(0xFFFFE119),
    Color(0xFFBFEF45),
    Color(0xFF3CB44B),
    Color(0xFF42D4F4),
    Color(0xFF4363D8),
    Color(0xFF911EB4),
    Color(0xFFF032E6),
    Color(0xFF800000),
    Color(0xFF9A6324),
    Color(0xFF808000),
    Color(0xFF469990),
    Color(0xFF000075),
    Color(0xFFA9A9A9),
    Color(0xFF000000),
  ];
}