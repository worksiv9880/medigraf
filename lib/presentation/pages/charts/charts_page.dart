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
                    Text(
                      '${parameter.name} (${parameter.unit})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: MetricChart(
                        metrics: selectedMetrics,
                        participants: selectedParticipantDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
