import '../../../../data/datasources/local/app_database.dart';
import '../models/chart_parameter.dart';

enum ChartRange {
  d7,
  d30,
  d90,
  all,
}

extension ChartRangeX on ChartRange {
  String get label {
    switch (this) {
      case ChartRange.d7:
        return '7d';
      case ChartRange.d30:
        return '30d';
      case ChartRange.d90:
        return '90d';
      case ChartRange.all:
        return 'All';
    }
  }

  int? get days {
    switch (this) {
      case ChartRange.d7:
        return 7;
      case ChartRange.d30:
        return 30;
      case ChartRange.d90:
        return 90;
      case ChartRange.all:
        return null;
    }
  }
}

List<ChartParameter> buildParameters(List<Metric> metrics) {
  final parameters = <ChartParameter>{};

  for (final metric in metrics) {
    parameters.add(ChartParameter(name: metric.name, unit: metric.unit));
  }

  return parameters.toList()
    ..sort((a, b) => a.normalizedName.compareTo(b.normalizedName));
}

Metric? findMatchingMetric({
  required List<Metric> metrics,
  required int participantId,
  required String name,
  required String unit,
}) {
  final normalizedName = name.trim().toLowerCase();
  final normalizedUnit = unit.trim().toLowerCase();

  for (final metric in metrics) {
    if (metric.participantId != participantId) continue;
    if (metric.name.trim().toLowerCase() != normalizedName) continue;
    if (metric.unit.trim().toLowerCase() != normalizedUnit) continue;
    return metric;
  }

  return null;
}
