import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../data/models/dashboard/monthly_bar_chart.dart';

class BarChartWidget extends StatefulWidget {
  const BarChartWidget({
    super.key,
    required this.data,
    this.leftBarColor = Colors.green,
    this.rightBarColor = Colors.red,
    this.avgColor = Colors.amber,
  });

  final List<MonthlyBarChart> data;
  final Color leftBarColor;
  final Color rightBarColor;
  final Color avgColor;

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  final double width = 12;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    rawBarGroups = List.generate(widget.data.length, (index) {
      final entry = widget.data[index];
      return makeGroupData(index, entry.entrada, entry.saida);
    });
    showingBarGroups = List.of(rawBarGroups);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 700,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  maxY: _getMaxY() + 5,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final isEntrada = rodIndex == 0;
                        final month = widget.data[group.x.toInt()].month;
                        return BarTooltipItem(
                          '$month\n${isEntrada ? "Entrada" : "Saída"}: ${rod.toY}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response == null || response.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        });
                        return;
                      }

                      touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                          return;
                        }
                        showingBarGroups = List.of(rawBarGroups);
                        if (touchedGroupIndex != -1) {
                          final group = showingBarGroups[touchedGroupIndex];
                          final avg =
                              group.barRods
                                  .map((e) => e.toY)
                                  .reduce((a, b) => a + b) /
                              group.barRods.length;

                          showingBarGroups[touchedGroupIndex] = group.copyWith(
                            barRods:
                                group.barRods.map((e) {
                                  return e.copyWith(
                                    toY: avg,
                                    color: widget.avgColor,
                                  );
                                }).toList(),
                          );
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: bottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getLeftTitleInterval(),
                        reservedSize: 40,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: showingBarGroups,
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    if (value < 0 || value >= widget.data.length) return Container();
    final month = widget.data[value.toInt()].month;
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(
        month,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barsSpace: 4,
      barRods: [
        BarChartRodData(toY: y1, color: widget.leftBarColor, width: width),
        BarChartRodData(toY: y2, color: widget.rightBarColor, width: width),
      ],
    );
  }

  double _getMaxY() {
    double maxY = 0;
    for (var entry in widget.data) {
      maxY = [maxY, entry.entrada, entry.saida].reduce((a, b) => a > b ? a : b);
    }
    return maxY;
  }

  double _getLeftTitleInterval() {
    final max = _getMaxY();
    if (max <= 10) return 2;
    if (max <= 20) return 5;
    return 10;
  }
}
