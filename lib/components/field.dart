import 'package:flutter/material.dart';

class Field extends StatelessWidget {

  final TextEditingController controller;
  final String labelText;
  final TextInputType textInputType;

  const Field({super.key, this.labelText = '', required this.controller, this.textInputType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      keyboardType: textInputType,
      decoration: InputDecoration(
        label: Text(labelText, style: const TextStyle(color: Colors.black)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Colors.black)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Colors.black)
        ),
      ),
    );
  }
}
