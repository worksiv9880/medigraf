class ChartParameter {
  final String name;
  final String unit;

  const ChartParameter({required this.name, required this.unit});

  @override
  bool operator ==(Object other) {
    return other is ChartParameter &&
        other.name.toLowerCase() == name.toLowerCase() &&
        other.unit.toLowerCase() == unit.toLowerCase();
  }

  @override
  int get hashCode => Object.hash(name.toLowerCase(), unit.toLowerCase());
}
