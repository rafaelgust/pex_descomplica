import 'package:flutter/material.dart';

import '../../../../../data/models/dashboard/monthly_bar_chart.dart';
import '../../../../../data/models/dashboard/product_pie_chart.dart';
import '../../../../controllers/dashboard_controller.dart';
import 'charts/bar_chart_widget.dart';
import 'charts/line_chart_widget.dart';
import 'charts/pie_chart_widget.dart';
import 'section_header.dart';

class DesktopCharts extends StatelessWidget {
  final DashboardController controller;
  const DesktopCharts({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: PieChartWidget(
                      products: [
                        ProductPieChart(
                          name: 'Café',
                          amount: 60,
                          urlImage:
                              'https://castronaves.vteximg.com.br/arquivos/ids/384748-1000-1000/9330_01.jpg',
                        ),
                        ProductPieChart(
                          name: 'Açúcar',
                          amount: 120,
                          urlImage:
                              'https://carrefourbrfood.vtexassets.com/arquivos/ids/110671165/acucar-refinado-uniao-docucar-1kg-1.jpg',
                        ),
                        ProductPieChart(
                          name: 'Arroz',
                          amount: 50,
                          urlImage:
                              'https://m.media-amazon.com/images/I/71rBEHnIkXL.jpg',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Vendas Mensais',
                    icon: Icons.trending_up,
                  ),
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
                    child: ValueListenableBuilder(
                      valueListenable: controller.invoicesMonthly,
                      builder: (
                        BuildContext context,
                        dynamic value,
                        Widget? child,
                      ) {
                        if (value.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nenhum dado encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        } else {
                          return LineChartWidget(data: value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionHeader(title: 'Entradas vs Saídas', icon: Icons.bar_chart),
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
    );
  }
}
