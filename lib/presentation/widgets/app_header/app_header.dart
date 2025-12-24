import 'package:flutter/material.dart';
import 'app_header_actions.dart';

class AppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title = 'MediGraf',
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        AppHeaderActions(extraActions: actions),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}

