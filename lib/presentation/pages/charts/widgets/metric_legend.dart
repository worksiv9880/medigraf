import 'package:flutter/material.dart';
import '../models/chart_parameter.dart';
import '../utils/chart_colors.dart';

class MetricLegend extends StatelessWidget {
  final List<ChartParameter> metrics;
  final ChartParameter selectedMetric;
  final ValueChanged<ChartParameter> onSelected;

  const MetricLegend({
    super.key,
    required this.metrics,
    required this.selectedMetric,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        children: metrics.take(6).map((metric) {
          final isSelected = metric == selectedMetric;
          final color =
              chartColors[metrics.indexOf(metric) % chartColors.length];

          return GestureDetector(
            onTap: () => onSelected(metric),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 3, height: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  metric.name,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
