import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {

  final String text;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;

  const CustomText({super.key, required this.text, this.fontSize = 14, this.color = Colors.black, this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
