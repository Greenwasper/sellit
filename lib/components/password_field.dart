import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {

  final TextEditingController controller;
  final bool passwordObscured;
  final VoidCallback setPasswordObscured;

  const PasswordField({super.key, required this.controller, required this.passwordObscured, required this.setPasswordObscured});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: passwordObscured,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        suffix: IconButton(
            onPressed: setPasswordObscured,
            icon: Icon(passwordObscured ? Icons.visibility_off : Icons.visibility, size: 20,)),
        contentPadding: const EdgeInsets.only(top: 5, bottom: 5, left: 12),
        label: const Text("Password", style: TextStyle(color: Colors.black)),
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
