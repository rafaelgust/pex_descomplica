import 'package:flutter/material.dart';

import '../../../../../data/models/dashboard/monthly_bar_chart.dart';
import '../../../../../data/models/dashboard/product_pie_chart.dart';
import '../../../../../data/models/invoice/invoices_monthly_model.dart';
import 'charts/bar_chart_widget.dart';
import 'charts/line_chart_widget.dart';
import 'charts/pie_chart_widget.dart';
import 'section_header.dart';

class SectionCharts extends StatelessWidget {
  final List<ProductPieChart> pieChartData;
  final List<InvoicesMonthlyModel> invoicesMonthly;

  const SectionCharts({
    super.key,
    required this.pieChartData,
    required this.invoicesMonthly,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        direction:
            MediaQuery.of(context).size.width > 1200
                ? Axis.horizontal
                : Axis.vertical,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Vendas Mensais', icon: Icons.trending_up),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      invoicesMonthly.isEmpty
                          ? const Center(
                            child: Text(
                              'Nenhum dado encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                          : LineChartWidget(data: invoicesMonthly),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SectionHeader(
                  title: 'Produtos Populares',
                  icon: Icons.pie_chart,
                ),
                Container(
                  height: 400,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: PieChartWidget(products: pieChartData),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Entradas vs Saídas',
                  icon: Icons.bar_chart,
                ),
                Container(
                  width: double.infinity,
                  height: 520,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BarChartWidget(
                    data: [
                      MonthlyBarChart(month: 'Jan', entrada: 10, saida: 6),
                      MonthlyBarChart(month: 'Fev', entrada: 12, saida: 8),
                      MonthlyBarChart(month: 'Mar', entrada: 14, saida: 9),
                      MonthlyBarChart(month: 'Abr', entrada: 7, saida: 5),
                      MonthlyBarChart(month: 'Mai', entrada: 13, saida: 12),
                      MonthlyBarChart(month: 'Jun', entrada: 10, saida: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
