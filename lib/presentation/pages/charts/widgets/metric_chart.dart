import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/datasources/local/app_database.dart';

class MetricChart extends ConsumerWidget {
  final Metric metric;
  final int days;

  const MetricChart({
    super.key,
    required this.metric,
    required this.days,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(metricDataPointsProvider(metric.id));

    return dataAsync.when(
      data: (points) {
        if (points.isEmpty) {
          return const Center(child: Text('No data points yet'));
        }

        final cutoff = DateTime.now().subtract(Duration(days: days));
        final filtered =
            points.where((p) => p.recordedAt.isAfter(cutoff)).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No data in selected range'));
        }

        final spots = filtered.asMap().entries.map(
              (e) => FlSpot(e.key.toDouble(), e.value.value),
            );

        return Padding(
          padding: const EdgeInsets.all(24),
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots.toList(),
                  isCurved: true,
                  color: AppTheme.chartBlue,
                  barWidth: 3,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
