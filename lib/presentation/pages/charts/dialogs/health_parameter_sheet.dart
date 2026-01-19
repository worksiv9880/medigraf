import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';
import '../models/chart_parameter.dart';
import '../utils/chart_helpers.dart';

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
  final List<_ValueEntry> _valueEntries = [
    _ValueEntry(
      controller: TextEditingController(),
      date: DateTime.now(),
    ),
  ];
  final _unitController = TextEditingController();
  final _valueInputFormatter = _DecimalInputFormatter();

  _ParameterMode _mode = _ParameterMode.custom;
  Participant? _selectedParticipant;
  ChartParameter? _selectedParameter;
  bool _isSaving = false;
  List<Metric> _cachedMetrics = [];

  @override
  void dispose() {
    _customNameController.dispose();
    for (final entry in _valueEntries) {
      entry.controller.dispose();
    }
    _unitController.dispose();
    super.dispose();
  }

  void _syncDefaults({
    required List<Participant> participants,
    required List<ChartParameter> parameters,
  }) {
    Participant? nextParticipant = _selectedParticipant;
    ChartParameter? nextParameter = _selectedParameter;

    if (nextParticipant == null && participants.isNotEmpty) {
      nextParticipant = participants.first;
    }

    if (_mode == _ParameterMode.existing &&
        nextParameter == null &&
        parameters.isNotEmpty) {
      nextParameter = parameters.first;
    }

    final shouldUpdate = nextParticipant != _selectedParticipant ||
        nextParameter != _selectedParameter ||
        (_mode == _ParameterMode.existing &&
            nextParameter != null &&
            _unitController.text != nextParameter.unit);

    if (shouldUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedParticipant = nextParticipant;
          _selectedParameter = nextParameter;
          if (_mode == _ParameterMode.existing && nextParameter != null) {
            _unitController.text = nextParameter.unit;
          }
        });
      });
    }
  }

  Future<DateTime?> _pickDate(DateTime initialDate) {
    final formatter = DateFormat('dd/MM/yyyy');
    var selectedDate = initialDate;
    final controller = TextEditingController();

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select date'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      onDateChanged: (date) {
                        setDialogState(() {
                          selectedDate = date;
                          controller.text = formatter.format(date);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _DateInputFormatter(),
                      ],
                      decoration: const InputDecoration(hintText: 'dd/mm/yyyy'),
                      onChanged: (value) {
                        if (value.length != 10) return;
                        try {
                          final parsed = formatter.parseStrict(value);
                          if (parsed.isBefore(DateTime(2020)) ||
                              parsed.isAfter(DateTime.now())) {
                            return;
                          }
                          setDialogState(() {
                            selectedDate = parsed;
                          });
                        } catch (_) {}
                      },
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedDate),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    final participant = _selectedParticipant;
    if (participant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile.')),
      );
      return;
    }

    final values = _valueEntries
        .map((entry) => entry.controller.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid value.')),
      );
      return;
    }
    final parsedValues = values
        .map((value) => double.tryParse(value.replaceAll(',', '.')))
        .toList(growable: false);
    if (parsedValues.any((value) => value == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values.')),
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
    } else if (_selectedParameter == null) {
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
        final customName = _customNameController.text.trim();
        final customUnit = _unitController.text.trim();
        final existingMetric = findMatchingMetric(
          metrics: _cachedMetrics,
          participantId: participant.id,
          name: customName,
          unit: customUnit,
        );
        metricId = existingMetric?.id ??
            await db.addMetric(
              MetricsCompanion(
                participantId: drift.Value(participant.id),
                name: drift.Value(customName),
                unit: drift.Value(customUnit),
              ),
            );
      } else {
        final selectedParameter = _selectedParameter!;
        final existingMetric = findMatchingMetric(
          metrics: _cachedMetrics,
          participantId: participant.id,
          name: selectedParameter.name,
          unit: selectedParameter.unit,
        );
        metricId = existingMetric?.id ??
            await db.addMetric(
              MetricsCompanion(
                participantId: drift.Value(participant.id),
                name: drift.Value(selectedParameter.name),
                unit: drift.Value(selectedParameter.unit),
              ),
            );
      }

      for (final entry in _valueEntries) {
        final parsedValue = double.tryParse(
          entry.controller.text.trim().replaceAll(',', '.'),
        );
        if (parsedValue == null) continue;
        await db.addDataPoint(
          MetricDataPointsCompanion(
            metricId: drift.Value(metricId),
            value: drift.Value(parsedValue),
            recordedAt: drift.Value(entry.date),
          ),
        );
      }

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
                final metricsAsyncList = participants
                    .map<AsyncValue<List<Metric>>>(
                      (participant) =>
                          ref.watch(metricsProvider(participant.id)),
                    )
                    .toList();

                if (metricsAsyncList.any((value) => value.isLoading)) {
                  return const Center(child: CircularProgressIndicator());
                }

                final errorValue = metricsAsyncList
                    .cast<AsyncValue<List<Metric>>>()
                    .firstWhere(
                      (value) => value.hasError,
                      orElse: () => const AsyncValue<List<Metric>>.data([]),
                    );
                if (errorValue.hasError) {
                  return Center(child: Text('Error: ${errorValue.error}'));
                }

                final metrics = metricsAsyncList
                    .expand((value) => value.value ?? <Metric>[])
                    .toList();
                final parameters = buildParameters(metrics);
                _cachedMetrics = metrics;

                _syncDefaults(
                  participants: participants,
                  parameters: parameters,
                );

                final valueHint = _mode == _ParameterMode.custom
                    ? 'e.g., 120'
                    : 'e.g., 120 ${_unitController.text}'.trim();

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
                              _selectedParameter = null;
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
                                _selectedParameter = null;
                              }
                            });
                          },
                        ),
                      ),
                      if (_mode == _ParameterMode.existing)
                        _Section(
                          title: 'Parameter',
                          child: DropdownButtonFormField<ChartParameter>(
                            value: _selectedParameter,
                            decoration: const InputDecoration(
                              hintText: 'Select parameter',
                            ),
                            items: parameters
                                .map(
                                  (parameter) => DropdownMenuItem(
                                    value: parameter,
                                    child: Text(
                                      '${parameter.name} (${parameter.unit})',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (parameter) {
                              setState(() {
                                _selectedParameter = parameter;
                                _unitController.text = parameter?.unit ?? '';
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
                        child: Column(
                          children: [
                            ..._valueEntries.asMap().entries.map((entry) {
                              final index = entry.key;
                              final valueEntry = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: valueEntry.controller,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: [
                                          _valueInputFormatter,
                                        ],
                                        decoration: InputDecoration(
                                          hintText: valueHint,
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Select date',
                                      icon: const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                      ),
                                      onPressed: () async {
                                        final picked =
                                            await _pickDate(valueEntry.date);
                                        if (picked != null) {
                                          setState(() {
                                            _valueEntries[index] =
                                                valueEntry.copyWith(
                                              date: picked,
                                            );
                                          });
                                        }
                                      },
                                    ),
                                    if (_valueEntries.length > 1)
                                      IconButton(
                                        tooltip: 'Remove value',
                                        icon: const Icon(Icons.close, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            final removed =
                                                _valueEntries.removeAt(index);
                                            removed.controller.dispose();
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _valueEntries.add(
                                      _ValueEntry(
                                        controller: TextEditingController(),
                                        date: DateTime.now(),
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add another value'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_mode == _ParameterMode.custom)
                        _Section(
                          title: 'Unit',
                          child: TextField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., mmHg, mg/dL, bpm',
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

class _ValueEntry {
  final TextEditingController controller;
  final DateTime date;

  const _ValueEntry({
    required this.controller,
    required this.date,
  });

  _ValueEntry copyWith({
    TextEditingController? controller,
    DateTime? date,
  }) {
    return _ValueEntry(
      controller: controller ?? this.controller,
      date: date ?? this.date,
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 8; i++) {
      buffer.write(digits[i]);
      if (i == 1 || i == 3) {
        buffer.write('/');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = newValue.text.replaceAll(RegExp(r'[^0-9,\\.]'), '');
    final buffer = StringBuffer();
    var hasSeparator = false;
    for (final char in sanitized.split('')) {
      if (char == '.' || char == ',') {
        if (hasSeparator) continue;
        hasSeparator = true;
        buffer.write(char);
      } else {
        buffer.write(char);
      }
    }
    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
