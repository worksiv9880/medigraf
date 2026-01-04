import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../widgets/app_header/app_header.dart';
import '../../../data/datasources/local/app_database.dart';

import 'state/charts_state.dart';
import 'widgets/charts_app_bar.dart';
import 'widgets/day_selector.dart';
import 'widgets/metric_legend.dart';
import 'widgets/empty_metrics_view.dart';
import 'widgets/metric_chart.dart';
import 'dialogs/add_metric_dialog.dart';
import 'dialogs/add_data_point_dialog.dart';
import '../../widgets/participant_filter/participant_filter.dart';

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

    final metricsAsync = ref.watch(metricsProvider(selectedParticipants.first));

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
            child: metricsAsync.when(
              data: (metrics) {
                if (metrics.isEmpty) {
                  return EmptyMetricsView(
                    onAddMetric: () => showAddMetricDialog(context, ref),
                  );
                }

                _state.selectedMetric ??= metrics.first;

                return Column(
                  children: [
                    DaySelector(days: _state.selectedDays),
                    Expanded(
                      child: MetricChart(
                        metric: _state.selectedMetric!,
                        days: _state.selectedDays,
                      ),
                    ),
                    MetricLegend(
                      metrics: metrics,
                      selectedMetric: _state.selectedMetric!,
                      onSelected: (metric) {
                        setState(() => _state.selectedMetric = metric);
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_metric',
            onPressed: () => showAddMetricDialog(context, ref),
            child: const Icon(Icons.add_chart),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add_data',
            onPressed: _state.selectedMetric == null
                ? null
                : () => showAddDataPointDialog(
                      context,
                      ref,
                      _state.selectedMetric!,
                    ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
