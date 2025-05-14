import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const LineChartWidget({super.key, required this.data});

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [Colors.blue, Colors.green];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 700,
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color.fromARGB(255, 55, 48, 35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Gráfico de Vendas Mensais',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1.70,
                  child: LineChart(showAvg ? avgData() : mainData()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartData mainData() {
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (var i = 0; i < widget.data.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), (widget.data[i]['value'] ?? 0).toDouble()),
      );
      labels.add(widget.data[i]['title'] ?? '');
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine:
            (value) => const FlLine(color: Color(0xff37434d), strokeWidth: 1),
        getDrawingVerticalLine:
            (value) => const FlLine(color: Color(0xff37434d), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            interval: 1,
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  index >= 0 && index < labels.length ? labels[index] : '',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            interval: 1000,
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: widget.data.length.toDouble() - 1,
      minY: 0,
      maxY:
          widget.data
              .map((e) => e['value'])
              .cast<num>()
              .reduce((a, b) => a > b ? a : b)
              .toDouble() +
          1000,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  gradientColors.map((c) => c..withValues(alpha: 0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    final spots = <FlSpot>[];
    final avg =
        widget.data.map((e) => e['value'] as num).reduce((a, b) => a + b) /
        widget.data.length;

    for (var i = 0; i < widget.data.length; i++) {
      spots.add(FlSpot(i.toDouble(), avg.toDouble()));
    }

    return mainData().copyWith(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              gradientColors[0]..withValues(alpha: 0.5),
              gradientColors[1]..withValues(alpha: 0.5),
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}
