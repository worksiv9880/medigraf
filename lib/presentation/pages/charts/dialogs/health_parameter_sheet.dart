import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';

enum _ParameterMode { custom, existing }

Future<void> showHealthParameterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _HealthParameterSheet(),
  );
}

class _HealthParameterSheet extends ConsumerStatefulWidget {
  const _HealthParameterSheet();

  @override
  ConsumerState<_HealthParameterSheet> createState() =>
      _HealthParameterSheetState();
}

class _HealthParameterSheetState extends ConsumerState<_HealthParameterSheet> {
  final _customNameController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();

  _ParameterMode _mode = _ParameterMode.custom;
  Participant? _selectedParticipant;
  Metric? _selectedMetric;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _customNameController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _syncDefaults({
    required List<Participant> participants,
    required List<Metric> metrics,
  }) {
    Participant? nextParticipant = _selectedParticipant;
    Metric? nextMetric = _selectedMetric;

    if (nextParticipant == null && participants.isNotEmpty) {
      nextParticipant = participants.first;
    }

    if (_mode == _ParameterMode.existing &&
        nextMetric == null &&
        metrics.isNotEmpty) {
      nextMetric = metrics.first;
    }

    final shouldUpdate = nextParticipant != _selectedParticipant ||
        nextMetric != _selectedMetric ||
        (_mode == _ParameterMode.existing &&
            nextMetric != null &&
            _unitController.text != nextMetric.unit);

    if (shouldUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedParticipant = nextParticipant;
          _selectedMetric = nextMetric;
          if (_mode == _ParameterMode.existing && nextMetric != null) {
            _unitController.text = nextMetric.unit;
          }
        });
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final participant = _selectedParticipant;
    if (participant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile.')),
      );
      return;
    }

    final value = double.tryParse(_valueController.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid value.')),
      );
      return;
    }

    if (_mode == _ParameterMode.custom) {
      if (_customNameController.text.trim().isEmpty ||
          _unitController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
        return;
      }
    } else if (_selectedMetric == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a parameter.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final db = ref.read(databaseProvider);
      int metricId;

      if (_mode == _ParameterMode.custom) {
        metricId = await db.addMetric(
          MetricsCompanion(
            participantId: drift.Value(participant.id),
            name: drift.Value(_customNameController.text.trim()),
            unit: drift.Value(_unitController.text.trim()),
          ),
        );
      } else {
        metricId = _selectedMetric!.id;
      }

      await db.addDataPoint(
        MetricDataPointsCompanion(
          metricId: drift.Value(metricId),
          value: drift.Value(value),
          recordedAt: drift.Value(_selectedDate),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(participantsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 40),
                const Expanded(
                  child: Text(
                    'Health Parameter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Record a new health measurement or vital sign.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: participantsAsync.when(
              data: (participants) {
                final metricsAsync = _selectedParticipant == null
                    ? const AsyncValue<List<Metric>>.data([])
                    : ref.watch(metricsProvider(_selectedParticipant!.id));

                return metricsAsync.when(
                  data: (metrics) {
                    _syncDefaults(participants: participants, metrics: metrics);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Section(
                            title: 'Profile',
                            child: DropdownButtonFormField<Participant>(
                              value: _selectedParticipant,
                              decoration: const InputDecoration(
                                hintText: 'Select profile',
                              ),
                              items: participants
                                  .map(
                                    (participant) => DropdownMenuItem(
                                      value: participant,
                                      child: Text(
                                        '${participant.emoji} ${participant.name}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (participant) {
                                setState(() {
                                  _selectedParticipant = participant;
                                  _selectedMetric = null;
                                  _unitController.clear();
                                });
                              },
                            ),
                          ),
                          _Section(
                            title: 'Parameter Type',
                            child: DropdownButtonFormField<_ParameterMode>(
                              value: _mode,
                              decoration:
                                  const InputDecoration(hintText: 'Select type'),
                              items: const [
                                DropdownMenuItem(
                                  value: _ParameterMode.custom,
                                  child: Text('Custom Parameter'),
                                ),
                                DropdownMenuItem(
                                  value: _ParameterMode.existing,
                                  child: Text('Existing Parameter'),
                                ),
                              ],
                              onChanged: (mode) {
                                if (mode == null) return;
                                setState(() {
                                  _mode = mode;
                                  if (_mode == _ParameterMode.custom) {
                                    _selectedMetric = null;
                                  }
                                });
                              },
                            ),
                          ),
                          if (_mode == _ParameterMode.existing)
                            _Section(
                              title: 'Parameter',
                              child: DropdownButtonFormField<Metric>(
                                value: _selectedMetric,
                                decoration: const InputDecoration(
                                  hintText: 'Select parameter',
                                ),
                                items: metrics
                                    .map(
                                      (metric) => DropdownMenuItem(
                                        value: metric,
                                        child: Text(
                                          '${metric.name} (${metric.unit})',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (metric) {
                                  setState(() {
                                    _selectedMetric = metric;
                                    _unitController.text = metric?.unit ?? '';
                                  });
                                },
                              ),
                            ),
                          if (_mode == _ParameterMode.custom)
                            _Section(
                              title: 'Custom Parameter Name',
                              child: TextField(
                                controller: _customNameController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g., Oxygen Saturation',
                                ),
                              ),
                            ),
                          _Section(
                            title: 'Value',
                            child: TextField(
                              controller: _valueController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'e.g., 120',
                              ),
                            ),
                          ),
                          _Section(
                            title: 'Unit',
                            child: TextField(
                              controller: _unitController,
                              enabled: _mode == _ParameterMode.custom,
                              decoration: const InputDecoration(
                                hintText: 'e.g., mmHg, mg/dL, bpm',
                              ),
                            ),
                          ),
                          _Section(
                            title: 'Date',
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(_selectedDate),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _isSaving ? null : _save,
                                  icon: const Icon(Icons.favorite_border),
                                  label: Text(
                                    _isSaving ? 'Saving...' : 'Add Parameter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
