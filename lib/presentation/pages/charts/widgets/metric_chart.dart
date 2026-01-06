import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';
import '../models/chart_parameter.dart';
import '../utils/chart_colors.dart';

class MetricChart extends ConsumerWidget {
  final ChartParameter metric;
  final List<Metric> metrics;
  final List<Participant> participants;
  final int days;

  const MetricChart({
    super.key,
    required this.metric,
    required this.metrics,
    required this.participants,
    required this.days,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (metrics.isEmpty) {
      return const Center(child: Text('No data points yet'));
    }

    final dataAsyncList = metrics
        .map((metric) => ref.watch(metricDataPointsProvider(metric.id)))
        .toList();

    final hasLoading = dataAsyncList.any((value) => value.isLoading);
    if (hasLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorValue = dataAsyncList
        .cast<AsyncValue<List<MetricDataPoint>>>()
        .firstWhere(
          (value) => value.hasError,
          orElse: () => const AsyncValue<List<MetricDataPoint>>.data([]),
        );
    if (errorValue.hasError) {
      return Center(child: Text('Error: ${errorValue.error}'));
    }

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final series = <_ParticipantSeries>[];

    for (var index = 0; index < metrics.length; index++) {
      final metricModel = metrics[index];
      final points = dataAsyncList[index].value ?? [];
      final participantIndex = participants.indexWhere(
        (participant) => participant.id == metricModel.participantId,
      );
      if (participantIndex == -1) continue;

      final filtered =
          points.where((p) => p.recordedAt.isAfter(cutoff)).toList();
      if (filtered.isEmpty) continue;

      final spots = filtered
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
          .toList();

      series.add(
        _ParticipantSeries(
          participant: participants[participantIndex],
          spots: spots,
          color: chartColors[participantIndex % chartColors.length],
        ),
      );
    }

    if (series.isEmpty) {
      return const Center(child: Text('No data in selected range'));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                lineBarsData: series
                    .map(
                      (entry) => LineChartBarData(
                        spots: entry.spots,
                        isCurved: true,
                        color: entry.color,
                        barWidth: 3,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          if (participants.length > 1) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: series
                  .map(
                    (entry) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: entry.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${entry.participant.emoji} ${entry.participant.name}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParticipantSeries {
  final Participant participant;
  final List<FlSpot> spots;
  final Color color;

  const _ParticipantSeries({
    required this.participant,
    required this.spots,
    required this.color,
  });
}
