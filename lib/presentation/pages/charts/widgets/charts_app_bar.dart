import 'package:flutter/material.dart';

class ChartsAppBar extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onDaysChanged;

  const ChartsAppBar({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      child: PopupMenuButton<int>(
        icon: const Icon(Icons.more_vert),
        onSelected: onDaysChanged,
        itemBuilder: (context) => const [
          PopupMenuItem(value: 7, child: Text('Last 7 days')),
          PopupMenuItem(value: 14, child: Text('Last 14 days')),
          PopupMenuItem(value: 30, child: Text('Last 30 days')),
        ],
      ),
    );
  }
}
