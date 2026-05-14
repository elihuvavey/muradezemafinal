import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const CustomText(
    this.text, {
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.white, // Default color is white
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
      textAlign: TextAlign.center,
    );
  }
}
