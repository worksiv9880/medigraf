import '../models/chart_parameter.dart';

class ChartsState {
  ChartParameter? selectedMetric;
  int selectedDays;

  ChartsState({
    this.selectedMetric,
    this.selectedDays = 7,
  });
}
