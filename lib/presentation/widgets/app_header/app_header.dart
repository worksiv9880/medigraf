import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return AppBar(
      title: const Text('MediGraf'),
      actions: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
          ),
          onPressed: () {
            ref.read(themeProvider.notifier).state = !isDark;
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
