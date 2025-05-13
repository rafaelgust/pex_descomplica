import 'package:flutter/material.dart';

import 'widgets/home/dashboard/charts/bar_chart_widget.dart';
import 'widgets/home/dashboard/charts/line_chart_widget.dart';
import 'widgets/home/dashboard/charts/pie_chart_widget.dart';
import 'widgets/home/dashboard/infor_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;

          // Define breakpoints
          int crossAxisCount = 3;
          if (maxWidth < 1200) crossAxisCount = 2;
          if (maxWidth < 800) crossAxisCount = 1;

          double itemWidth =
              (maxWidth - (crossAxisCount - 1) * 16 - 32) / crossAxisCount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _responsiveCard(
                      child: const InforCard(
                        title: 'Total de Produtos em Estoque',
                        amount: '1.587',
                        value: 'R\$ 145.782,50',
                        icon: Icons.inventory_2,
                        color: Colors.blue,
                      ),
                      width: itemWidth,
                    ),
                    _responsiveCard(
                      child: const InforCard(
                        title: 'Débitos com Fornecedores',
                        amount: '23',
                        value: 'R\$ 1.587,00',
                        icon: Icons.warning_amber,
                        color: Colors.orange,
                      ),
                      width: itemWidth,
                    ),
                    _responsiveCard(
                      child: const InforCard(
                        title: 'Vendas Pendentes',
                        amount: '7',
                        value: 'R\$ 1.587,00',
                        icon: Icons.shopping_cart,
                        color: Colors.green,
                      ),
                      width: itemWidth,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionCard(
                  title: 'Distribuição de Produtos',
                  child: PieChartWidget(
                    produtos: [
                      Produto(
                        nome: 'Café',
                        quantidade: 30,
                        imagemUrl: 'https://example.com/imagens/cafe.png',
                      ),
                      Produto(
                        nome: 'Açúcar',
                        quantidade: 20,
                        imagemUrl: 'https://example.com/imagens/acucar.png',
                      ),
                      Produto(
                        nome: 'Arroz',
                        quantidade: 50,
                        imagemUrl: 'https://example.com/imagens/arroz.png',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Vendas Mensais',
                  child: LineChartWidget(
                    data: [
                      {'title': 'Fev/2025', 'value': 2400},
                      {'title': 'Mar/2025', 'value': 4000},
                      {'title': 'Abr/2025', 'value': 1800},
                      {'title': 'Mai/2025', 'value': 3200},
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Entrada vs Saída de Produtos',
                  child: BarChartWidget(
                    data: [
                      MonthlyEntry(month: 'Jan', entrada: 10, saida: 6),
                      MonthlyEntry(month: 'Fev', entrada: 12, saida: 8),
                      MonthlyEntry(month: 'Mar', entrada: 14, saida: 9),
                      MonthlyEntry(month: 'Abr', entrada: 7, saida: 5),
                      MonthlyEntry(month: 'Mai', entrada: 13, saida: 12),
                      MonthlyEntry(month: 'Jun', entrada: 10, saida: 11),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _responsiveCard({required Widget child, required double width}) {
    return SizedBox(width: width, child: child);
  }
}
