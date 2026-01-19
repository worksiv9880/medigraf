import 'package:flutter/material.dart';

class EmptyMetricsView extends StatelessWidget {
  final VoidCallback onAddParameter;

  const EmptyMetricsView({super.key, required this.onAddParameter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No metrics yet',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onAddParameter,
            icon: const Icon(Icons.add),
            label: const Text('Add Parameter'),
          ),
        ],
      ),
    );
  }
}
