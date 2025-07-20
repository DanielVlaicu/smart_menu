import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final Map<DateTime, List<FlSpot>> accessDataPerDay = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateSampleData();
  }

  void _generateSampleData() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime day = now.subtract(Duration(days: i));
      List<FlSpot> hourlyData = List.generate(24, (hour) => FlSpot(hour.toDouble(), (hour % 5 + i).toDouble()));
      accessDataPerDay[DateTime(day.year, day.month, day.day)] = hourlyData;
    }
  }

  List<Widget> _buildCharts() {
    List<DateTime> sortedDates = accessDataPerDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedDates.take(7).map((date) => _buildChartForDay(date)).toList();
  }

  Widget _buildChartForDay(DateTime day) {
    final data = accessDataPerDay[day]!;
    final dateLabel = DateFormat('dd MMM yyyy').format(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            dateLabel,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1200, // Asta îți permite spațiere largă între ore
              child: LineChart(

                LineChartData(
                  minX: 0,
                  maxX: 23,
                  minY: 0,
                  // Adaugă padding suplimentar pentru a nu tăia partea de sus
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade700,
                      tooltipRoundedRadius: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'Ora ${spot.x.toInt()}: ${spot.y.toInt()} accesări',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    verticalInterval: 1,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 0.5),
                    getDrawingVerticalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, _) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('${value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, _) => Transform.translate(
                          offset: const Offset(-10, 5),
                          child: Text('${value.toInt()}h', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.white30),
                      bottom: BorderSide(color: Colors.white30),
                    ),
                  ),
                  clipData: FlClipData.all(), // Previne desenarea peste margini
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(radius: 3, color: Colors.blueAccent, strokeWidth: 0);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (picked != null && !accessDataPerDay.containsKey(picked)) {
      setState(() {
        selectedDate = picked;
        accessDataPerDay[picked] = List.generate(24, (hour) => FlSpot(hour.toDouble(), (hour % 4).toDouble()));
      });
    } else if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistici Accesări'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _pickDate,
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildCharts(),
        ),
      ),
    );
  }
}
