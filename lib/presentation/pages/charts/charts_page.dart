import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../widgets/app_header/app_header.dart';
import 'widgets/empty_metrics_view.dart';
import 'widgets/metric_chart.dart';
import 'dialogs/health_parameter_sheet.dart';
import '../../widgets/participant_filter/participant_filter.dart';
import 'models/chart_parameter.dart';
import '../../../data/datasources/local/app_database.dart';
import 'utils/chart_colors.dart';

class ChartsPage extends ConsumerWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParticipants = ref.watch(selectedParticipantsProvider);

    if (selectedParticipants.isEmpty) {
      return Scaffold(
        appBar: const AppHeader(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ParticipantFilter(),
              Expanded(
                child: Center(
                  child: Text(
                    'Please select a participant from the calendar',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          const ParticipantFilter(),
          Expanded(
            child: _MetricsBody(
              selectedParticipants: selectedParticipants.toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showHealthParameterSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MetricsBody extends ConsumerStatefulWidget {
  final List<int> selectedParticipants;

  const _MetricsBody({
    required this.selectedParticipants,
  });

  @override
  ConsumerState<_MetricsBody> createState() => _MetricsBodyState();
}

class _MetricsBodyState extends ConsumerState<_MetricsBody> {
  Future<void> _confirmDeleteChart({
    required BuildContext context,
    required List<Metric> metrics,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete chart'),
        content: const Text(
          'Are you sure you want to delete this chart? '
          'All information will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final db = ref.read(databaseProvider);
    for (final metric in metrics) {
      await db.deleteMetric(metric.id);
    }
  }

  Future<void> _deleteParticipantMetric({
    required BuildContext context,
    required Metric metric,
    required Participant participant,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete metric'),
        content: Text(
          'Delete ${metric.name} for ${participant.emoji} ${participant.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final db = ref.read(databaseProvider);
    await db.deleteMetric(metric.id);
  }

  Widget _buildParticipantMetricRow({
    required Participant participant,
    required Metric metric,
    required int colorIndex,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: chartColors[colorIndex % chartColors.length],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${participant.emoji} ${participant.name}',
          style: const TextStyle(fontSize: 12),
        ),
        IconButton(
          tooltip: 'Delete metric',
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () => _deleteParticipantMetric(
            context: context,
            metric: metric,
            participant: participant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedParticipants = widget.selectedParticipants;
    final participantsAsync = ref.watch(participantsProvider);
    final metricsAsyncList = selectedParticipants
        .map<AsyncValue<List<Metric>>>(
          (participantId) => ref.watch(metricsProvider(participantId)),
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
    final parameters = _buildParameters(metrics);

    return participantsAsync.when(
      data: (participants) {
        final selectedParticipantDetails = participants
            .where((participant) =>
                selectedParticipants.contains(participant.id))
            .toList();

        if (parameters.isEmpty) {
          return EmptyMetricsView(
            onAddParameter: () => showHealthParameterSheet(context, ref),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: parameters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final parameter = parameters[index];
            final selectedMetrics = metrics
                .where(
                  (metric) =>
                      metric.name.toLowerCase() ==
                          parameter.name.toLowerCase() &&
                      metric.unit.toLowerCase() ==
                          parameter.unit.toLowerCase(),
                )
                .toList();
            final participantMetricRows = selectedMetrics
                .map((metric) {
                  final participantIndex = selectedParticipantDetails.indexWhere(
                    (participant) => participant.id == metric.participantId,
                  );
                  if (participantIndex == -1) return null;
                  return _buildParticipantMetricRow(
                    participant: selectedParticipantDetails[participantIndex],
                    metric: metric,
                    colorIndex: participantIndex,
                  );
                })
                .whereType<Widget>()
                .toList();

            return Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${parameter.name} (${parameter.unit})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete chart',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteChart(
                            context: context,
                            metrics: selectedMetrics,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: MetricChart(
                        metrics: selectedMetrics,
                        participants: selectedParticipantDetails,
                      ),
                    ),
                    if (participantMetricRows.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: participantMetricRows,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

List<ChartParameter> _buildParameters(List<Metric> metrics) {
  final parameters = <ChartParameter>{};

  for (final metric in metrics) {
    parameters.add(ChartParameter(name: metric.name, unit: metric.unit));
  }

  return parameters.toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
