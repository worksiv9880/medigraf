import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';

void showChartEntryDialog(
  BuildContext context,
  WidgetRef ref, {
  int? initialParticipantId,
  Metric? initialMetric,
}) {
  showDialog(
    context: context,
    builder: (_) => ChartEntryDialog(
      initialParticipantId: initialParticipantId,
      initialMetric: initialMetric,
    ),
  );
}

class ChartEntryDialog extends ConsumerStatefulWidget {
  const ChartEntryDialog({
    super.key,
    this.initialParticipantId,
    this.initialMetric,
  });

  final int? initialParticipantId;
  final Metric? initialMetric;

  @override
  ConsumerState<ChartEntryDialog> createState() => _ChartEntryDialogState();
}

class _ChartEntryDialogState extends ConsumerState<ChartEntryDialog> {
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedParticipantId;
  int? _selectedMetricId;

  @override
  void initState() {
    super.initState();
    _selectedParticipantId = widget.initialParticipantId;
    _selectedMetricId = widget.initialMetric?.id;
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _unitController.dispose();
    _valueController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    });
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(participantsProvider);

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Health Parameter')),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: participantsAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => SizedBox(
          height: 120,
          child: Center(child: Text('Error: $error')),
        ),
        data: (participants) {
          if (participants.isEmpty) {
            return const Text('Add a participant to start tracking metrics.');
          }

          final activeParticipantId =
              _selectedParticipantId ?? participants.first.id;
          final metricsAsync = ref.watch(metricsProvider(activeParticipantId));
          final metrics = metricsAsync.maybeWhen(
            data: (metrics) => metrics,
            orElse: () => const <Metric>[],
          );

          Metric? selectedMetric;
          for (final metric in metrics) {
            if (metric.id == _selectedMetricId) {
              selectedMetric = metric;
              break;
            }
          }

          if (selectedMetric == null && _selectedMetricId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _selectedMetricId = null);
              }
            });
          }

          final isCustomMetric = selectedMetric == null;
          if (!isCustomMetric) {
            _unitController.text = selectedMetric.unit;
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record a new health measurement or vital sign.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: activeParticipantId,
                  decoration: const InputDecoration(labelText: 'Profile'),
                  items: participants
                      .map(
                        (participant) => DropdownMenuItem(
                          value: participant.id,
                          child: Text(
                            '${participant.emoji} ${participant.name}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedParticipantId = value;
                      _selectedMetricId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  value: _selectedMetricId,
                  decoration:
                      const InputDecoration(labelText: 'Parameter Type'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Custom Parameter'),
                    ),
                    ...metrics.map(
                      (metric) => DropdownMenuItem<int?>(
                        value: metric.id,
                        child: Text('${metric.name} (${metric.unit})'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMetricId = value;
                    });
                  },
                ),
                if (isCustomMetric) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _customNameController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Parameter Name',
                      hintText: 'e.g., Oxygen Saturation',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _valueController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'e.g., 120',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _unitController,
                  readOnly: !isCustomMetric,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    hintText: 'e.g., mmHg, mg/dL, bpm',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final participants = participantsAsync.value;
            if (participants == null || participants.isEmpty) {
              _showValidationMessage('Please add a participant first.');
              return;
            }

            final participantId =
                _selectedParticipantId ?? participants.first.id;
            final metrics = ref
                .read(metricsProvider(participantId))
                .valueOrNull ??
                const <Metric>[];

            Metric? selectedMetric;
            for (final metric in metrics) {
              if (metric.id == _selectedMetricId) {
                selectedMetric = metric;
                break;
              }
            }

            final isCustomMetric = selectedMetric == null;
            final valueText = _valueController.text.trim();
            final value = double.tryParse(valueText);
            if (value == null) {
              _showValidationMessage('Please enter a valid value.');
              return;
            }

            final db = ref.read(databaseProvider);
            int metricId;
            if (isCustomMetric) {
              final name = _customNameController.text.trim();
              final unit = _unitController.text.trim();
              if (name.isEmpty || unit.isEmpty) {
                _showValidationMessage(
                  'Please enter a custom parameter name and unit.',
                );
                return;
              }

              metricId = await db.addMetric(
                MetricsCompanion(
                  participantId: drift.Value(participantId),
                  name: drift.Value(name),
                  unit: drift.Value(unit),
                ),
              );
            } else {
              metricId = selectedMetric.id;
            }

            await db.addDataPoint(
              MetricDataPointsCompanion(
                metricId: drift.Value(metricId),
                value: drift.Value(value),
                recordedAt: drift.Value(_selectedDate),
              ),
            );

            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Parameter'),
        ),
      ],
    );
  }
}
