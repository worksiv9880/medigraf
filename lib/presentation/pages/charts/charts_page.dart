import 'package:drift/drift.dart' as drift;
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
import 'utils/chart_helpers.dart';

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
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          onPressed: () => showHealthParameterSheet(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
  final Map<ChartParameter, ChartRange> _rangeByParameter = {};

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

  Future<void> _showMetricPointsDialog({
    required BuildContext context,
    required Metric metric,
    required Participant participant,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '${participant.emoji} ${participant.name} - ${metric.name}',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, ref, _) {
              final pointsAsync =
                  ref.watch(metricDataPointsProvider(metric.id));
              return pointsAsync.when(
                data: (points) {
                  if (points.isEmpty) {
                    return const Text('No values recorded yet.');
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: points.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final point = points[index];
                      return ListTile(
                        title: Text(point.value.toStringAsFixed(1)),
                        subtitle: Text(
                          '${point.recordedAt.day.toString().padLeft(2, '0')}/'
                          '${point.recordedAt.month.toString().padLeft(2, '0')}/'
                          '${point.recordedAt.year}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete value',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final db = ref.read(databaseProvider);
                            await db.deleteDataPoint(point.id);
                            final remaining =
                                await db.getDataPointsForMetric(metric.id);
                            final shouldDeleteMetric = remaining.isEmpty;
                            if (!context.mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.clearSnackBars();
                            messenger
                                .showSnackBar(
                                  SnackBar(
                                    content: const Text('Value deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () async {
                                        await db.addDataPoint(
                                          MetricDataPointsCompanion(
                                            metricId:
                                                drift.Value(metric.id),
                                            value: drift.Value(point.value),
                                            recordedAt:
                                                drift.Value(point.recordedAt),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .closed
                                .then((reason) async {
                              if (reason == SnackBarClosedReason.action) {
                                return;
                              }
                              if (shouldDeleteMetric) {
                                await db.deleteMetric(metric.id);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantMetricRow({
    required Participant participant,
    required Metric metric,
    required int colorIndex,
  }) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
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
          style: textStyle,
        ),
        IconButton(
          tooltip: 'Manage values',
          icon: const Icon(Icons.tune, size: 18),
          onPressed: () => _showMetricPointsDialog(
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
    final parameters = buildParameters(metrics);

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: parameters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final parameter = parameters[index];
            final range = _rangeByParameter[parameter] ?? ChartRange.all;
            final selectedMetrics = metrics
                .where(
                  (metric) =>
                      metric.name.trim().toLowerCase() ==
                          parameter.normalizedName &&
                      metric.unit.trim().toLowerCase() ==
                          parameter.normalizedUnit,
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

            final cardHeight = (MediaQuery.sizeOf(context).height * 0.35)
                .clamp(260.0, 420.0);

            return Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                        Flexible(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: ChartRange.values
                                .map(
                                  (option) => ChoiceChip(
                                    label: Text(option.label),
                                    selected: range == option,
                                    onSelected: (_) {
                                      setState(() {
                                        _rangeByParameter[parameter] = option;
                                      });
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
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
                      height: cardHeight,
                      child: MetricChart(
                        metrics: selectedMetrics,
                        participants: selectedParticipantDetails,
                        unit: parameter.unit,
                        range: range,
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
