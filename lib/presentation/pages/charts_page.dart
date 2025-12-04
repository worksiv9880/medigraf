import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../../core/di/providers.dart';
import '../../data/datasources/local/app_database.dart';
import '../../core/theme/app_theme.dart';

class ChartsPage extends ConsumerStatefulWidget {
  const ChartsPage({super.key});

  @override
  ConsumerState<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends ConsumerState<ChartsPage> {
  Metric? _selectedMetric;
  int _selectedDays = 7;

  void _showAddMetricDialog() {
    final selectedParticipant = ref.read(selectedParticipantProvider);
    if (selectedParticipant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a participant first')),
      );
      return;
    }

    final nameController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Metric'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Metric Name',
                hintText: 'Weight, Blood Pressure, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'kg, mmHg, etc.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || unitController.text.trim().isEmpty) {
                return;
              }

              final db = ref.read(databaseProvider);
              await db.addMetric(
                MetricsCompanion(
                  participantId: drift.Value(selectedParticipant.id),
                  name: drift.Value(nameController.text.trim()),
                  unit: drift.Value(unitController.text.trim()),
                ),
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddDataPointDialog() {
    if (_selectedMetric == null) return;

    final valueController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => AlertDialog(
          title: Text('Add ${_selectedMetric!.name} Reading'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Value (${_selectedMetric!.unit})',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${DateFormat.yMMMd().format(selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: builderContext,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(valueController.text.trim());
                if (value == null) return;

                final db = ref.read(databaseProvider);
                await db.addDataPoint(
                  MetricDataPointsCompanion(
                    metricId: drift.Value(_selectedMetric!.id),
                    value: drift.Value(value),
                    recordedAt: drift.Value(selectedDate),
                  ),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedParticipant = ref.watch(selectedParticipantProvider);

    if (selectedParticipant == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Graph Building'),
        ),
        body: const Center(
          child: Text('Please select a participant from the calendar'),
        ),
      );
    }

    final metricsAsync = ref.watch(metricsProvider(selectedParticipant.id));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Graph Building'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              setState(() => _selectedDays = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 14, child: Text('Last 14 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
            ],
          ),
        ],
      ),
      body: metricsAsync.when(
        data: (metrics) {
          if (metrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No metrics yet'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _showAddMetricDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Metric'),
                  ),
                ],
              ),
            );
          }

          _selectedMetric ??= metrics.first;

          return Column(
            children: [
              // Day selector
              Container(
                height: 80,
                color: Theme.of(context).cardColor,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _selectedDays,
                  itemBuilder: (context, index) {
                    final day = DateTime.now().subtract(Duration(days: _selectedDays - 1 - index));
                    final isToday = DateUtils.isSameDay(day, DateTime.now());
                    return _buildDayChip(day, isToday);
                  },
                ),
              ),
              
              // Chart
              Expanded(
                child: _selectedMetric != null
                    ? _MetricChart(
                        metric: _selectedMetric!,
                        days: _selectedDays,
                      )
                    : const SizedBox(),
              ),
              
              // Legend
              Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: metrics.take(6).map((metric) {
                    final isSelected = metric.id == _selectedMetric?.id;
                    return _buildLegendItem(
                      metric.name,
                      _getMetricColor(metrics.indexOf(metric)),
                      isSelected,
                      () => setState(() => _selectedMetric = metric),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_metric',
            onPressed: _showAddMetricDialog,
            child: const Icon(Icons.add_chart),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add_data',
            onPressed: _selectedMetric != null ? _showAddDataPointDialog : null,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildDayChip(DateTime day, bool isToday) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.day.toString(),
            style: TextStyle(
              color: isToday ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('dd').format(day) == DateFormat('dd').format(DateTime.now())
                ? '9 dim'
                : '${DateFormat('d').format(day)} dim',
            style: TextStyle(
              color: isToday ? Colors.white70 : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String name, Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(int index) {
    final colors = [
      AppTheme.chartBlue,
      AppTheme.chartOrange,
      AppTheme.chartGreen,
      AppTheme.chartRed,
      AppTheme.chartPurple,
      AppTheme.chartYellow,
    ];
    return colors[index % colors.length];
  }
}

class _MetricChart extends ConsumerWidget {
  final Metric metric;
  final int days;

  const _MetricChart({required this.metric, required this.days});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataPointsAsync = ref.watch(metricDataPointsProvider(metric.id));

    return dataPointsAsync.when(
      data: (dataPoints) {
        if (dataPoints.isEmpty) {
          return const Center(child: Text('No data points yet'));
        }

        // Filter data points for selected time range
        final cutoffDate = DateTime.now().subtract(Duration(days: days));
        final filteredPoints = dataPoints
            .where((p) => p.recordedAt.isAfter(cutoffDate))
            .toList();

        if (filteredPoints.isEmpty) {
          return const Center(child: Text('No data in selected range'));
        }

        final spots = filteredPoints.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.value);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppTheme.chartBlue,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.chartBlue,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.chartBlue.withValues(alpha: 0.3),
                        AppTheme.chartBlue.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              minY: 0,
              maxY: (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}