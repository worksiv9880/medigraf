import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return IconButton(
      icon: Icon(
        isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).state = !isDark;
      },
    );
  }
}
