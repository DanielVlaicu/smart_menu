import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<FlSpot> accessData = [
    const FlSpot(0, 2),
    const FlSpot(1, 5),
    const FlSpot(2, 4),
    const FlSpot(3, 8),
    const FlSpot(4, 3),
    const FlSpot(5, 7),
    const FlSpot(6, 6),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistici Accesări'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) => Text('Zi ${value.toInt() + 1}', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: accessData,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
