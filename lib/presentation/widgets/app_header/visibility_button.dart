import 'package:flutter/material.dart';

class VisibilityButton extends StatelessWidget {
  const VisibilityButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.visibility_outlined),
      onPressed: () {
        // TODO: visibility logic
      },
    );
  }
}
