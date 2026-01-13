import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CoordinateGrid {
  final double horizontalInterval;
  final double verticalInterval;
  final Color lineColor;
  final double lineWidth;
  final List<int>? dashArray;

  const CoordinateGrid({
    required this.horizontalInterval,
    required this.verticalInterval,
    this.lineColor = const Color(0xFFE0E0E0),
    this.lineWidth = 1,
    this.dashArray,
  });

  FlGridData toGridData() {
    return FlGridData(
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: horizontalInterval,
      verticalInterval: verticalInterval,
      getDrawingHorizontalLine: (value) => _buildLine(),
      getDrawingVerticalLine: (value) => _buildLine(),
    );
  }

  FlLine _buildLine() {
    return FlLine(
      color: lineColor,
      strokeWidth: lineWidth,
      dashArray: dashArray,
    );
  }
}
