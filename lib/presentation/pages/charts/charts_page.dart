import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../widgets/app_header/app_header.dart';
import 'state/charts_state.dart';
import 'widgets/charts_app_bar.dart';
import 'widgets/day_selector.dart';
import 'widgets/metric_legend.dart';
import 'widgets/empty_metrics_view.dart';
import 'widgets/metric_chart.dart';
import 'dialogs/health_parameter_sheet.dart';
import '../../widgets/participant_filter/participant_filter.dart';
import 'models/chart_parameter.dart';
import '../../../data/datasources/local/app_database.dart';

class ChartsPage extends ConsumerStatefulWidget {
  const ChartsPage({super.key});

  @override
  ConsumerState<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends ConsumerState<ChartsPage> {
  final ChartsState _state = ChartsState();

  @override
  Widget build(BuildContext context) {
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
          ChartsAppBar(
            selectedDays: _state.selectedDays,
            onDaysChanged: (days) {
              setState(() => _state.selectedDays = days);
            },
          ),
          Expanded(
            child: _MetricsBody(
              selectedParticipants: selectedParticipants.toList(),
              state: _state,
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
  final ChartsState state;

  const _MetricsBody({
    required this.selectedParticipants,
    required this.state,
  });

  @override
  ConsumerState<_MetricsBody> createState() => _MetricsBodyState();
}

class _MetricsBodyState extends ConsumerState<_MetricsBody> {
  @override
  Widget build(BuildContext context) {
    final selectedParticipants = widget.selectedParticipants;
    final state = widget.state;
    final participantsAsync = ref.watch(participantsProvider);
    final metricsAsyncList = selectedParticipants
        .map((participantId) => ref.watch(metricsProvider(participantId)))
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

    final metrics =
        metricsAsyncList.expand((value) => value.value ?? []).toList();
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

        if (state.selectedMetric == null ||
            !parameters.contains(state.selectedMetric)) {
          state.selectedMetric = parameters.first;
        }

        final selectedParameter = state.selectedMetric!;
        final selectedMetrics = metrics
            .where(
              (metric) =>
                  metric.name.toLowerCase() ==
                      selectedParameter.name.toLowerCase() &&
                  metric.unit.toLowerCase() ==
                      selectedParameter.unit.toLowerCase(),
            )
            .toList();

        return Column(
          children: [
            DaySelector(days: state.selectedDays),
            Expanded(
              child: MetricChart(
                metric: selectedParameter,
                metrics: selectedMetrics,
                participants: selectedParticipantDetails,
                days: state.selectedDays,
              ),
            ),
            MetricLegend(
              metrics: parameters,
              selectedMetric: selectedParameter,
              onSelected: (metric) {
                setState(() => state.selectedMetric = metric);
              },
            ),
          ],
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
