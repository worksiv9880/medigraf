import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddChartValueSheet extends StatefulWidget {
  const AddChartValueSheet({
    super.key,
    required this.onSubmit,
    this.onCancel,
    this.initialProfile,
    this.initialParameterType = 'Custom Parameter',
  });

  final ValueChanged<ChartValueDraft> onSubmit;
  final VoidCallback? onCancel;
  final String? initialProfile;
  final String initialParameterType;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<ChartValueDraft> onSubmit,
    VoidCallback? onCancel,
    String? initialProfile,
    String initialParameterType = 'Custom Parameter',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddChartValueSheet(
        onSubmit: onSubmit,
        onCancel: onCancel,
        initialProfile: initialProfile,
        initialParameterType: initialParameterType,
      ),
    );
  }

  @override
  State<AddChartValueSheet> createState() => _AddChartValueSheetState();
}

class _AddChartValueSheetState extends State<AddChartValueSheet> {
  static const _accentColor = Color(0xFFFF2D86);

  final _customParameterController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _dateController = TextEditingController();

  late String _selectedProfile;
  late String _selectedParameterType;
  DateTime _selectedDate = DateTime.now();

  final List<String> _profiles = ['John Doe', 'Jane Doe', 'Child 1'];
  final List<String> _parameterTypes = [
    'Custom Parameter',
    'Blood Pressure',
    'Heart Rate',
    'Glucose',
    'Weight',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProfile = widget.initialProfile ?? _profiles.first;
    _selectedParameterType = widget.initialParameterType;
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _customParameterController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submit() {
    widget.onSubmit(
      ChartValueDraft(
        profile: _selectedProfile,
        parameterType: _selectedParameterType,
        customParameterName: _customParameterController.text.trim(),
        value: _valueController.text.trim(),
        unit: _unitController.text.trim(),
        recordedAt: _selectedDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Parameter',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Record a new health measurement or vital sign.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedProfile,
              items: _profiles
                  .map((profile) => DropdownMenuItem(
                        value: profile,
                        child: Text(profile),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedProfile = value);
              },
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 16),
            Text(
              'Parameter Type',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedParameterType,
              items: _parameterTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedParameterType = value);
              },
              decoration: const InputDecoration(),
            ),
            if (_selectedParameterType == 'Custom Parameter') ...[
              const SizedBox(height: 16),
              Text(
                'Custom Parameter Name',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customParameterController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Oxygen Saturation',
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Value',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g., 120',
                suffixIcon: Icon(Icons.bar_chart),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unit',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                hintText: 'e.g., mmHg, mg/dL, bpm',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Date',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onCancel?.call();
                      Navigator.of(context).maybePop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submit,
                    child: const Text('Add Parameter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChartValueDraft {
  ChartValueDraft({
    required this.profile,
    required this.parameterType,
    required this.customParameterName,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  final String profile;
  final String parameterType;
  final String customParameterName;
  final String value;
  final String unit;
  final DateTime recordedAt;
}
