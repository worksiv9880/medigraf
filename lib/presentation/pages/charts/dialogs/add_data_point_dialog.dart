import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';

void showAddDataPointDialog(
  BuildContext context,
  WidgetRef ref,
  Metric metric,
) {
  final valueController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Add ${metric.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Value (${metric.unit})'),
            ),
            ListTile(
              title: Text(DateFormat.yMMMd().format(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
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
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(valueController.text);
              if (value == null) return;

              final db = ref.read(databaseProvider);
              await db.addDataPoint(
                MetricDataPointsCompanion(
                  metricId: drift.Value(metric.id),
                  value: drift.Value(value),
                  recordedAt: drift.Value(selectedDate),
                ),
              );

              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}
