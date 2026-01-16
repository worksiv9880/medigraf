class ChartParameter {
  final String name;
  final String unit;

  const ChartParameter({required this.name, required this.unit});

  String get normalizedName => name.trim().toLowerCase();
  String get normalizedUnit => unit.trim().toLowerCase();

  @override
  bool operator ==(Object other) {
    return other is ChartParameter &&
        other.normalizedName == normalizedName &&
        other.normalizedUnit == normalizedUnit;
  }

  @override
  int get hashCode => Object.hash(normalizedName, normalizedUnit);
}
