import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../data/models/invoice/invoices_monthly_model.dart';
import '../../../../../../data/services/internationalization/intl_service.dart';

class LineChartWidget extends StatefulWidget {
  final List<InvoicesMonthlyModel> data;

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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: AspectRatio(
              aspectRatio: 1.70,
              child: LineChart(showAvg ? avgData() : mainData()),
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
      final item = widget.data[i];
      spots.add(FlSpot(i.toDouble(), item.totalValue.toDouble()));
      labels.add(
        '${DateFormat.MMM().format(DateTime(item.year, item.month))}/${item.year}',
      );
    }

    final maxY =
        widget.data
            .map((e) => e.totalValue)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

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
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                formatCurrency(value.toInt()),
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
      maxY: maxY + 1000,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              return LineTooltipItem(
                formatCurrency(touchedSpot.y.toInt()),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 1,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),

          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors:
                  gradientColors.map((c) => c.withValues(alpha: 0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    final spots = <FlSpot>[];
    final avg =
        widget.data.map((e) => e.totalValue).reduce((a, b) => a + b) /
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
            colors:
                gradientColors.map((c) => c.withValues(alpha: 0.5)).toList(),
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
