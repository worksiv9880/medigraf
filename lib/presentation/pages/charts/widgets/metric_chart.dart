import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/di/providers.dart';
import 'package:intl/intl.dart';

import '../../../../data/datasources/local/app_database.dart';
import '../utils/chart_colors.dart';

class MetricChart extends ConsumerWidget {
  final List<Metric> metrics;
  final List<Participant> participants;

  const MetricChart({
    super.key,
    required this.metrics,
    required this.participants,
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

    final dateIndex = <DateTime, int>{};
    final orderedDates = <DateTime>[];

    for (var index = 0; index < metrics.length; index++) {
      final metricModel = metrics[index];
      final points = dataAsyncList[index].value ?? [];
      final participantIndex = participants.indexWhere(
        (participant) => participant.id == metricModel.participantId,
      );
      if (participantIndex == -1) continue;

      if (points.isEmpty) continue;

      for (final point in points) {
        final day = DateTime(
          point.recordedAt.year,
          point.recordedAt.month,
          point.recordedAt.day,
        );
        if (!dateIndex.containsKey(day)) {
          dateIndex[day] = orderedDates.length;
          orderedDates.add(day);
        }
      }

    }

    orderedDates.sort();
    dateIndex
      ..clear()
      ..addEntries(
        orderedDates.asMap().entries.map(
              (entry) => MapEntry(entry.value, entry.key),
            ),
      );

    final updatedSeries = <_ParticipantSeries>[];

    for (var index = 0; index < metrics.length; index++) {
      final metricModel = metrics[index];
      final points = dataAsyncList[index].value ?? [];
      final participantIndex = participants.indexWhere(
        (participant) => participant.id == metricModel.participantId,
      );
      if (participantIndex == -1 || points.isEmpty) continue;

      final spots = points
          .map((point) {
            final day = DateTime(
              point.recordedAt.year,
              point.recordedAt.month,
              point.recordedAt.day,
            );
            final x = dateIndex[day];
            if (x == null) return null;
            return FlSpot(x.toDouble(), point.value);
          })
          .whereType<FlSpot>()
          .toList();

      if (spots.isEmpty) continue;

      updatedSeries.add(
        _ParticipantSeries(
          participant: participants[participantIndex],
          spots: spots,
          color: chartColors[participantIndex % chartColors.length],
        ),
      );
    }

    if (updatedSeries.isEmpty) {
      return const Center(child: Text('No data points yet'));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= orderedDates.length) {
                          return const SizedBox.shrink();
                        }
                        final dateLabel = DateFormat('MM/dd')
                            .format(orderedDates[index]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateLabel,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: updatedSeries
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
              children: updatedSeries
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
