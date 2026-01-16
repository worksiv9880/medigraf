import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/di/providers.dart';
import 'package:intl/intl.dart';

import '../../../../data/datasources/local/app_database.dart';
import '../utils/coordinate_grid.dart';
import '../utils/chart_colors.dart';
import '../utils/chart_helpers.dart';

class MetricChart extends ConsumerWidget {
  final List<Metric> metrics;
  final List<Participant> participants;
  final String unit;
  final ChartRange range;

  const MetricChart({
    super.key,
    required this.metrics,
    required this.participants,
    required this.unit,
    required this.range,
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
    double? minY;
    double? maxY;
    DateTime? latestDate;

    DateTime _truncateDate(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    DateTime? _rangeStart() {
      final rangeDays = range.days;
      if (rangeDays == null || latestDate == null) return null;
      final latestDay = _truncateDate(latestDate!);
      return latestDay.subtract(Duration(days: rangeDays - 1));
    }

    for (var index = 0; index < metrics.length; index++) {
      final metricModel = metrics[index];
      final points = dataAsyncList[index].value ?? [];
      final participantIndex = participants.indexWhere(
        (participant) => participant.id == metricModel.participantId,
      );
      if (participantIndex == -1 || points.isEmpty) continue;

      for (final point in points) {
        latestDate = latestDate == null
            ? point.recordedAt
            : (point.recordedAt.isAfter(latestDate!)
                ? point.recordedAt
                : latestDate);
      }
    }

    final rangeStart = _rangeStart();

    for (var index = 0; index < metrics.length; index++) {
      final metricModel = metrics[index];
      final points = dataAsyncList[index].value ?? [];
      final participantIndex = participants.indexWhere(
        (participant) => participant.id == metricModel.participantId,
      );
      if (participantIndex == -1 || points.isEmpty) continue;

      for (final point in points) {
        if (rangeStart != null) {
          final day = _truncateDate(point.recordedAt);
          if (day.isBefore(rangeStart)) continue;
        }
        final day = _truncateDate(point.recordedAt);
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
          .where((point) {
            if (rangeStart == null) return true;
            final day = _truncateDate(point.recordedAt);
            return day.isAtSameMomentAs(rangeStart) || day.isAfter(rangeStart);
          })
          .map((point) {
            final day = _truncateDate(point.recordedAt);
            final x = dateIndex[day];
            if (x == null) return null;
            minY = minY == null
                ? point.value
                : (point.value < minY! ? point.value : minY);
            maxY = maxY == null
                ? point.value
                : (point.value > maxY! ? point.value : maxY);
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

    final minValue = minY ?? 0;
    final maxValue = maxY ?? minValue + 1;
    final valueRange = (maxValue - minValue).abs();
    final yInterval = valueRange <= 10
        ? 1.0
        : valueRange <= 50
            ? 5.0
            : 10.0;
    // Skip labels when there are too many points to avoid overcrowding.
    final labelStep =
        orderedDates.length <= 6 ? 1 : (orderedDates.length / 6).ceil();
    final minX = 0.0;
    final maxX = (orderedDates.length - 1).toDouble();
    final padding = (valueRange * 0.1).clamp(1, double.infinity);
    final minChartY = minValue - padding;
    final maxChartY = maxValue + padding;
    final grid = CoordinateGrid(
      horizontalInterval: yInterval,
      verticalInterval: labelStep.toDouble(),
      lineColor: Theme.of(context).colorScheme.outlineVariant,
      lineWidth: 0.8,
    );
    final axisLabelColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final unitLabel = unit.trim().isEmpty ? '' : ' ${unit.trim()}';

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minChartY,
        maxY: maxChartY,
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        gridData: grid.toGridData(),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = index >= 0 && index < orderedDates.length
                    ? orderedDates[index]
                    : null;
                final dateLabel =
                    date == null ? '' : dateFormatter.format(date);
                return LineTooltipItem(
                  '$dateLabel\n${spot.y.toStringAsFixed(1)}$unitLabel',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              final indicatorColor =
                  (barData.color ?? axisLabelColor).withOpacity(0.4);
              return TouchedSpotIndicatorData(
                FlLine(color: indicatorColor, strokeWidth: 1),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: barData.color ?? axisLabelColor,
                      strokeWidth: 2,
                      strokeColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                final displayValue = value % 1 == 0
                    ? value.toInt().toString()
                    : value.toStringAsFixed(1);
                return Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 11,
                    color: axisLabelColor,
                  ),
                );
              },
            ),
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
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= orderedDates.length) {
                  return const SizedBox.shrink();
                }
                if (labelStep > 1 &&
                    index % labelStep != 0 &&
                    index != orderedDates.length - 1) {
                  return const SizedBox.shrink();
                }
                final dateLabel = dateFormatter.format(orderedDates[index]);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Text(
                      dateLabel,
                      style: TextStyle(fontSize: 10, color: axisLabelColor),
                    ),
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
                dotData: const FlDotData(show: false),
              ),
            )
            .toList(),
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
