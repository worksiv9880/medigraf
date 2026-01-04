import '../../../../data/datasources/local/app_database.dart';

class ChartsState {
  Metric? selectedMetric;
  int selectedDays;

  ChartsState({
    this.selectedMetric,
    this.selectedDays = 7,
  });
}
