import 'package:flutter/material.dart';

class EmptyMetricsView extends StatelessWidget {
  final VoidCallback onAddMetric;

  const EmptyMetricsView({super.key, required this.onAddMetric});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No metrics yet'),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onAddMetric,
            icon: const Icon(Icons.add),
            label: const Text('Add Metric'),
          ),
        ],
      ),
    );
  }
}
