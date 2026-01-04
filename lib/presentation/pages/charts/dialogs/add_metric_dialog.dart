import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';

void showAddMetricDialog(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  final unitController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add Metric'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Metric name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: unitController,
            decoration: const InputDecoration(labelText: 'Unit'),
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
            final selectedParticipants = ref.read(selectedParticipantsProvider);
            if (selectedParticipants.isEmpty) return;

            final db = ref.read(databaseProvider);
            await db.addMetric(
              MetricsCompanion(
                participantId: drift.Value(selectedParticipants.first),
                name: drift.Value(nameController.text.trim()),
                unit: drift.Value(unitController.text.trim()),
              ),
            );

            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
