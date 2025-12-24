import 'package:flutter/material.dart';
import 'theme_toggle_button.dart';
import 'visibility_button.dart';

class AppHeaderActions extends StatelessWidget {
  final List<Widget>? extraActions;

  const AppHeaderActions({super.key, this.extraActions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const VisibilityButton(),
        const ThemeToggleButton(),
        ...?extraActions,
      ],
    );
  }
}
