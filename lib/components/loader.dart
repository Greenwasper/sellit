import 'package:flutter/material.dart';

class Loader extends StatelessWidget {

  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black.withOpacity(0.6),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
